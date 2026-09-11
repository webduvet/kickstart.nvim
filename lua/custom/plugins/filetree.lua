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
      default_component_configs = {
        filesystem = {
          follow_current_file = true
        },
        git_status = {
          symbols = {
            -- Change type
            added     = "✚", -- NOTE: you can set any of these to an empty string to not show them
            deleted   = "✖",
            modified  = "",
            renamed   = "r",
            -- Status type
            untracked = "?",
            ignored   = "i",
            unstaged  = "u",
            staged    = "",
            conflict  = "E",
          },
          align = "right",
        },
      },
    }
  end,
}
