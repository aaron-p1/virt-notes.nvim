 local _local_1_ = vim local startswith = _local_1_["startswith"]
 local tbl_contains = _local_1_["tbl_contains"]
 local tbl_extend = _local_1_["tbl_extend"]
 local tbl_deep_extend = _local_1_["tbl_deep_extend"]
 local tbl_filter = _local_1_["tbl_filter"]
 local tbl_flatten = _local_1_["tbl_flatten"]
 local tbl_map = _local_1_["tbl_map"]
 local ui = _local_1_["ui"]
 local validate = _local_1_["validate"]
 local _local_2_ = _local_1_["api"] local nvim_buf_clear_namespace = _local_2_["nvim_buf_clear_namespace"]
 local nvim_buf_get_extmarks = _local_2_["nvim_buf_get_extmarks"]
 local nvim_buf_get_name = _local_2_["nvim_buf_get_name"]
 local nvim_buf_get_option = _local_2_["nvim_buf_get_option"]
 local nvim_buf_line_count = _local_2_["nvim_buf_line_count"]
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
 local has = _local_3_["has"]
 local mkdir = _local_3_["mkdir"]
 local readdir = _local_3_["readdir"]
 local readfile = _local_3_["readfile"]
 local stdpath = _local_3_["stdpath"]
 local substitute = _local_3_["substitute"]
 local writefile = _local_3_["writefile"]
 local _local_4_ = _local_1_["keymap"] local kset = _local_4_["set"]

 local is_windows = (1 == has("win32"))
 print(is_windows)

 local namespace = nvim_create_namespace("VirtNotes") local note_highlight = "VirtNote"



 local default_mappings = {add = {keys = "<prefix>a", opts = {desc = "Add note"}}, edit = {keys = "<prefix>e", opts = {desc = "Edit note"}}, remove = {keys = "<prefix>dd", opts = {desc = "Delete note"}}, remove_on_line = {keys = "<prefix>dl", opts = {desc = "Delete all notes on line"}}, ["remove-in-file"] = {keys = "<prefix>da", opts = {desc = "Delete all notes in file"}}, copy = {keys = "<prefix>c", opts = {desc = "Copy note"}}, cut = {keys = "<prefix>x", opts = {desc = "Cut note"}}, paste = {keys = "<prefix>p", opts = {desc = "Paste note"}}}











 local notes_path = (stdpath("data") .. "/virt_notes")
 local remove_schemes = {"oil"}

 local _3fsaved_note = nil local delete_note_on_paste_3f = false


 local actions = {}

 nvim_set_hl(0, note_highlight, {default = true, link = "WildMenu"})

 local function index_of(table, value) _G.assert((nil ~= value), "Missing argument value on fennel/virt-notes.fnl:68") _G.assert((nil ~= table), "Missing argument table on fennel/virt-notes.fnl:68")
 local index = nil for k, v in pairs(table) do if index then break end
 if (v == value) then index = k else index = nil end end return index end

 local function clear_scheme(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:72")
 local new_path = path for _, scheme in ipairs(remove_schemes) do
 new_path = string.gsub(new_path, ("^" .. scheme .. "://"), "") end return new_path end

 local function get_absolute_path(_3fbufnr)
 return clear_scheme(nvim_buf_get_name((_3fbufnr or 0))) end

 local function clean_path(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:79")










 if is_windows then
 return string.gsub(path, "[<>:\"/\\|?*]", "_") else
 return string.gsub(path, "/", "_") end end

 local function file__3enotes_file(file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:94")
 return (notes_path .. "/" .. clean_path(file) .. ".txt") end

 local function get_line()
 local _let_7_ = nvim_win_get_cursor(0) local line = _let_7_[1]
 return (line - 1) end

 local function notes__3evirt_text(notes) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:101")
 local virt_text local _8_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for _, note in ipairs(notes) do
 local val_19_auto = {{note, note_highlight}, {" "}} if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _8_ = tbl_17_auto end virt_text = flatten(_8_, 1)

 table.remove(virt_text)
 return virt_text end

 local function extmarks__3enotes(extmarks) _G.assert((nil ~= extmarks), "Missing argument extmarks on fennel/virt-notes.fnl:108")
 local notes = {} for _, _10_ in ipairs(extmarks) do local _each_11_ = _10_ local _0 = _each_11_[1] local line = _each_11_[2] local _1 = _each_11_[3] local _each_12_ = _each_11_[4] local virt_text = _each_12_["virt_text"]
 local existing = (notes[line] or {}) local virt_note_text


 local function _13_(_241) return (_241)[1] end local function _14_(_241) return (_241)[2] end virt_note_text = tbl_map(_13_, tbl_filter(_14_, virt_text))
 do end (notes)[line] = tbl_flatten({existing, virt_note_text})
 notes = notes end return notes end

 local function get_all_notes(bufnr) _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:117")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {details = true})
 return extmarks__3enotes(extmarks) end

 local function get_notes(bufnr, line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:122") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:122")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, {line, 0}, {line, -1}, {details = true})

 local line_notes = extmarks__3enotes(extmarks)
 return (line_notes[line] or {}) end

 local function set_all_notes(bufnr, all_notes, _3fdisable_event) _G.assert((nil ~= all_notes), "Missing argument all-notes on fennel/virt-notes.fnl:129") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:129")

 nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
 do local max_line = nvim_buf_line_count(bufnr)
 for line, notes in pairs(all_notes) do
 local real_line if (line >= max_line) then real_line = (max_line - 1) else real_line = line end
 nvim_buf_set_extmark(bufnr, namespace, real_line, 0, {virt_text = notes__3evirt_text(notes)}) end end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function set_notes(bufnr, line, notes, _3fdisable_event) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:141") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:141") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:141")

 nvim_buf_clear_namespace(bufnr, namespace, line, (line + 1))
 if (#notes > 0) then
 nvim_buf_set_extmark(bufnr, namespace, line, 0, {virt_text = notes__3evirt_text(notes)}) else end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function add_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:151") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:151") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:151")
 local existing = get_notes(bufnr, line)
 local note_exists_3f = tbl_contains(existing, note)
 if not note_exists_3f then
 table.insert(existing, note)
 return set_notes(bufnr, line, existing) else return nil end end

 local function remove_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:158") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:158") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:158")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, note)
 if _3fnote_index then
 table.remove(existing, _3fnote_index)
 return set_notes(bufnr, line, existing) else return nil end end

 local function edit_note(bufnr, line, old_note, new_note) _G.assert((nil ~= new_note), "Missing argument new-note on fennel/virt-notes.fnl:165") _G.assert((nil ~= old_note), "Missing argument old-note on fennel/virt-notes.fnl:165") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:165") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:165")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, old_note)
 if _3fnote_index then
 existing[_3fnote_index] = new_note
 return set_notes(bufnr, line, existing) else return nil end end

 local function note__3eline(line_nr, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:172") _G.assert((nil ~= line_nr), "Missing argument line-nr on fennel/virt-notes.fnl:172")
 return (line_nr .. " " .. note) end

 local function line__3enote(line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:175")
 return string.match(line, "^(%d+) (.*)$") end

 local function persist_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:178") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:178")

 local notes_file = file__3enotes_file(file)
 local all_notes = get_all_notes(bufnr) local lines
 local function _22_() local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for line, notes in pairs(all_notes) do local val_19_auto
 do local tbl_17_auto0 = {} local i_18_auto0 = #tbl_17_auto0 for _, note in ipairs(notes) do
 local val_19_auto0 = note__3eline(line, note) if (nil ~= val_19_auto0) then i_18_auto0 = (i_18_auto0 + 1) do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0 else end end val_19_auto = tbl_17_auto0 end if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end return tbl_17_auto end lines = tbl_flatten(_22_())
 if (0 == #lines) then
 return delete(notes_file) else

 table.insert(lines, 1, file)
 return writefile(lines, notes_file) end end

 local function parse_notes_file(lines) _G.assert((nil ~= lines), "Missing argument lines on fennel/virt-notes.fnl:191")


 local file = lines[1]
 table.remove(lines, 1)

 local function _26_() local notes = {} for _, line in ipairs(lines) do
 local line_nr_str, note = line__3enote(line)
 local linenr = tonumber(line_nr_str)
 local existing = (notes[linenr] or {})
 if (linenr and note) then
 table.insert(existing, note)
 do end (notes)[linenr] = existing else end
 notes = notes end return notes end return {file, _26_()} end

 local function get_notes_from_file(notes_file) _G.assert((nil ~= notes_file), "Missing argument notes-file on fennel/virt-notes.fnl:206")

 local _28_, _29_ = pcall(readfile, notes_file) if ((_28_ == true) and ((_G.type(_29_) == "table") and (nil ~= (_29_)[1]))) then local l = (_29_)[1] local lines = _29_
 return parse_notes_file(lines) elseif true then local _ = _28_
 return {nil, {}} else return nil end end

 local function get_notes_in_files(files) local tbl_14_auto = {}

 for _, notes_file in ipairs(files) do local k_15_auto, v_16_auto = nil, nil
 do local notes_file0 = (notes_path .. "/" .. notes_file)
 local _let_31_ = get_notes_from_file(notes_file0) local file = _let_31_[1] local all_notes = _let_31_[2]
 k_15_auto, v_16_auto = file, all_notes end if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end return tbl_14_auto end

 local function load_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:219") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:219")

 local notes_file = file__3enotes_file(file)
 local _let_33_ = get_notes_from_file(notes_file) local _ = _let_33_[1] local all_notes = _let_33_[2]
 return set_all_notes(bufnr, all_notes, true) end

 local function on_choice(callback, _3fchoice) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:225")
 if _3fchoice then return callback(_3fchoice) else return nil end end

 local function select_note_on_line(prompt, bufnr, line, callback) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:228") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:228") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:228") _G.assert((nil ~= prompt), "Missing argument prompt on fennel/virt-notes.fnl:228")
 local _35_ = get_notes(bufnr, line) if ((_G.type(_35_) == "table") and (nil ~= (_35_)[1]) and (nil ~= (_35_)[2])) then local x = (_35_)[1] local y = (_35_)[2] local notes = _35_
 local function _36_(...) return on_choice(callback, ...) end return ui.select(notes, {prompt = prompt}, _36_) elseif ((_G.type(_35_) == "table") and (nil ~= (_35_)[1])) then local entry = (_35_)[1]
 return callback(entry) elseif true then local _ = _35_
 return nil else return nil end end

 local function get_project_notes_files(cwd)
 local clean_cwd = clean_path(cwd)
 local has_files_3f, notes_files = pcall(readdir, notes_path)
 if has_files_3f then
 local function _38_(_241) return startswith(_241, clean_cwd) end return tbl_filter(_38_, notes_files) else
 return {} end end

 local function get_notes_in_cwd()

 local cwd = getcwd()
 local notes_files = get_project_notes_files(cwd)
 return get_notes_in_files(notes_files) end

 local function save_note(delete_on_paste_3f, bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:247") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:247") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:247") _G.assert((nil ~= delete_on_paste_3f), "Missing argument delete-on-paste? on fennel/virt-notes.fnl:247")
 _3fsaved_note = {bufnr = bufnr, line = line, note = note}
 delete_note_on_paste_3f = delete_on_paste_3f return nil end

 local function on_buf_read(_40_) local _arg_41_ = _40_ local bufnr = _arg_41_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:251")
 local file = get_absolute_path(bufnr)
 if ("" ~= file) then
 return load_notes(bufnr, file) else return nil end end

 local function on_buf_write(_43_) local _arg_44_ = _43_ local bufnr = _arg_44_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:256")
 local file = get_absolute_path(bufnr)
 if (1 == filereadable(file)) then
 return persist_notes(bufnr, file) else return nil end end

 local function on_virt_notes_updated(_46_) local _arg_47_ = _46_ local bufnr = _arg_47_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:261")
 local file = get_absolute_path(bufnr)
 local modified_3f = nvim_buf_get_option(bufnr, "modified")
 if (not modified_3f and ("" ~= file)) then
 return persist_notes(bufnr, file) else return nil end end

 actions.add = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _51_() local _49_ local function _50_(_241) return add_note(bufnr, line, _241) end _49_ = _50_ local function _52_(...) return on_choice(_49_, ...) end return _52_ end return ui.input({prompt = "Add note:"}, _51_()) end

 actions.edit = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line() local on_select
 local function _53_(note)

 local function _56_() local _54_
 local function _55_(_241) return edit_note(bufnr, line, note, _241) end _54_ = _55_ local function _57_(...) return on_choice(_54_, ...) end return _57_ end return ui.input({prompt = "Edit note: ", default = note}, _56_()) end on_select = _53_
 return select_note_on_line("Edit note", bufnr, line, on_select) end

 actions.remove = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _58_(...) return remove_note(bufnr, line, ...) end return select_note_on_line("Remove note", bufnr, line, _58_) end

 actions.remove_on_line = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()
 return set_notes(bufnr, line, {}) end

 actions.remove_in_file = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 return set_all_notes(bufnr, {}) end

 actions["save-note"] = function(_3fprompt, _3fsuccess_msg, _3fdelete_on_paste_3f)
 local prompt = (_3fprompt or "Save note")
 local success_msg = (_3fsuccess_msg or "Note saved")
 local delete_on_paste_3f = (_3fdelete_on_paste_3f or false)
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _59_(_241)
 save_note(delete_on_paste_3f, bufnr, line, _241)
 return nvim_echo({{success_msg}, {": "}, {_241}}, false, {}) end return select_note_on_line(prompt, bufnr, line, _59_) end

 actions.copy = function()
 return actions["save-note"]("Copy note", "Note copied", false) end

 actions.move = function()
 vim.deprecate("actions.move()", "actions.cut()", "2024", "virt-notes.nvim", true)
 return actions["save-note"]("Move note", "Moving note", true) end

 actions.cut = function()
 return actions["save-note"]("Cut note", "Note cut", true) end

 actions.paste = function()
 if _3fsaved_note then
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()
 local note_text = _3fsaved_note.note
 if delete_note_on_paste_3f then
 remove_note(_3fsaved_note.bufnr, _3fsaved_note.line, _3fsaved_note.note) else end
 add_note(bufnr, line, note_text)
 return save_note(delete_note_on_paste_3f, bufnr, line, note_text) else
 return nvim_echo({{"No note selected", "ErrorMsg"}}, false, {}) end end

 local function replace_prefix(keys, prefix) _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:335") _G.assert((nil ~= keys), "Missing argument keys on fennel/virt-notes.fnl:335")
 local function _62_(word)
 if (string.lower(word) == "prefix") then
 return prefix else return nil end end return string.gsub(keys, "<([^>]+)>", _62_) end

 local function map_keys(prefix, mappings) _G.assert((nil ~= mappings), "Missing argument mappings on fennel/virt-notes.fnl:340") _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:340")

 local set_mappings local function _64_(_241) if (_241 == false) then return nil else return _241 end end set_mappings = tbl_map(_64_, mappings)
 for action, _66_ in pairs(set_mappings) do local _each_67_ = _66_ local keys = _each_67_["keys"] local opts = _each_67_["opts"]
 local real_keys = replace_prefix(keys, prefix)
 local callback = actions[action]
 if callback then
 kset("n", real_keys, callback, opts) else end end return nil end

 local function validate_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:349")
 local user_mappings local function _69_() local t_70_ = config.mappings if (nil ~= t_70_) then t_70_ = (t_70_).actions else end return t_70_ end user_mappings = (_69_() or {}) local map_rules
 do local tbl_14_auto = {} for action, map_opts in pairs(user_mappings) do
 local k_15_auto, v_16_auto = ("mappings.actions." .. action), {map_opts, {"table", "string", "boolean"}} if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end map_rules = tbl_14_auto end local rules





 local _74_ do local t_73_ = config.mappings if (nil ~= t_73_) then t_73_ = (t_73_).prefix else end _74_ = t_73_ end
 local _77_ do local t_76_ = config.mappings if (nil ~= t_76_) then t_76_ = (t_76_).actions else end _77_ = t_76_ end rules = {notes_path = {config.notes_path, {"string", "nil"}}, hl_group = {config.hl_group, {"string", "nil"}}, remove_schemes = {config.remove_schemes, {"table", "nil"}}, mappings = {config.mappings, {"table", "boolean", "nil"}}, ["mappings.prefix"] = {_74_, {"string", "nil"}}, ["mappings.actions"] = {_77_, {"table", "nil"}}}
 return validate(tbl_extend("error", rules, map_rules)) end

 local function apply_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:362")
 if config.notes_path then
 notes_path = config.notes_path else end
 if config.hl_group then
 nvim_set_hl(0, note_highlight, {link = config.hl_group}) else end
 if config.remove_schemes then
 remove_schemes = config.remove_schemes else end
 if (config.mappings ~= false) then
 local map_cfg = (config.mappings or {})
 local prefix = (map_cfg.prefix or "<Leader>v") local key_actions

 local function _82_(_241) if (type(_241) == "string") then return {keys = _241} else return _241 end end key_actions = tbl_map(_82_, (map_cfg.actions or {}))
 return map_keys(prefix, tbl_deep_extend("force", default_mappings, key_actions)) else return nil end end

 local function fix_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:376")
 local _86_ do local t_85_ = config if (nil ~= t_85_) then t_85_ = (t_85_).mappings else end if (nil ~= t_85_) then t_85_ = (t_85_).actions else end if (nil ~= t_85_) then t_85_ = (t_85_).move else end _86_ = t_85_ end if _86_ then
 config.mappings.actions["cut"] = config.mappings.actions.move
 config.mappings.actions["move"] = nil else end
 return config end

 local function setup(_3fconfig)
 do local config = fix_config((_3fconfig or {}))
 validate_config(config)
 apply_config(config) end
 mkdir(notes_path, "p")
 if (1 == exists("g:loaded_telescope")) then
 local _let_91_ = require("telescope") local load_extension = _let_91_["load_extension"]
 load_extension("virt_notes") else end
 local group = nvim_create_augroup("VirtNotes", {clear = true})
 nvim_create_autocmd("BufRead", {group = group, callback = on_buf_read})
 nvim_create_autocmd("BufWrite", {group = group, callback = on_buf_write})
 return nvim_create_autocmd("User", {group = group, pattern = "VirtualNotesUpdated", callback = on_virt_notes_updated}) end




 return {setup = setup, get_notes_in_cwd = get_notes_in_cwd, get_notes_in_files = get_notes_in_files, actions = actions}
