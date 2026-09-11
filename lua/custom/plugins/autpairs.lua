-- File: lua/custom/plugins/autopairs.lua

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup {}
  end,
}
