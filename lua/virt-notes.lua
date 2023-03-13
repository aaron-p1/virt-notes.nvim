 local _local_1_ = vim local startswith = _local_1_["startswith"]
 local tbl_contains = _local_1_["tbl_contains"]
 local tbl_extend = _local_1_["tbl_extend"]
 local tbl_filter = _local_1_["tbl_filter"]
 local tbl_flatten = _local_1_["tbl_flatten"]
 local tbl_map = _local_1_["tbl_map"]
 local ui = _local_1_["ui"]
 local validate = _local_1_["validate"]
 local _local_2_ = _local_1_["api"] local nvim_buf_clear_namespace = _local_2_["nvim_buf_clear_namespace"]
 local nvim_buf_get_extmarks = _local_2_["nvim_buf_get_extmarks"]
 local nvim_buf_get_name = _local_2_["nvim_buf_get_name"]
 local nvim_buf_get_option = _local_2_["nvim_buf_get_option"]
 local nvim_buf_set_extmark = _local_2_["nvim_buf_set_extmark"]
 local nvim_create_augroup = _local_2_["nvim_create_augroup"]
 local nvim_create_autocmd = _local_2_["nvim_create_autocmd"]
 local nvim_create_namespace = _local_2_["nvim_create_namespace"]
 local nvim_exec_autocmds = _local_2_["nvim_exec_autocmds"]
 local nvim_get_current_buf = _local_2_["nvim_get_current_buf"]
 local nvim_echo = _local_2_["nvim_echo"]
 local nvim_set_hl = _local_2_["nvim_set_hl"]
 local nvim_win_get_cursor = _local_2_["nvim_win_get_cursor"]
 local _local_3_ = _local_1_["fn"] local exists = _local_3_["exists"]
 local delete = _local_3_["delete"]
 local filereadable = _local_3_["filereadable"]
 local flatten = _local_3_["flatten"]
 local fnamemodify = _local_3_["fnamemodify"]
 local getcwd = _local_3_["getcwd"]
 local mkdir = _local_3_["mkdir"]
 local readdir = _local_3_["readdir"]
 local readfile = _local_3_["readfile"]
 local stdpath = _local_3_["stdpath"]
 local substitute = _local_3_["substitute"]
 local writefile = _local_3_["writefile"]
 local _local_4_ = _local_1_["keymap"] local kset = _local_4_["set"]

 local namespace = nvim_create_namespace("VirtNotes") local note_highlight = "VirtNote"



 local default_mappings = {add = {keys = "<prefix>a", opts = {desc = "Add note"}}, edit = {keys = "<prefix>e", opts = {desc = "Edit note"}}, remove = {keys = "<prefix>dd", opts = {desc = "Delete note"}}, remove_on_line = {keys = "<prefix>dl", opts = {desc = "Delete all notes on line"}}, ["remove-in-file"] = {keys = "<prefix>da", opts = {desc = "Delete all notes in file"}}, move = {keys = "<prefix>x", opts = {desc = "Move note"}}, paste = {keys = "<prefix>p", opts = {desc = "Paste note"}}}









 local notes_path = (stdpath("data") .. "/virt_notes")
 local remove_schemes = {"oil"}

 local _3fsaved_note = nil

 local actions = {}

 nvim_set_hl(0, note_highlight, {default = true, link = "WildMenu"})

 local function index_of(table, value) _G.assert((nil ~= value), "Missing argument value on fennel/virt-notes.fnl:59") _G.assert((nil ~= table), "Missing argument table on fennel/virt-notes.fnl:59")
 local index = nil for k, v in pairs(table) do if index then break end
 if (v == value) then index = k else index = nil end end return index end

 local function clear_scheme(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:63")
 local new_path = path for _, scheme in ipairs(remove_schemes) do
 new_path = string.gsub(new_path, ("^" .. scheme .. "://"), "") end return new_path end

 local function get_absolute_path(_3fbufnr)
 return clear_scheme(nvim_buf_get_name((_3fbufnr or 0))) end

 local function clean_path(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:70")
 return string.gsub(path, "/", "_") end

 local function file__3enotes_file(file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:73")
 return (notes_path .. "/" .. clean_path(file) .. ".txt") end

 local function get_line()
 local _let_6_ = nvim_win_get_cursor(0) local line = _let_6_[1]
 return (line - 1) end

 local function remove_scheme(notes_file) _G.assert((nil ~= notes_file), "Missing argument notes-file on fennel/virt-notes.fnl:80")
 return substitute(notes_file, "^\\(\\w\\+:__\\)\\?", "", "") end

 local function notes__3evirt_text(notes) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:83")
 local virt_text local _7_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for _, note in ipairs(notes) do
 local val_19_auto = {{note, note_highlight}, {" "}} if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _7_ = tbl_17_auto end virt_text = flatten(_7_, 1)

 table.remove(virt_text)
 return virt_text end

 local function extmarks__3enotes(extmarks) _G.assert((nil ~= extmarks), "Missing argument extmarks on fennel/virt-notes.fnl:90")
 local notes = {} for _, _9_ in ipairs(extmarks) do local _each_10_ = _9_ local _0 = _each_10_[1] local line = _each_10_[2] local _1 = _each_10_[3] local _each_11_ = _each_10_[4] local virt_text = _each_11_["virt_text"]
 local existing = (notes[line] or {}) local virt_note_text


 local function _12_(_241) return (_241)[1] end local function _13_(_241) return (_241)[2] end virt_note_text = tbl_map(_12_, tbl_filter(_13_, virt_text))
 do end (notes)[line] = tbl_flatten({existing, virt_note_text})
 notes = notes end return notes end

 local function get_all_notes(bufnr) _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:99")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {details = true})
 return extmarks__3enotes(extmarks) end

 local function get_notes(bufnr, line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:104") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:104")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, {line, 0}, {line, -1}, {details = true})

 local line_notes = extmarks__3enotes(extmarks)
 return (line_notes[line] or {}) end

 local function set_all_notes(bufnr, all_notes, _3fdisable_event) _G.assert((nil ~= all_notes), "Missing argument all-notes on fennel/virt-notes.fnl:111") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:111")

 nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
 for line, notes in pairs(all_notes) do
 nvim_buf_set_extmark(bufnr, namespace, line, 0, {virt_text = notes__3evirt_text(notes)}) end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function set_notes(bufnr, line, notes, _3fdisable_event) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:121") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:121") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:121")

 nvim_buf_clear_namespace(bufnr, namespace, line, (line + 1))
 if (#notes > 0) then
 nvim_buf_set_extmark(bufnr, namespace, line, 0, {virt_text = notes__3evirt_text(notes)}) else end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function add_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:131") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:131") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:131")
 local existing = get_notes(bufnr, line)
 local note_exists_3f = tbl_contains(existing, note)
 if not note_exists_3f then
 table.insert(existing, note)
 return set_notes(bufnr, line, existing) else return nil end end

 local function remove_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:138") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:138") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:138")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, note)
 if _3fnote_index then
 table.remove(existing, _3fnote_index)
 return set_notes(bufnr, line, existing) else return nil end end

 local function edit_note(bufnr, line, old_note, new_note) _G.assert((nil ~= new_note), "Missing argument new-note on fennel/virt-notes.fnl:145") _G.assert((nil ~= old_note), "Missing argument old-note on fennel/virt-notes.fnl:145") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:145") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:145")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, old_note)
 if _3fnote_index then
 existing[_3fnote_index] = new_note
 return set_notes(bufnr, line, existing) else return nil end end

 local function note__3eline(line_nr, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:152") _G.assert((nil ~= line_nr), "Missing argument line-nr on fennel/virt-notes.fnl:152")
 return (line_nr .. " " .. note) end

 local function line__3enote(line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:155")
 return string.match(line, "^(%d+) (.*)$") end

 local function persist_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:158") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:158")

 local notes_file = file__3enotes_file(file)
 local all_notes = get_all_notes(bufnr) local lines
 local function _20_() local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for line, notes in pairs(all_notes) do local val_19_auto
 do local tbl_17_auto0 = {} local i_18_auto0 = #tbl_17_auto0 for _, note in ipairs(notes) do
 local val_19_auto0 = note__3eline(line, note) if (nil ~= val_19_auto0) then i_18_auto0 = (i_18_auto0 + 1) do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0 else end end val_19_auto = tbl_17_auto0 end if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end return tbl_17_auto end lines = tbl_flatten(_20_())
 if (0 == #lines) then
 return delete(notes_file) else

 table.insert(lines, 1, file)
 return writefile(lines, notes_file) end end

 local function parse_notes_file(lines) _G.assert((nil ~= lines), "Missing argument lines on fennel/virt-notes.fnl:171")


 local file = lines[1]
 table.remove(lines, 1)

 local function _24_() local notes = {} for _, line in ipairs(lines) do
 local line_nr_str, note = line__3enote(line)
 local linenr = tonumber(line_nr_str)
 local existing = (notes[linenr] or {})
 if (linenr and note) then
 table.insert(existing, note)
 do end (notes)[linenr] = existing else end
 notes = notes end return notes end return {file, _24_()} end

 local function get_notes_from_file(notes_file) _G.assert((nil ~= notes_file), "Missing argument notes-file on fennel/virt-notes.fnl:186")

 local _26_, _27_ = pcall(readfile, notes_file) if ((_26_ == true) and ((_G.type(_27_) == "table") and (nil ~= (_27_)[1]))) then local l = (_27_)[1] local lines = _27_
 return parse_notes_file(lines) elseif true then local _ = _26_
 return {nil, {}} else return nil end end

 local function get_notes_in_files(files) local tbl_14_auto = {}

 for _, notes_file in ipairs(files) do local k_15_auto, v_16_auto = nil, nil
 do local notes_file0 = (notes_path .. "/" .. notes_file)
 local _let_29_ = get_notes_from_file(notes_file0) local file = _let_29_[1] local all_notes = _let_29_[2]
 k_15_auto, v_16_auto = file, all_notes end if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end return tbl_14_auto end

 local function load_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:199") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:199")

 local notes_file = file__3enotes_file(file)
 local _let_31_ = get_notes_from_file(notes_file) local _ = _let_31_[1] local all_notes = _let_31_[2]
 return set_all_notes(bufnr, all_notes, true) end

 local function on_choice(callback, _3fchoice) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:205")
 if _3fchoice then return callback(_3fchoice) else return nil end end

 local function select_note_on_line(prompt, bufnr, line, callback) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:208") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:208") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:208") _G.assert((nil ~= prompt), "Missing argument prompt on fennel/virt-notes.fnl:208")
 local _33_ = get_notes(bufnr, line) if ((_G.type(_33_) == "table") and (nil ~= (_33_)[1]) and (nil ~= (_33_)[2])) then local x = (_33_)[1] local y = (_33_)[2] local notes = _33_
 local function _34_(...) return on_choice(callback, ...) end return ui.select(notes, {prompt = prompt}, _34_) elseif ((_G.type(_33_) == "table") and (nil ~= (_33_)[1])) then local entry = (_33_)[1]
 return callback(entry) elseif true then local _ = _33_
 return nil else return nil end end

 local function get_project_notes_files(cwd)
 local clean_cwd = clean_path(cwd)
 local has_files_3f, notes_files = pcall(readdir, notes_path)
 if has_files_3f then
 local function _36_(_241) return startswith(_241, clean_cwd) end return tbl_filter(_36_, notes_files) else
 return {} end end

 local function get_notes_in_cwd()

 local cwd = getcwd()
 local notes_files = get_project_notes_files(cwd)
 return get_notes_in_files(notes_files) end

 local function on_buf_read(_38_) local _arg_39_ = _38_ local bufnr = _arg_39_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:227")
 local file = get_absolute_path(bufnr)
 if ("" ~= file) then
 return load_notes(bufnr, file) else return nil end end

 local function on_buf_write(_41_) local _arg_42_ = _41_ local bufnr = _arg_42_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:232")
 local file = get_absolute_path(bufnr)
 if (1 == filereadable(file)) then
 return persist_notes(bufnr, file) else return nil end end

 local function on_virt_notes_updated(_44_) local _arg_45_ = _44_ local bufnr = _arg_45_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:237")
 local file = get_absolute_path(bufnr)
 local modified_3f = nvim_buf_get_option(bufnr, "modified")
 if (not modified_3f and ("" ~= file)) then
 return persist_notes(bufnr, file) else return nil end end

 actions.add = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _49_() local _47_ local function _48_(_241) return add_note(bufnr, line, _241) end _47_ = _48_ local function _50_(...) return on_choice(_47_, ...) end return _50_ end return ui.input({prompt = "Add note:"}, _49_()) end

 actions.edit = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line() local on_select
 local function _51_(note)

 local function _54_() local _52_
 local function _53_(_241) return edit_note(bufnr, line, note, _241) end _52_ = _53_ local function _55_(...) return on_choice(_52_, ...) end return _55_ end return ui.input({prompt = "Edit note: ", default = note}, _54_()) end on_select = _51_
 return select_note_on_line("Edit note", bufnr, line, on_select) end

 actions.remove = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _56_(...) return remove_note(bufnr, line, ...) end return select_note_on_line("Remove note", bufnr, line, _56_) end

 actions.remove_on_line = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()
 return set_notes(bufnr, line, {}) end

 actions.remove_in_file = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 return set_all_notes(bufnr, {}) end

 actions.move = function()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _57_(_241)
 _3fsaved_note = {bufnr = bufnr, line = line, note = _241}
 return nvim_echo({{"Moving note: "}, {_241}}, false, {}) end return select_note_on_line("Move note", bufnr, line, _57_) end

 actions.paste = function()
 if _3fsaved_note then
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()
 add_note(bufnr, line, _3fsaved_note.note)
 remove_note(_3fsaved_note.bufnr, _3fsaved_note.line, _3fsaved_note.note)
 _3fsaved_note = {bufnr = bufnr, line = line, note = _3fsaved_note.note} return nil else
 return nvim_echo({{"No note selected", "ErrorMsg"}}, false, {}) end end

 local function replace_prefix(keys, prefix) _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:296") _G.assert((nil ~= keys), "Missing argument keys on fennel/virt-notes.fnl:296")
 local function _59_(word)
 if (string.lower(word) == "prefix") then
 return prefix else return nil end end return string.gsub(keys, "<([^>]+)>", _59_) end

 local function map_keys(prefix, mappings) _G.assert((nil ~= mappings), "Missing argument mappings on fennel/virt-notes.fnl:301") _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:301")

 local set_mappings local function _61_(_241) if (_241 == false) then return nil else return _241 end end set_mappings = tbl_map(_61_, mappings)
 for action, _63_ in pairs(set_mappings) do local _each_64_ = _63_ local keys = _each_64_["keys"] local opts = _each_64_["opts"]
 local real_keys = replace_prefix(keys, prefix)
 local callback = actions[action]
 if callback then
 kset("n", real_keys, callback, opts) else end end return nil end

 local function validate_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:310")
 local user_mappings local function _66_() local t_67_ = config.mappings if (nil ~= t_67_) then t_67_ = (t_67_).actions else end return t_67_ end user_mappings = (_66_() or {}) local map_rules
 do local tbl_14_auto = {} for action, map_opts in pairs(user_mappings) do
 local k_15_auto, v_16_auto = ("mappings.actions." .. action), {map_opts, {"table", "string", "boolean"}} if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end map_rules = tbl_14_auto end local rules





 local _71_ do local t_70_ = config.mappings if (nil ~= t_70_) then t_70_ = (t_70_).prefix else end _71_ = t_70_ end
 local _74_ do local t_73_ = config.mappings if (nil ~= t_73_) then t_73_ = (t_73_).actions else end _74_ = t_73_ end rules = {notes_path = {config.notes_path, {"string", "nil"}}, hl_group = {config.hl_group, {"string", "nil"}}, remove_schemes = {config.remove_schemes, {"table", "nil"}}, mappings = {config.mappings, {"table", "boolean", "nil"}}, ["mappings.prefix"] = {_71_, {"string", "nil"}}, ["mappings.actions"] = {_74_, {"table", "nil"}}}
 return validate(tbl_extend("error", rules, map_rules)) end

 local function apply_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:323")
 if config.notes_path then
 notes_path = config.notes_path else end
 if config.hl_group then
 nvim_set_hl(0, note_highlight, {link = config.hl_group}) else end
 if config.remove_schemes then
 remove_schemes = config.remove_schemes else end
 if (config.mappings ~= false) then
 local map_cfg = (config.mappings or {})
 local prefix = (map_cfg.prefix or "<Leader>v") local key_actions

 local function _79_(_241) if (type(_241) == "string") then return {keys = _241} else return _241 end end key_actions = tbl_map(_79_, (map_cfg.actions or {}))
 return map_keys(prefix, tbl_extend("force", default_mappings, key_actions)) else return nil end end

 local function setup(_3fconfig)
 do local config = (_3fconfig or {})
 validate_config(config)
 apply_config(config) end
 mkdir(notes_path, "p")
 if (1 == exists("g:loaded_telescope")) then
 local _let_82_ = require("telescope") local load_extension = _let_82_["load_extension"]
 load_extension("virt_notes") else end
 local group = nvim_create_augroup("VirtNotes", {clear = true})
 nvim_create_autocmd("BufRead", {group = group, callback = on_buf_read})
 nvim_create_autocmd("BufWrite", {group = group, callback = on_buf_write})
 return nvim_create_autocmd("User", {group = group, pattern = "VirtualNotesUpdated", callback = on_virt_notes_updated}) end




 return {setup = setup, get_notes_in_cwd = get_notes_in_cwd, get_notes_in_files = get_notes_in_files, actions = actions}
