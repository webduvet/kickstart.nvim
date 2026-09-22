-- Database client (Postgres, MySQL, SQLite, ...) with SSH-tunneled
-- connections. vim-dadbod-ssh rewrites a `ssh://host:postgresql://...` URL
-- into a local `ssh -L` tunnel + a `postgresql://...@127.0.0.1:PORT/...`
-- URL before handing it to dadbod, so tunneling is transparent to the UI.
--
-- Add your own connections in `vim.g.dbs` below, or save them interactively
-- from DBUI (they persist to `db_ui_save_location`). SSH connection string
-- shape: 'ssh://ssh-host-or-alias:postgresql://user:pass@db-host/db_name'
-- (the ssh host can be a plain `~/.ssh/config` alias).
vim.g.db_ui_save_location = vim.fn.stdpath 'config' .. '/db_ui_queries'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1

return {
  'kristijanhusak/vim-dadbod-ui',
  lazy = true,
  cmd = { 'DB', 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  init = function()
    -- vim.g.dbs = {
    --   mydb = 'ssh://mybastion:postgresql://user:password@127.0.0.1/mydb',
    -- }
  end,
  dependencies = {
    'tpope/vim-dadbod',
    'pbogut/vim-dadbod-ssh',
  },
  config = function()
    vim.keymap.set('n', '<leader>Du', ':DBUIToggle<cr>', { desc = '[U]I toggle' })
    vim.keymap.set('n', '<leader>Df', ':DBUIFindBuffer<cr>', { desc = '[F]ind buffer' })
    vim.keymap.set('n', '<leader>Da', ':DBUIAddConnection<cr>', { desc = '[A]dd connection' })

    require('which-key').add {
      { '<leader>D', group = 'Database' },
    }
  end,
}
