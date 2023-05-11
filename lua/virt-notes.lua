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
 local mkdir = _local_3_["mkdir"]
 local readdir = _local_3_["readdir"]
 local readfile = _local_3_["readfile"]
 local stdpath = _local_3_["stdpath"]
 local substitute = _local_3_["substitute"]
 local writefile = _local_3_["writefile"]
 local _local_4_ = _local_1_["keymap"] local kset = _local_4_["set"]

 local namespace = nvim_create_namespace("VirtNotes") local note_highlight = "VirtNote"



 local default_mappings = {add = {keys = "<prefix>a", opts = {desc = "Add note"}}, edit = {keys = "<prefix>e", opts = {desc = "Edit note"}}, remove = {keys = "<prefix>dd", opts = {desc = "Delete note"}}, remove_on_line = {keys = "<prefix>dl", opts = {desc = "Delete all notes on line"}}, ["remove-in-file"] = {keys = "<prefix>da", opts = {desc = "Delete all notes in file"}}, copy = {keys = "<prefix>c", opts = {desc = "Copy note"}}, cut = {keys = "<prefix>x", opts = {desc = "Cut note"}}, paste = {keys = "<prefix>p", opts = {desc = "Paste note"}}}











 local notes_path = (stdpath("data") .. "/virt_notes")
 local remove_schemes = {"oil"}

 local _3fsaved_note = nil local delete_note_on_paste_3f = false


 local actions = {}

 nvim_set_hl(0, note_highlight, {default = true, link = "WildMenu"})

 local function index_of(table, value) _G.assert((nil ~= value), "Missing argument value on fennel/virt-notes.fnl:64") _G.assert((nil ~= table), "Missing argument table on fennel/virt-notes.fnl:64")
 local index = nil for k, v in pairs(table) do if index then break end
 if (v == value) then index = k else index = nil end end return index end

 local function clear_scheme(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:68")
 local new_path = path for _, scheme in ipairs(remove_schemes) do
 new_path = string.gsub(new_path, ("^" .. scheme .. "://"), "") end return new_path end

 local function get_absolute_path(_3fbufnr)
 return clear_scheme(nvim_buf_get_name((_3fbufnr or 0))) end

 local function clean_path(path) _G.assert((nil ~= path), "Missing argument path on fennel/virt-notes.fnl:75")
 return string.gsub(path, "/", "_") end

 local function file__3enotes_file(file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:78")
 return (notes_path .. "/" .. clean_path(file) .. ".txt") end

 local function get_line()
 local _let_6_ = nvim_win_get_cursor(0) local line = _let_6_[1]
 return (line - 1) end

 local function remove_scheme(notes_file) _G.assert((nil ~= notes_file), "Missing argument notes-file on fennel/virt-notes.fnl:85")
 return substitute(notes_file, "^\\(\\w\\+:__\\)\\?", "", "") end

 local function notes__3evirt_text(notes) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:88")
 local virt_text local _7_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for _, note in ipairs(notes) do
 local val_19_auto = {{note, note_highlight}, {" "}} if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _7_ = tbl_17_auto end virt_text = flatten(_7_, 1)

 table.remove(virt_text)
 return virt_text end

 local function extmarks__3enotes(extmarks) _G.assert((nil ~= extmarks), "Missing argument extmarks on fennel/virt-notes.fnl:95")
 local notes = {} for _, _9_ in ipairs(extmarks) do local _each_10_ = _9_ local _0 = _each_10_[1] local line = _each_10_[2] local _1 = _each_10_[3] local _each_11_ = _each_10_[4] local virt_text = _each_11_["virt_text"]
 local existing = (notes[line] or {}) local virt_note_text


 local function _12_(_241) return (_241)[1] end local function _13_(_241) return (_241)[2] end virt_note_text = tbl_map(_12_, tbl_filter(_13_, virt_text))
 do end (notes)[line] = tbl_flatten({existing, virt_note_text})
 notes = notes end return notes end

 local function get_all_notes(bufnr) _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:104")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {details = true})
 return extmarks__3enotes(extmarks) end

 local function get_notes(bufnr, line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:109") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:109")

 local extmarks = nvim_buf_get_extmarks(bufnr, namespace, {line, 0}, {line, -1}, {details = true})

 local line_notes = extmarks__3enotes(extmarks)
 return (line_notes[line] or {}) end

 local function set_all_notes(bufnr, all_notes, _3fdisable_event) _G.assert((nil ~= all_notes), "Missing argument all-notes on fennel/virt-notes.fnl:116") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:116")

 nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
 do local max_line = nvim_buf_line_count(bufnr)
 for line, notes in pairs(all_notes) do
 local real_line if (line >= max_line) then real_line = (max_line - 1) else real_line = line end
 nvim_buf_set_extmark(bufnr, namespace, real_line, 0, {virt_text = notes__3evirt_text(notes)}) end end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function set_notes(bufnr, line, notes, _3fdisable_event) _G.assert((nil ~= notes), "Missing argument notes on fennel/virt-notes.fnl:128") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:128") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:128")

 nvim_buf_clear_namespace(bufnr, namespace, line, (line + 1))
 if (#notes > 0) then
 nvim_buf_set_extmark(bufnr, namespace, line, 0, {virt_text = notes__3evirt_text(notes)}) else end

 if not _3fdisable_event then
 return nvim_exec_autocmds("User", {pattern = "VirtualNotesUpdated", data = {buf = bufnr}}) else return nil end end


 local function add_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:138") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:138") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:138")
 local existing = get_notes(bufnr, line)
 local note_exists_3f = tbl_contains(existing, note)
 if not note_exists_3f then
 table.insert(existing, note)
 return set_notes(bufnr, line, existing) else return nil end end

 local function remove_note(bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:145") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:145") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:145")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, note)
 if _3fnote_index then
 table.remove(existing, _3fnote_index)
 return set_notes(bufnr, line, existing) else return nil end end

 local function edit_note(bufnr, line, old_note, new_note) _G.assert((nil ~= new_note), "Missing argument new-note on fennel/virt-notes.fnl:152") _G.assert((nil ~= old_note), "Missing argument old-note on fennel/virt-notes.fnl:152") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:152") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:152")
 local existing = get_notes(bufnr, line)
 local _3fnote_index = index_of(existing, old_note)
 if _3fnote_index then
 existing[_3fnote_index] = new_note
 return set_notes(bufnr, line, existing) else return nil end end

 local function note__3eline(line_nr, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:159") _G.assert((nil ~= line_nr), "Missing argument line-nr on fennel/virt-notes.fnl:159")
 return (line_nr .. " " .. note) end

 local function line__3enote(line) _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:162")
 return string.match(line, "^(%d+) (.*)$") end

 local function persist_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:165") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:165")

 local notes_file = file__3enotes_file(file)
 local all_notes = get_all_notes(bufnr) local lines
 local function _21_() local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for line, notes in pairs(all_notes) do local val_19_auto
 do local tbl_17_auto0 = {} local i_18_auto0 = #tbl_17_auto0 for _, note in ipairs(notes) do
 local val_19_auto0 = note__3eline(line, note) if (nil ~= val_19_auto0) then i_18_auto0 = (i_18_auto0 + 1) do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0 else end end val_19_auto = tbl_17_auto0 end if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end return tbl_17_auto end lines = tbl_flatten(_21_())
 if (0 == #lines) then
 return delete(notes_file) else

 table.insert(lines, 1, file)
 return writefile(lines, notes_file) end end

 local function parse_notes_file(lines) _G.assert((nil ~= lines), "Missing argument lines on fennel/virt-notes.fnl:178")


 local file = lines[1]
 table.remove(lines, 1)

 local function _25_() local notes = {} for _, line in ipairs(lines) do
 local line_nr_str, note = line__3enote(line)
 local linenr = tonumber(line_nr_str)
 local existing = (notes[linenr] or {})
 if (linenr and note) then
 table.insert(existing, note)
 do end (notes)[linenr] = existing else end
 notes = notes end return notes end return {file, _25_()} end

 local function get_notes_from_file(notes_file) _G.assert((nil ~= notes_file), "Missing argument notes-file on fennel/virt-notes.fnl:193")

 local _27_, _28_ = pcall(readfile, notes_file) if ((_27_ == true) and ((_G.type(_28_) == "table") and (nil ~= (_28_)[1]))) then local l = (_28_)[1] local lines = _28_
 return parse_notes_file(lines) elseif true then local _ = _27_
 return {nil, {}} else return nil end end

 local function get_notes_in_files(files) local tbl_14_auto = {}

 for _, notes_file in ipairs(files) do local k_15_auto, v_16_auto = nil, nil
 do local notes_file0 = (notes_path .. "/" .. notes_file)
 local _let_30_ = get_notes_from_file(notes_file0) local file = _let_30_[1] local all_notes = _let_30_[2]
 k_15_auto, v_16_auto = file, all_notes end if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end return tbl_14_auto end

 local function load_notes(bufnr, file) _G.assert((nil ~= file), "Missing argument file on fennel/virt-notes.fnl:206") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:206")

 local notes_file = file__3enotes_file(file)
 local _let_32_ = get_notes_from_file(notes_file) local _ = _let_32_[1] local all_notes = _let_32_[2]
 return set_all_notes(bufnr, all_notes, true) end

 local function on_choice(callback, _3fchoice) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:212")
 if _3fchoice then return callback(_3fchoice) else return nil end end

 local function select_note_on_line(prompt, bufnr, line, callback) _G.assert((nil ~= callback), "Missing argument callback on fennel/virt-notes.fnl:215") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:215") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:215") _G.assert((nil ~= prompt), "Missing argument prompt on fennel/virt-notes.fnl:215")
 local _34_ = get_notes(bufnr, line) if ((_G.type(_34_) == "table") and (nil ~= (_34_)[1]) and (nil ~= (_34_)[2])) then local x = (_34_)[1] local y = (_34_)[2] local notes = _34_
 local function _35_(...) return on_choice(callback, ...) end return ui.select(notes, {prompt = prompt}, _35_) elseif ((_G.type(_34_) == "table") and (nil ~= (_34_)[1])) then local entry = (_34_)[1]
 return callback(entry) elseif true then local _ = _34_
 return nil else return nil end end

 local function get_project_notes_files(cwd)
 local clean_cwd = clean_path(cwd)
 local has_files_3f, notes_files = pcall(readdir, notes_path)
 if has_files_3f then
 local function _37_(_241) return startswith(_241, clean_cwd) end return tbl_filter(_37_, notes_files) else
 return {} end end

 local function get_notes_in_cwd()

 local cwd = getcwd()
 local notes_files = get_project_notes_files(cwd)
 return get_notes_in_files(notes_files) end

 local function save_note(delete_on_paste_3f, bufnr, line, note) _G.assert((nil ~= note), "Missing argument note on fennel/virt-notes.fnl:234") _G.assert((nil ~= line), "Missing argument line on fennel/virt-notes.fnl:234") _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:234") _G.assert((nil ~= delete_on_paste_3f), "Missing argument delete-on-paste? on fennel/virt-notes.fnl:234")
 _3fsaved_note = {bufnr = bufnr, line = line, note = note}
 delete_note_on_paste_3f = delete_on_paste_3f return nil end

 local function on_buf_read(_39_) local _arg_40_ = _39_ local bufnr = _arg_40_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:238")
 local file = get_absolute_path(bufnr)
 if ("" ~= file) then
 return load_notes(bufnr, file) else return nil end end

 local function on_buf_write(_42_) local _arg_43_ = _42_ local bufnr = _arg_43_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:243")
 local file = get_absolute_path(bufnr)
 if (1 == filereadable(file)) then
 return persist_notes(bufnr, file) else return nil end end

 local function on_virt_notes_updated(_45_) local _arg_46_ = _45_ local bufnr = _arg_46_["buf"] _G.assert((nil ~= bufnr), "Missing argument bufnr on fennel/virt-notes.fnl:248")
 local file = get_absolute_path(bufnr)
 local modified_3f = nvim_buf_get_option(bufnr, "modified")
 if (not modified_3f and ("" ~= file)) then
 return persist_notes(bufnr, file) else return nil end end

 actions.add = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _50_() local _48_ local function _49_(_241) return add_note(bufnr, line, _241) end _48_ = _49_ local function _51_(...) return on_choice(_48_, ...) end return _51_ end return ui.input({prompt = "Add note:"}, _50_()) end

 actions.edit = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line() local on_select
 local function _52_(note)

 local function _55_() local _53_
 local function _54_(_241) return edit_note(bufnr, line, note, _241) end _53_ = _54_ local function _56_(...) return on_choice(_53_, ...) end return _56_ end return ui.input({prompt = "Edit note: ", default = note}, _55_()) end on_select = _52_
 return select_note_on_line("Edit note", bufnr, line, on_select) end

 actions.remove = function()
 local file = get_absolute_path()
 local bufnr = nvim_get_current_buf()
 local line = get_line()

 local function _57_(...) return remove_note(bufnr, line, ...) end return select_note_on_line("Remove note", bufnr, line, _57_) end

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

 local function _58_(_241)
 save_note(delete_on_paste_3f, bufnr, line, _241)
 return nvim_echo({{success_msg}, {": "}, {_241}}, false, {}) end return select_note_on_line(prompt, bufnr, line, _58_) end

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

 local function replace_prefix(keys, prefix) _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:322") _G.assert((nil ~= keys), "Missing argument keys on fennel/virt-notes.fnl:322")
 local function _61_(word)
 if (string.lower(word) == "prefix") then
 return prefix else return nil end end return string.gsub(keys, "<([^>]+)>", _61_) end

 local function map_keys(prefix, mappings) _G.assert((nil ~= mappings), "Missing argument mappings on fennel/virt-notes.fnl:327") _G.assert((nil ~= prefix), "Missing argument prefix on fennel/virt-notes.fnl:327")

 local set_mappings local function _63_(_241) if (_241 == false) then return nil else return _241 end end set_mappings = tbl_map(_63_, mappings)
 for action, _65_ in pairs(set_mappings) do local _each_66_ = _65_ local keys = _each_66_["keys"] local opts = _each_66_["opts"]
 local real_keys = replace_prefix(keys, prefix)
 local callback = actions[action]
 if callback then
 kset("n", real_keys, callback, opts) else end end return nil end

 local function validate_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:336")
 local user_mappings local function _68_() local t_69_ = config.mappings if (nil ~= t_69_) then t_69_ = (t_69_).actions else end return t_69_ end user_mappings = (_68_() or {}) local map_rules
 do local tbl_14_auto = {} for action, map_opts in pairs(user_mappings) do
 local k_15_auto, v_16_auto = ("mappings.actions." .. action), {map_opts, {"table", "string", "boolean"}} if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then tbl_14_auto[k_15_auto] = v_16_auto else end end map_rules = tbl_14_auto end local rules





 local _73_ do local t_72_ = config.mappings if (nil ~= t_72_) then t_72_ = (t_72_).prefix else end _73_ = t_72_ end
 local _76_ do local t_75_ = config.mappings if (nil ~= t_75_) then t_75_ = (t_75_).actions else end _76_ = t_75_ end rules = {notes_path = {config.notes_path, {"string", "nil"}}, hl_group = {config.hl_group, {"string", "nil"}}, remove_schemes = {config.remove_schemes, {"table", "nil"}}, mappings = {config.mappings, {"table", "boolean", "nil"}}, ["mappings.prefix"] = {_73_, {"string", "nil"}}, ["mappings.actions"] = {_76_, {"table", "nil"}}}
 return validate(tbl_extend("error", rules, map_rules)) end

 local function apply_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:349")
 if config.notes_path then
 notes_path = config.notes_path else end
 if config.hl_group then
 nvim_set_hl(0, note_highlight, {link = config.hl_group}) else end
 if config.remove_schemes then
 remove_schemes = config.remove_schemes else end
 if (config.mappings ~= false) then
 local map_cfg = (config.mappings or {})
 local prefix = (map_cfg.prefix or "<Leader>v") local key_actions

 local function _81_(_241) if (type(_241) == "string") then return {keys = _241} else return _241 end end key_actions = tbl_map(_81_, (map_cfg.actions or {}))
 return map_keys(prefix, tbl_deep_extend("force", default_mappings, key_actions)) else return nil end end

 local function fix_config(config) _G.assert((nil ~= config), "Missing argument config on fennel/virt-notes.fnl:363")
 local _85_ do local t_84_ = config if (nil ~= t_84_) then t_84_ = (t_84_).mappings else end if (nil ~= t_84_) then t_84_ = (t_84_).actions else end if (nil ~= t_84_) then t_84_ = (t_84_).move else end _85_ = t_84_ end if _85_ then
 config.mappings.actions["cut"] = config.mappings.actions.move
 config.mappings.actions["move"] = nil else end
 return config end

 local function setup(_3fconfig)
 do local config = fix_config((_3fconfig or {}))
 validate_config(config)
 apply_config(config) end
 mkdir(notes_path, "p")
 if (1 == exists("g:loaded_telescope")) then
 local _let_90_ = require("telescope") local load_extension = _let_90_["load_extension"]
 load_extension("virt_notes") else end
 local group = nvim_create_augroup("VirtNotes", {clear = true})
 nvim_create_autocmd("BufRead", {group = group, callback = on_buf_read})
 nvim_create_autocmd("BufWrite", {group = group, callback = on_buf_write})
 return nvim_create_autocmd("User", {group = group, pattern = "VirtualNotesUpdated", callback = on_virt_notes_updated}) end




 return {setup = setup, get_notes_in_cwd = get_notes_in_cwd, get_notes_in_files = get_notes_in_files, actions = actions}
