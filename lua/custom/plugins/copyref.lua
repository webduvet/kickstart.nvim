-- Visual-mode `zp`: copy "<path> L<start>:<end>" for the selected lines into
-- the clipboard and the unnamed (yank) register, for pasting into shell agents.
-- The path is relative to the cwd when possible (same as <C-g>), else absolute.
vim.keymap.set('x', 'zp', function()
  local a, b = vim.fn.line 'v', vim.fn.line '.'
  local first, last = math.min(a, b), math.max(a, b)
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':~:.')
  local ref = ('%s L%d:%d'):format(path, first, last)
  vim.fn.setreg('"', ref)
  vim.fn.setreg('+', ref)
  vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)
  vim.notify(ref)
end, { desc = 'Copy file path + line range' })

-- lazy.nvim imports every file in this folder as a plugin spec; no plugins here.
return {}
