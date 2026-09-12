-- Persistent side-panel for LSP hover docs (`:DocsViewToggle`), instead of
-- the transient popup from `vim.lsp.buf.hover()`. See <leader>lv.
return {
  'amrbashir/nvim-docs-view',
  lazy = true,
  cmd = 'DocsViewToggle',
  opts = {
    position = 'right',
    width = 60,
  },
}
