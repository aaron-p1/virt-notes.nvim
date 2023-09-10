local config = require("virt-notes.config")
local util = require("virt-notes.util")

local M = {
    --- The note that was saved for pasting.
    ---
    --- @type { buffer: integer, line: integer, note: string, delete_on_paste: boolean } | nil
    yanked_note = nil,
}

--- Splits a string into line number and note.
---
--- @param line string
--- @return integer? line_nr
--- @return string? text
local function line_to_note(line)
    local line_nr, text = string.match(line, "^(%d+) (.*)$")

    return tonumber(line_nr), text
end

--- Parses the notes file content and returns the file name and notes.
--- The first line of the notes file has to be the file name.
---
--- Example of a notes file:
---    `/home/user/notes.md
---    0 This is a note
---    0 This is another note on the same line
---    2 This is another note`
---
--- This will return:
---   `"/home/user/notes.md", {
---     [0] = { "This is a note", "This is another note on the same line" },
---     [2] = { "This is another note" },
---   }`
---
--- @param lines string[]
--- @return string file
--- @return table<integer, string[]> notes
function M.parse_notes_file(lines)
    local file = lines[1]
    local notes = {}

    for index, line in ipairs(lines) do
        if index ~= 1 then
            local line_nr, text = line_to_note(line)

            if line_nr and text then
                if notes[line_nr] == nil then
                    notes[line_nr] = { text }
                else
                    table.insert(notes[line_nr], text)
                end
            end
        end
    end

    return file, notes
end

--- Loads all notes from a file and returns it.
---
--- @param notes_file string
--- @return string? file
--- @return table<integer, string[]> notes
function M.get_notes_from_file(notes_file)
    local ok, lines = pcall(vim.fn.readfile, notes_file)

    if not ok then
        return nil, {}
    end

    return M.parse_notes_file(lines)
end

--- Converts a list of notes to a list of extmark virtual text.
---
--- @param notes string[]
--- @return string[][] virt_text for `nvim_buf_set_extmark` function
local function notes_to_virt_text(notes)
    if #notes == 0 then
        return {}
    end

    local virt_text = {}

    for index, note in ipairs(notes) do
        if index ~= 1 then
            table.insert(virt_text, { " " })
        end
        table.insert(virt_text, { note, config.note_highlight })
    end

    return virt_text
end

--- Sets all notes for a buffer.
---
--- @param bufnr integer
--- @param all_notes table<integer, string[]>
--- @param with_autocmd? boolean if true, the `VirtualNotesUpdated` autocmd will be triggered
function M.set_all_notes(bufnr, all_notes, with_autocmd)
    with_autocmd = with_autocmd == nil and true or with_autocmd

    vim.api.nvim_buf_clear_namespace(bufnr, 0, 0, -1)

    local max_line = vim.api.nvim_buf_line_count(bufnr) - 1

    for linenr, notes in pairs(all_notes) do
        vim.api.nvim_buf_set_extmark(bufnr, config.namespace, math.min(linenr, max_line), 0, {
            virt_text = notes_to_virt_text(notes),
        })
    end

    if with_autocmd then
        vim.api.nvim_exec_autocmds("User", { pattern = "VirtualNotesUpdated", data = { buf = bufnr } })
    end
end

--- Sets notes in `bufnr` at `line`.
---
--- @param bufnr integer
--- @param line integer zero-indexed
--- @param notes string[]
function M.set_notes_at_line(bufnr, line, notes)
    vim.api.nvim_buf_clear_namespace(bufnr, config.namespace, line, line + 1)

    if #notes > 0 then
        vim.api.nvim_buf_set_extmark(bufnr, config.namespace, line, 0, {
            virt_text = notes_to_virt_text(notes),
        })
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "VirtualNotesUpdated", data = { buf = bufnr } })
end

--- Loads all notes for a buffer.
---
--- @param bufnr integer
function M.load_notes(bufnr)
    local file = util.get_path(bufnr)

    if file == "" then
        return
    end

    local notes_file = util.file_to_notes_file(file)
    local _, all_notes = M.get_notes_from_file(notes_file)

    M.set_all_notes(bufnr, all_notes, false)
end

--- Converts a list of extmarks to a list of notes.
---
--- @param extmarks any[]
--- @return table<integer, string[]> notes
local function extmarks_to_notes(extmarks)
    local notes = {}

    for _, extmark in ipairs(extmarks) do
        local line = extmark[2]
        local virt_text = extmark[4].virt_text

        for _, virt_text_entry in ipairs(virt_text) do
            if virt_text_entry[2] then
                if notes[line] == nil then
                    notes[line] = { virt_text_entry[1] }
                else
                    table.insert(notes[line], virt_text_entry[1])
                end
            end
        end
    end

    return notes
end

--- Gets all notes for a buffer.
---
--- @param bufnr integer
--- @return table<integer, string[]> notes
function M.get_all_notes(bufnr)
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, config.namespace, 0, -1, { details = true })

    return extmarks_to_notes(extmarks)
end

--- Gets notes in `bufnr` at `line`.
---
--- @param bufnr integer
--- @param line integer zero-indexed
--- @return string[] notes
function M.get_notes_at_line(bufnr, line)
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, config.namespace, { line, 0 }, { line, -1 }, {
        details = true,
    })

    local line_notes = extmarks_to_notes(extmarks)
    return line_notes[line] or {}
end

--- Persists all notes for a buffer.
---
--- @param bufnr integer
function M.persist_notes(bufnr)
    local file = util.get_path(bufnr)

    if file == "" then
        return
    end

    local notes_file = util.file_to_notes_file(file)
    local all_notes = M.get_all_notes(bufnr)

    local lines = {}

    for linenr, notes in vim.spairs(all_notes) do
        for _, note in ipairs(notes) do
            table.insert(lines, string.format("%d %s", linenr, note))
        end
    end

    if #lines == 0 then
        vim.fn.delete(notes_file)
    else
        table.insert(lines, 1, file)
        vim.fn.writefile(lines, notes_file)
    end
end

--- Gets all notes in the given `notes_files`.
---
--- @param notes_files string[]
--- @return table<string, table<integer, string[]>> notes `{ file = { line = {notes} } }`
function M.get_notes_in_files(notes_files)
    local all_notes = {}

    for _, notes_file in ipairs(notes_files) do
        notes_file = config.values.notes_path .. "/" .. notes_file
        local file, notes = M.get_notes_from_file(notes_file)

        assert(file ~= nil, "Could not load notes file: " .. notes_file)

        all_notes[file] = notes
    end

    return all_notes
end

--- Gets all notes in the current working directory.
---
--- @return table<string, table<integer, string[]>> notes `{ file = { line = {notes} } }`
function M.get_notes_in_cwd()
    local cwd = vim.fn.getcwd()
    local notes_files = util.get_project_notes_files(cwd)

    return M.get_notes_in_files(notes_files)
end

--- Adds the `text` as a note to the given `bufnr` at `line`.
---
--- If the note already exists, it will not be added.
--- (Limitation because of ui notes selection implementation)
---
--- @param bufnr integer
--- @param line integer
--- @param text string
function M.add_note(bufnr, line, text)
    local notes = M.get_notes_at_line(bufnr, line)
    local note_exists = vim.tbl_contains(notes, text)

    if not note_exists then
        table.insert(notes, text)
        M.set_notes_at_line(bufnr, line, notes)
    end
end

--- Changes `note` text in the given `bufnr` at `line` to `new_text`.
---
--- @param bufnr integer
--- @param line integer
--- @param note string
--- @param new_text string
function M.edit_note(bufnr, line, note, new_text)
    local notes = M.get_notes_at_line(bufnr, line)
    local note_index = util.index_of(notes, note)

    if note_index then
        notes[note_index] = new_text
        M.set_notes_at_line(bufnr, line, notes)
    end
end

--- Removes the `note` in the given `bufnr` at `line`.
---
--- @param bufnr integer
--- @param line integer
--- @param note string
function M.remove_note(bufnr, line, note)
    local notes = M.get_notes_at_line(bufnr, line)
    local note_index = util.index_of(notes, note)

    if note_index then
        table.remove(notes, note_index)
        M.set_notes_at_line(bufnr, line, notes)
    end
end

--- Saves the `note` in the given `bufnr` at `line` for pasting.
---
--- @param bufnr integer
--- @param line integer
--- @param note string
--- @param delete_on_paste boolean
function M.yank_note(bufnr, line, note, delete_on_paste)
    M.yanked_note = {
        bufnr = bufnr,
        line = line,
        note = note,
        delete_on_paste = delete_on_paste,
    }
end

return M