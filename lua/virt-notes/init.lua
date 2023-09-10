local config = require("virt-notes.config")
local util = require("virt-notes.util")
local notes = require("virt-notes.notes")

local M = {
    get_notes_in_cwd = notes.get_notes_in_cwd,
    get_notes_in_files = notes.get_notes_in_files,
    actions = require("virt-notes.actions"),
}

--- Callback called when notes were edited.
---
--- @param event table
function M.on_virt_notes_updated(event)
    local buf = event.data.buf

    local file = util.get_path(buf)
    local modified = vim.api.nvim_buf_get_option(buf, "modified")

    if not modified and file ~= "" then
        notes.persist_notes(buf)
    end
end

--- Sets up the plugin with the given `user_config`
---
--- @param user_config virt_notes_config?
function M.setup(user_config)
    user_config = user_config or {}

    config.apply_config(user_config)

    local group = vim.api.nvim_create_augroup("VirtNotes", { clear = true })

    vim.api.nvim_create_autocmd("BufRead", {
        group = group,
        callback = function(event)
            notes.load_notes(event.buf)
        end,
    })

    vim.api.nvim_create_autocmd("BufWrite", {
        group = group,
        callback = function(event)
            notes.persist_notes(event.buf)
        end,
    })

    vim.api.nvim_create_autocmd(
        "User",
        { group = group, pattern = "VirtualNotesUpdated", callback = M.on_virt_notes_updated }
    )

    if vim.fn.has("vim_starting") == 0 then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                notes.load_notes(buf)
            end
        end
    end
end

return M