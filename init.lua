--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

vim.keymap.set('n', 'J', '<c-d>')
vim.keymap.set('n', 'K', '<c-u>')

-- <leader>n/<leader>b (Neo-tree tree/buffer-picker), <leader>B/<leader>g/
-- <leader>f/<leader>l which-key groups: all set up further down, once
-- telescope/gitsigns/which-key are configured.

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  -- 'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      -- (successor to the now-archived folke/neodev.nvim)
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    },
  },

  {
    -- Autocompletion (successor to nvim-cmp; built-in snippet engine, no LuaSnip needed)
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = {
        preset = 'default',
        -- match the <C-j>/<C-k> selection style used in Telescope
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        -- accept the highlighted suggestion with Tab; falls through to
        -- snippet-jump / a literal tab when no completion menu is open
        ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = false } },
      -- auto-popup parameter hints while typing inside a function call
      signature = { enabled = true },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      -- cmdline completion (e.g. `:colorscheme <Tab>`) uses its own keymap
      -- preset, separate from the one above: without this, <C-j>/<C-k>
      -- fall through to Vim's built-ins in cmdline mode (<C-j> = <CR>,
      -- <C-k> = digraph entry) instead of cycling suggestions
      cmdline = {
        keymap = {
          preset = 'cmdline',
          ['<C-j>'] = { 'select_next', 'fallback' },
          ['<C-k>'] = { 'select_prev', 'fallback' },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        vim.keymap.set('n', '[c', function() gs.nav_hunk 'prev' end, { buffer = bufnr, desc = 'Go to Previous Hunk' })
        vim.keymap.set('n', ']c', function() gs.nav_hunk 'next' end, { buffer = bufnr, desc = 'Go to Next Hunk' })
        vim.keymap.set('n', '<leader>gh', gs.preview_hunk, { buffer = bufnr, desc = '[H]unk preview' })
        vim.keymap.set('n', '<leader>gb', gs.blame_line, { buffer = bufnr, desc = '[B]lame line' })
        vim.keymap.set('n', '<leader>gd', gs.diffthis, { buffer = bufnr, desc = '[D]iff against index' })
      end,
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- v3 renamed the module to `ibl`; opts are passed straight to `ibl.setup()`
    main = 'ibl',
    opts = {
      indent = { char = '┊' },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  -- NOTE: '0.1.x' is the old release branch and is no longer maintained
  -- (https://github.com/nvim-telescope/telescope.nvim/issues/3487); 'master'
  -- is the actively developed branch despite what telescope's README says.
  { 'nvim-telescope/telescope.nvim', branch = 'master', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    -- NOTE: 'master' is no longer maintained upstream; 'main' is the
    -- actively developed branch (different config API, see setup below).
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

-- retrobox is built into Neovim, no plugin needed
vim.cmd.colorscheme 'retrobox'

-- Force a highly-visible, fixed cursor color. Left unset, Neovim derives
-- the terminal cursor color from Normal's fg, which some themes (onedark
-- included) also reuse as TabLineSel's background -- making the cursor
-- disappear whenever it lands on/near that highlight. Re-applied on every
-- ColorScheme event so it survives manual `:colorscheme` switches too.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('custom-cursor-visibility', { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, 'Cursor', { bg = '#e5c07b', fg = '#282c34' })
    vim.api.nvim_set_hl(0, 'lCursor', { link = 'Cursor' })
  end,
})
vim.api.nvim_exec_autocmds('ColorScheme', {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Always highlight the current line (no fade-in/out on idle, unlike
-- nvim-cursorline's own line-highlight feature, which is disabled)
vim.o.cursorline = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local telescope_actions = require 'telescope.actions'
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-j>'] = telescope_actions.move_selection_next,
        ['<C-k>'] = telescope_actions.move_selection_previous,
      },
    },
  },
}

-- bufferline and lualine are already configured via their lazy.nvim `opts`
-- in lua/custom/plugins/bufferline.lua and lualine.lua

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- [[ <leader>f : Find (Telescope) ]]
-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Word Under Cursor' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>f/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzily Search In Buffer' })

-- [[ <leader>g : Git ]]
vim.keymap.set('n', '<leader>gs', ':Git<cr>', { desc = '[S]tatus (Fugitive)' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git [F]iles' })
-- gb/gd/gh (blame/diff/hunk-preview) are buffer-local, set up in gitsigns' on_attach above

-- <leader>n / <leader>b (Neo-tree filesystem tree / buffer picker, as two
-- independent stacked-left-column windows, with live buffer preview) are
-- defined in lua/custom/plugins/filetree.lua, alongside the rest of the
-- Neo-tree setup they depend on. <leader>Bb below is the same as <leader>b.

-- [[ <leader>B : Buffer ]]
vim.keymap.set('n', '<leader>Bn', ':bnext<cr>', { desc = '[N]ext buffer' })
vim.keymap.set('n', '<leader>Bp', ':bprevious<cr>', { desc = '[P]revious buffer' })
vim.keymap.set('n', '<leader>Bd', ':bdelete<cr>', { desc = '[D]elete buffer' })

-- Quick standalone close, same action as <leader>Bd.
vim.keymap.set('n', '<leader>q', ':bdelete<cr>', { desc = 'Close buffer' })

-- Label the leader groups so which-key's popup shows names instead of raw keys
require('which-key').add {
  { '<leader>f', group = 'Find' },
  { '<leader>g', group = 'Git' },
  { '<leader>B', group = 'Buffer' },
  { '<leader>l', group = 'LSP' },
}

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`. The 'master' branch is unmaintained upstream
-- (https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/876)
-- so this is on 'main', which has a very different, less monolithic API:
-- no more `.configs.setup{ ensure_installed, highlight, indent, ... }`.
--
-- NOTE: the old `incremental_selection` module (<c-space> to expand
-- selection, <M-space> to shrink, <c-s> for scope) was dropped upstream in
-- this rewrite with no direct replacement; it's simply gone for now.
local ts_langs = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' }
require('nvim-treesitter').install(ts_langs)

vim.api.nvim_create_autocmd('FileType', {
  pattern = ts_langs,
  callback = function(args)
    -- Highlighting/indent used to come from `.configs.setup()`; now enabled
    -- per-filetype instead. Treesitter indent for Python was excluded
    -- before too (its indentation is historically unreliable).
    pcall(vim.treesitter.start)
    if args.match ~= 'python' then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer'] = 'V',
      ['@class.outer'] = 'V',
    },
  },
  move = { set_jumps = true },
}

-- You can use the capture groups defined in textobjects.scm
local ts_select = require 'nvim-treesitter-textobjects.select'
vim.keymap.set({ 'x', 'o' }, 'aa', function() ts_select.select_textobject('@parameter.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ia', function() ts_select.select_textobject('@parameter.inner', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner', 'textobjects') end)

local ts_move = require 'nvim-treesitter-textobjects.move'
vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() ts_move.goto_next_start('@function.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() ts_move.goto_next_start('@class.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() ts_move.goto_next_end('@function.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function() ts_move.goto_next_end('@class.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() ts_move.goto_previous_start('@function.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() ts_move.goto_previous_start('@class.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() ts_move.goto_previous_end('@function.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() ts_move.goto_previous_end('@class.outer', 'textobjects') end)

-- (parameter swap dropped: unused; <leader>a is now hover docs, see LspAttach below)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end, { desc = 'Go to next diagnostic message' })
-- [[ Configure LSP ]]
--  This autocommand runs when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end

    -- [[ <leader>l : LSP ]]
    nmap('<leader>lh', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>lv', '<cmd>DocsViewToggle<cr>', 'Toggle Docs View (side panel)')
    nmap('<leader>ls', vim.lsp.buf.signature_help, 'Signature Help')
    nmap('<leader>lr', vim.lsp.buf.rename, 'Rename')
    nmap('<leader>la', vim.lsp.buf.code_action, 'Code Action')
    nmap('<leader>lt', vim.lsp.buf.type_definition, 'Type Definition')
    nmap('<leader>ld', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
    nmap('<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
    nmap('<leader>le', vim.diagnostic.open_float, 'Diagnostics (float)')
    nmap('<leader>lq', vim.diagnostic.setloclist, 'Diagnostics (list)')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(event.buf, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  `vim.lsp.config()`. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- rust_analyzer = {},
  gopls = {},
  pyright = {},
  ts_ls = {},

  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

-- blink.cmp supports additional completion capabilities, so broadcast that to all servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

for server_name, server_config in pairs(servers) do
  vim.lsp.config(server_name, server_config)
end

-- Ensure the servers above are installed, then enable them via `vim.lsp.enable()`
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  -- Only auto-enable servers we've configured above; other Mason-installed
  -- packages (formatters registered as pseudo-LSPs, servers from other
  -- projects, etc.) are left alone rather than started for every buffer.
  automatic_enable = vim.tbl_keys(servers),
}

vim.keymap.set('n', '<C-J>', '<C-W><C-J>')
vim.keymap.set('n', '<C-K>', '<C-W><C-K>')
vim.keymap.set('n', '<C-L>', '<C-W><C-L>')
vim.keymap.set('n', '<C-H>', '<C-W><C-H>')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
