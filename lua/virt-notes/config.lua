--- @class virt_notes_config
--- @field notes_path string? path to save note files to
--- @field hl_group string? highlight group to use for virtual text
--- @field remove_schemes string[]? schemes to remove from paths when saving or loading notes
--- @field mappings user_mappings | false | nil mappings to use for the plugin

--- @class user_mappings
--- @field prefix string? `<prefix>` to use for mappings
--- @field actions user_mapping_actions | nil actions to map

--- @class user_mapping_actions
--- @field add user_mapping_action | nil
--- @field edit user_mapping_action | nil
--- @field remove user_mapping_action | nil
--- @field remove_on_line user_mapping_action | nil
--- @field remove_in_file user_mapping_action | nil
--- @field copy user_mapping_action | nil
--- @field cut user_mapping_action | nil
--- @field paste user_mapping_action | nil

--- @alias user_mapping_action user_mapping_action_opts | string | false

--- @class user_mapping_action_opts
--- @field keys string keys to map. `<prefix>` will be replaced with `mappings.prefix`
--- @field opts table options to pass to `nvim_set_keymap`

local is_windows = vim.fn.has("win32") == 1

local namespace = vim.api.nvim_create_namespace("VirtNotes")
local note_highlight = "VirtNote"

local default_mapping_prefix = "<Leader>v"

local default_mappings = {
    add = { keys = "<prefix>a", opts = { desc = "Add note" } },
    edit = { keys = "<prefix>e", opts = { desc = "Edit note" } },
    remove = { keys = "<prefix>dd", opts = { desc = "Delete note" } },
    remove_on_line = { keys = "<prefix>dl", opts = { desc = "Delete all notes on line" } },
    remove_in_file = { keys = "<prefix>da", opts = { desc = "Delete all notes in file" } },
    copy = { keys = "<prefix>c", opts = { desc = "Copy note" } },
    -- move is deprecated but still does the same as cut
    cut = { keys = "<prefix>x", opts = { desc = "Cut note" } },
    paste = { keys = "<prefix>p", opts = { desc = "Paste note" } },
}

local M = {
    values = {
        notes_path = vim.fn.stdpath("data") .. "/virt_notes",
        remove_schemes = { "oil" },
    },
    namespace = namespace,
    note_highlight = note_highlight,
    is_windows = is_windows,
}

--- Validates the given config
---
--- @param user_config virt_notes_config
local function validate_config(user_config)
    local mappings = user_config.mappings or {}

    vim.validate({
        notes_path = { user_config.notes_path, { "string", "nil" } },
        hl_group = { user_config.hl_group, { "string", "nil" } },
        remove_schemes = { user_config.remove_schemes, { "table", "nil" } },
        mappings = { user_config.mappings, { "table", "boolean", "nil" } },
        ["mappings.prefix"] = { mappings.prefix, { "string", "nil" } },
        ["mappings.actions"] = { mappings.actions, { "table", "nil" } },
    })

    for action, map_opts in pairs(mappings.actions or {}) do
        vim.validate({ ["mappings.actions." .. action] = { map_opts, { "table", "string", "boolean" } } })
    end
end

--- Replaces `"<prefix>"` in `keys` with the `prefix`
---
--- @param keys string
--- @param prefix string
--- @return string real_keys
local function replace_mapping_prefix(keys, prefix)
    return select(
        1,
        string.gsub(keys, "<([^>]+)>", function(word)
            if string.lower(word) == "prefix" then
                return prefix
            end
        end)
    )
end

--- Sets keymaps for the given `mappings`
---
--- @param prefix string
--- @param mappings table
local function map_keys(prefix, mappings)
    local actions = require("virt-notes.actions")

    for action, map_opts in pairs(mappings) do
        if map_opts ~= false then
            local real_keys = replace_mapping_prefix(map_opts.keys, prefix)
            local callback = actions[action]

            if callback then
                vim.keymap.set("n", real_keys, callback, map_opts.opts)
            end
        end
    end
end

--- Applies the given `user_config`
---
--- @param user_config virt_notes_config
function M.apply_config(user_config)
    validate_config(user_config)

    if user_config.notes_path then
        M.values.notes_path = user_config.notes_path
    end

    vim.fn.mkdir(M.values.notes_path, "p")

    if user_config.hl_group then
        vim.api.nvim_set_hl(0, note_highlight, { link = user_config.hl_group })
    end

    if user_config.remove_schemes then
        M.values.remove_schemes = user_config.remove_schemes
    end

    if user_config.mappings ~= false then
        local map_cfg = user_config.mappings or {}

        local prefix = map_cfg.prefix or default_mapping_prefix

        local user_mappings = vim.tbl_map(function(action)
            if type(action) == "string" then
                return { keys = action }
            end

            return action
        end, map_cfg.actions or {})

        map_keys(prefix, vim.tbl_deep_extend("force", default_mappings, user_mappings))
    end
end

return M