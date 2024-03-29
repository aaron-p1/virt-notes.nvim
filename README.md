# Virtual notes in any buffer

Are you tired of not being able to add comments to certain files or buffers in Neovim? Look no
further than this powerful plugin! With its help, you can add notes to JSON files and even the
read-only [vim-fugitive](https://github.com/tpope/vim-fugitive) status buffer.
Your notes will be displayed as virtual text and saved to a default location of
`stdpath("data") + "/virt_notes/"`.


https://user-images.githubusercontent.com/62202958/224789708-d6f70987-6724-4498-9d0b-5d333aabc3ca.mp4

In this video I use the [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) color scheme,
[dressing.nvim](https://github.com/stevearc/dressing.nvim) for input and
[dressing.nvim](https://github.com/stevearc/dressing.nvim) +
[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for selection.

## Requirements

- [neovim >= 0.9.1](https://github.com/neovim/neovim/wiki/Installing-Neovim), other versions not tested
- optionally [telescope](https://github.com/nvim-telescope/telescope.nvim) plugin
- vim.ui plugins like [dressing.nvim](https://github.com/stevearc/dressing.nvim) are recommended to
  make selections and input better

## Install

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use 'aaron-p1/virt-notes.nvim'
```

## Setup

### Minimal

```lua
require('virt-notes').setup()
```

Note: This maps `<Leader>v…` for note manipulation.

### Default config

```lua
require('virt-notes').setup({
    -- directory to save notes at
    notes_path = vim.fn.stdpath("data") .. "/virt_notes",
    -- highlight group for notes
    hl_group = "WildMenu",
    -- schemes that are removed from buffer name
    remove_schemes = {"oil"},
    -- mappings can be set to false to disable all
    mappings = {
        -- "<prefix>" in keys will be replaced with this
        prefix = "<Leader>v",
        -- keys are keys for mapping
        -- opts are map opts from vim.keymap.set
        --
        -- Actions can be set to string: {add = "<Leader>na"}
        actions = {
            add = {keys = "<prefix>a", opts = {desc = "Add note"}},
            edit = {keys = "<prefix>e", opts = {desc = "Edit note"}},
            remove = {keys = "<prefix>dd", opts = {desc = "Delete note"}},
            remove_on_line = {keys = "<prefix>dl", opts = {desc = "Delete all notes on line"}},
            remove_in_file = {keys = "<prefix>da", opts = {desc = "Delete all notes in file"}},
            copy = {keys = "<prefix>c", opts = {desc = "Copy note"}},
            -- cut deletes note when pasting (note: not deleting when buffer is unloaded)
            cut = {keys = "<prefix>x", opts = {desc = "Cut note"}},
            paste = {keys = "<prefix>p", opts = {desc = "Paste note"}}
        }
    }
})
