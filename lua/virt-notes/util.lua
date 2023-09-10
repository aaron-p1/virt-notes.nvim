local config = require("virt-notes.config")

local M = {}

--- Returns the table index of the first occurrence of the given `value`
--- in the given `table`
---
--- @param table table
--- @param value any
--- @return integer? index
function M.index_of(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
end

--- Returns the zero-indexed line number of the cursor current window
---
--- @return integer line
function M.get_line()
    return vim.api.nvim_win_get_cursor(0)[1] - 1
end

--- Removes the scheme from the given `path` if it matches any of the `remove_schemes`
---
--- @param path string
--- @return string path
function M.clear_scheme(path)
    return select(
        1,
        string.gsub(path, "^([^:]+)://", function(scheme)
            if vim.tbl_contains(config.values.remove_schemes, scheme) then
                return ""
            end
        end)
    )
end

--- Returns absolute path of the buffer and optionally removes the scheme
---
--- @param bufnr number
--- @return string path
function M.get_path(bufnr)
    return M.clear_scheme(vim.api.nvim_buf_get_name(bufnr))
end

--- Cleans the given `path` for use as filename
---
--- Replaced characters are different on Windows and Unix systems, because
--- in earlier versions of this plugin, only `/` was replaced. This works
--- on Unix systems, so if a path has a schema like for example `fugitive://`
--- it was replaced as `fugitive:__`, but Windows does not allow `:`.
--- If the replaced characters are changed later on, note files would
--- not be found anymore. So differentiation between Unix and Windows is needed.
---
--- @param path string
--- @return string escaped_path
function M.clean_path(path)
    local pattern = config.is_windows and '[<>:"/\\|?*]' or "/"

    return select(1, string.gsub(path, pattern, "_"))
end

--- Convert the given `file_path` to a notes file path
---
--- @param file_path string
--- @return string notes_file_path
function M.file_to_notes_file(file_path)
    return config.values.notes_path .. "/" .. M.clean_path(file_path) .. ".txt"
end

--- Gets all notes files for files in the given `cwd`
---
--- @param cwd string
--- @return string[] notes_files
function M.get_project_notes_files(cwd)
    local clean_cwd = M.clean_path(cwd)
    local ok, notes_files = pcall(vim.fn.readdir, config.values.notes_path)

    if not ok then
        return {}
    end

    local result = {}

    for _, notes_file in ipairs(notes_files) do
        if vim.startswith(notes_file, clean_cwd) then
            table.insert(result, notes_file)
        end
    end

    return result
end

return M