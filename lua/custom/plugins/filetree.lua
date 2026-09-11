-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.g.neotree_auto_open = 1

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function ()
    require('neo-tree').setup {
      -- NOTE: this is the actual place for filesystem-source options
      -- (follow_current_file, filtered_items, etc.) - `follow_current_file`
      -- was previously nested under `default_component_configs.filesystem`,
      -- which isn't a real config path, so it silently did nothing.
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = {
          -- Show everything directly in the tree instead of collapsing
          -- items behind a "(N hidden items)" placeholder line.
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          hide_hidden = false, -- only affects Windows
        },
      },
      default_component_configs = {
        -- Classic NERDTree-style plain tree: no per-filetype icons (avoids
        -- depending on Nerd Font glyph coverage entirely), simple +/-
        -- folder markers instead of the nerd-font folder glyphs.
        icon = {
          folder_closed = "+",
          folder_open = "-",
          folder_empty = "+",
          folder_empty_open = "-",
          default = "",
          provider = function() end, -- skip the nvim-web-devicons lookup
        },
        git_status = {
          symbols = {
            -- Change type
            added     = "A",
            deleted   = "D",
            modified  = "M",
            renamed   = "R",
            -- Status type
            untracked = "?",
            ignored   = "!",
            unstaged  = "U",
            staged    = "S",
            conflict  = "C",
          },
          align = "right",
        },
      },
    }
  end,
}
