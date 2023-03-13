 local _local_1_ = vim local _local_2_ = _local_1_["fn"] local flatten = _local_2_["flatten"] local fnamemodify = _local_2_["fnamemodify"]

 local _local_3_ = require("telescope") local register_extension = _local_3_["register_extension"]
 local _local_4_ = require("telescope.pickers") local new_picker = _local_4_["new"]
 local _local_5_ = require("telescope.finders") local new_finder = _local_5_["new_table"]
 local _local_6_ = require("telescope.config") local _local_7_ = _local_6_["values"] local generic_sorter = _local_7_["generic_sorter"] local grep_previewer = _local_7_["grep_previewer"]


 local _local_8_ = require("virt-notes") local get_notes_in_cwd = _local_8_["get_notes_in_cwd"]

 local function notes__3enote_entries(notes) _G.assert((nil ~= notes), "Missing argument notes on fennel/telescope/_extensions/virt_notes.fnl:11")

 local nested do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for file, file_notes in pairs(notes) do local val_19_auto
 do local tbl_17_auto0 = {} local i_18_auto0 = #tbl_17_auto0 for line, notes0 in pairs(file_notes) do local val_19_auto0
 do local tbl_17_auto1 = {} local i_18_auto1 = #tbl_17_auto1 for _, note in ipairs(notes0) do
 local val_19_auto1 = {file = file, line = line, note = note} if (nil ~= val_19_auto1) then i_18_auto1 = (i_18_auto1 + 1) do end (tbl_17_auto1)[i_18_auto1] = val_19_auto1 else end end val_19_auto0 = tbl_17_auto1 end if (nil ~= val_19_auto0) then i_18_auto0 = (i_18_auto0 + 1) do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0 else end end val_19_auto = tbl_17_auto0 end if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end nested = tbl_17_auto end
 return flatten(nested) end

 local function note_entry__3etelescope_entry(note_entry) _G.assert((nil ~= note_entry), "Missing argument note-entry on fennel/telescope/_extensions/virt_notes.fnl:19")
 local path = fnamemodify(note_entry.file, ":.")
 return {value = note_entry, display = (path .. " | " .. note_entry.note), ordinal = (path .. " " .. note_entry.line .. " " .. note_entry.note), path = note_entry.file, lnum = (1 + note_entry.line)} end





 local function telescope_virt_notes(_3fopts)
 local opts = (_3fopts or {})
 local notes = get_notes_in_cwd()
 local results = notes__3enote_entries(notes)
 local finder = new_finder({results = results, entry_maker = note_entry__3etelescope_entry})
 local picker = new_picker(opts, {results_title = "Virtual Notes", prompt_title = "Filter Virtual Notes", finder = finder, sorter = generic_sorter(opts), previewer = grep_previewer(opts)}) return picker:find() end







 return register_extension({exports = {virt_notes = telescope_virt_notes}})
