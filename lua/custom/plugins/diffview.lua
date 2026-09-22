return {
  -- Branch/commit overview: file panel on the left, side-by-side diff on the right.
  -- Unlike `:Git difftool`, it's a single tab that closes in one go.
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gv',
      function()
        vim.ui.input({ prompt = 'Diff against: ', default = 'master...HEAD' }, function(rev)
          if rev and rev ~= '' then
            vim.cmd('DiffviewOpen ' .. rev)
          end
        end)
      end,
      desc = 'Diff[V]iew vs branch',
    },
    { '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [H]istory' },
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Diffview [Q]uit' },
  },
  opts = {},
}
