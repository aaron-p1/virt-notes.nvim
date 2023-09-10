local notes = require("virt-notes.notes")

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local tconfig = require("telescope.config").values

--- Flattens the nested list of notes
---
--- @param notes_table table<string, table<integer, string[]>>
--- @return {file: string, line: integer, note: string}[]
local function flatten_notes(notes_table)
    local flattened = {}

    vim.iter(notes_table):each(function(file, file_notes)
        vim.iter(file_notes):each(function(line, line_notes)
            vim.iter(line_notes):each(function(note)
                table.insert(flattened, { file = file, line = line, note = note })
            end)
        end)
    end)

    return flattened
end

--- Generates a telescope entry from a note entry
---
--- @param note_entry {file: string, line: integer, note: string}
--- @return table
local function make_entry(note_entry)
    local path = vim.fn.fnamemodify(note_entry.file, ":.")
    local line_nr = note_entry.line + 1

    return {
        value = note_entry,
        ordinal = string.format("%s:%d | %s", path, line_nr, note_entry.note),
        display = string.format("%s:%d | %s", path, line_nr, note_entry.note),
        path = note_entry.file,
        lnum = line_nr,
    }
end

--- Open virt notes telescope picker
---
--- @param opts? table
local function telescope_virt_notes(opts)
    opts = opts or {}

    local cwd_notes = notes.get_notes_in_cwd()
    local results = flatten_notes(cwd_notes)
    local finder = finders.new_table({ results = results, entry_maker = make_entry })
    local picker = pickers.new(opts, {
        results_title = "Virtual Notes",
        prompt_title = "Filter Virtual Notes",
        finder = finder,
        sorter = tconfig.generic_sorter(opts),
        previewer = tconfig.grep_previewer(opts),
    })

    picker:find()
end

return require("telescope").register_extension({ exports = { virt_notes = telescope_virt_notes } })
