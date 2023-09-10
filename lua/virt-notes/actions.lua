local util = require("virt-notes.util")
local notes = require("virt-notes.notes")

local M = {}

--- Executes `callback` if choice is not nil.
---
--- @param callback fun(input: string)
--- @return fun(input: string | nil)
local function on_ui_action(callback)
    return function(input)
        if input ~= nil then
            callback(input)
        end
    end
end

--- Prompts user to select a note on the current `bufnr` at the cursor `line`.
---
--- If there is only one note, it will be selected without prompting.
---
--- @param prompt string
--- @param bufnr integer
--- @param line integer
--- @param callback fun(text: string)
local function select_note_on_line(prompt, bufnr, line, callback)
    local line_notes = notes.get_notes_at_line(bufnr, line)

    if #line_notes == 1 then
        callback(line_notes[1])
    elseif #line_notes > 1 then
        vim.ui.select(line_notes, { prompt = prompt }, on_ui_action(callback))
    end
end

--- Saves the selected note in a temporary variable for pasting later.
---
--- @param prompt string?
--- @param success_msg string?
--- @param delete_on_paste boolean?
local function save_note(prompt, success_msg, delete_on_paste)
    prompt = prompt or "Save note"
    success_msg = success_msg or "Note saved"
    delete_on_paste = delete_on_paste or false

    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()

    select_note_on_line(prompt, bufnr, line, function(note)
        notes.yank_note(bufnr, line, note, delete_on_paste)
        vim.api.nvim_echo({ { success_msg .. ": " .. note } }, false, {})
    end)
end

--- Adds a note to the current `bufnr` at the cursor `line`.
function M.add()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()

    vim.ui.input(
        { prompt = "Add note:" },
        on_ui_action(function(text)
            notes.add_note(bufnr, line, text)
        end)
    )
end

--- Edits the selected note in the current `bufnr` at the cursor `line`.
function M.edit()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()

    select_note_on_line("Edit note", bufnr, line, function(note)
        vim.ui.input(
            { prompt = "Edit note: ", default = note },
            on_ui_action(function(new_text)
                notes.edit_note(bufnr, line, note, new_text)
            end)
        )
    end)
end

--- Removes the selected note in the current `bufnr` at the cursor `line`.
function M.remove()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()

    select_note_on_line("Remove note", bufnr, line, function(note)
        notes.remove_note(bufnr, line, note)
    end)
end

--- Removes all notes in the current `bufnr` at the cursor `line`.
function M.remove_on_line()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()

    notes.set_notes_at_line(bufnr, line, {})
end

--- Removes all notes in the current `bufnr`.
function M.remove_in_file()
    local bufnr = vim.api.nvim_get_current_buf()

    vim.ui.input(
        { prompt = "Are you sure you want to remove all notes in current buffer? (y/N):" },
        on_ui_action(function(choice)
            if choice == "y" or choice == "Y" then
                notes.set_all_notes(bufnr, {})
            end
        end)
    )
end

--- Yanks the selected note in the current `bufnr` at the cursor `line` for copying.
---
--- Can be pasted with `paste()`
function M.copy()
    save_note("Copy note", "Note copied", false)
end

--- Yanks the selected note in the current `bufnr` at the cursor `line` for moving.
---
--- Can be pasted with `paste()` and will be deleted after pasting.
function M.move()
    vim.deprecate("actions.move()", "actions.cut()", "2024", "virt-notes.nvim", true)
    save_note("Move note", "Moving note", true)
end

--- Yanks the selected note in the current `bufnr` at the cursor `line` for moving.
---
--- Can be pasted with `paste()` and will be deleted after pasting.
function M.cut()
    save_note("Cut note", "Note cut", true)
end

--- Pastes the note saved with `copy()` or `cut()` in the current `bufnr` at the cursor `line`.
---
--- Deletes the note after pasting if it was saved with `cut()`.
function M.paste()
    if not notes.yanked_note then
        vim.api.nvim_echo({ { "No note selected", "ErrorMsg" } }, false, {})
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local line = util.get_line()
    local note_text = notes.yanked_note.note

    if notes.yanked_note.delete_on_paste then
        notes.remove_note(notes.yanked_note.bufnr, notes.yanked_note.line, notes.yanked_note.note)
    end

    notes.add_note(bufnr, line, note_text)

    -- Yank note again, so a cut note can be pasted multiple times
    notes.yank_note(bufnr, line, note_text, notes.yanked_note.delete_on_paste)
end

return M
