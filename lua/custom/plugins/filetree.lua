-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.g.neotree_auto_open = 1

-- The editor window the buffers picker previews/opens into (set whenever we
-- enter/focus the picker; read by open_and_close and the live-preview
-- autocmd below). Module-local so both can share it.
local neotree_buffers_preview_win = nil

-- Finds a window to preview buffers into: the current one, unless it's
-- itself a neo-tree/fidget window (e.g. cursor was inside the file tree),
-- in which case the first "normal" window is used instead.
local function find_editor_window()
  local function is_editorish(win)
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    return ft ~= 'neo-tree' and ft ~= 'fidget'
  end
  local cur = vim.api.nvim_get_current_win()
  if is_editorish(cur) then
    return cur
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_editorish(win) then
      return win
    end
  end
  return cur
end

-- With `position = "current"`, neo-tree tracks state per-window
-- (state_by_win), not as the single tab-level state `manager.get_state()`
-- returns - so that's unreliable for "does this source's window already
-- exist" here. A direct scan is simpler and always correct.
local function find_neotree_window(source_name)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'neo-tree' and vim.b[buf].neo_tree_source == source_name then
      return win
    end
  end
  return nil
end

-- Renders `source_name` into the current window. `:split`/`:vsplit`
-- duplicate the current buffer into the new window, and neo-tree's
-- `position = "current"` handling special-cases "current buffer is
-- already neo-tree" by substituting that buffer's *original* stored
-- position instead - which would route this right back to the old
-- window. A plain scratch buffer avoids that special case.
local function render_neotree_source_in_current_win(source_name)
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
  require('neo-tree.command').execute { action = 'show', source = source_name, position = 'current' }
end

---@param source_name string
---@param open_fn fun() called only when the source's window doesn't exist yet
local function toggle_or_focus_neotree_source(source_name, open_fn)
  local win = find_neotree_window(source_name)
  if win then
    if vim.api.nvim_get_current_win() == win then
      vim.api.nvim_win_close(win, false)
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    open_fn()
  end
end

local function open_neotree_filesystem_stacked()
  local buffers_win = find_neotree_window 'buffers'
  if buffers_win then
    -- Stacking next to an existing window: this is the one case that
    -- actually needs position="current".
    vim.api.nvim_set_current_win(buffers_win)
    vim.cmd 'aboveleft split'
    render_neotree_source_in_current_win 'filesystem'
  else
    -- Plain standalone sidebar: use the normal position="left" path, which
    -- keeps neo-tree's built-in protection against files opening inside
    -- the tree window itself. (position="current" disables that
    -- protection - it's meant for transient/one-off placement, not a
    -- persistent sidebar - which caused files to open inside the tree.)
    require('neo-tree.command').execute { action = 'focus', source = 'filesystem', position = 'left' }
  end
  local win = find_neotree_window 'filesystem'
  if win then
    vim.api.nvim_set_current_win(win)
  end
end

local function open_neotree_buffers_stacked()
  local preview_target = find_editor_window()
  local fs_win = find_neotree_window 'filesystem'
  if fs_win then
    vim.api.nvim_set_current_win(fs_win)
    vim.cmd 'belowright split'
    render_neotree_source_in_current_win 'buffers'
  else
    -- Same reasoning as open_neotree_filesystem_stacked above. This one
    -- matters less in practice since the buffers source's own <cr> is
    -- fully overridden (open_and_close below) rather than relying on
    -- neo-tree's generic "find an appropriate window" logic, but there's
    -- no reason to give up the standard protection here either.
    require('neo-tree.command').execute { action = 'focus', source = 'buffers', position = 'left' }
  end
  local win = find_neotree_window 'buffers'
  if win then
    vim.api.nvim_set_current_win(win)
  end
  neotree_buffers_preview_win = preview_target
end

-- As you move the cursor through the buffers picker, live-switch the
-- editor window to whichever buffer is currently highlighted (no need to
-- press <cr> just to preview). Scoped to the buffers source only, so the
-- regular filesystem tree's navigation is unaffected.
vim.api.nvim_create_autocmd('CursorMoved', {
  group = vim.api.nvim_create_augroup('neotree-buffers-live-preview', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype ~= 'neo-tree' then
      return
    end
    if vim.b[args.buf].neo_tree_source ~= 'buffers' then
      return
    end
    if not neotree_buffers_preview_win or not vim.api.nvim_win_is_valid(neotree_buffers_preview_win) then
      return
    end
    -- `position = "current"` windows are tracked per-window
    -- (state_by_win), so this has to be looked up per-window too, not via
    -- the tab-level `manager.get_state('buffers')` singleton.
    local state = require('neo-tree.sources.manager').get_state_for_window(vim.api.nvim_get_current_win())
    local node = state and state.tree and state.tree:get_node()
    local bufnr = node and node.extra and node.extra.bufnr
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and bufnr ~= vim.api.nvim_win_get_buf(neotree_buffers_preview_win) then
      vim.api.nvim_win_set_buf(neotree_buffers_preview_win, bufnr)
    end
  end,
})

local function toggle_or_focus_neotree_buffers()
  toggle_or_focus_neotree_source('buffers', open_neotree_buffers_stacked)
end

vim.keymap.set('n', '<leader>n', function()
  toggle_or_focus_neotree_source('filesystem', open_neotree_filesystem_stacked)
end, { desc = 'Toggle file [N]eo-tree' })
vim.keymap.set('n', '<leader>b', toggle_or_focus_neotree_buffers, { desc = 'Toggle/focus [B]uffer picker (Neo-tree)' })
-- Same as <leader>b, just also reachable through the Buffer which-key group
-- (<leader>Bn/Bp/Bd, defined in init.lua).
vim.keymap.set('n', '<leader>Bb', toggle_or_focus_neotree_buffers, { desc = 'Pick [B]uffer (Neo-tree)' })

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
        commands = {
          -- neo-tree's file-open logic (utils.open_file) has a hard-coded
          -- special case: when state.current_position == "current" it
          -- skips window-picking entirely and opens the file right there
          -- - fine for one-off transient uses of position="current", but
          -- wrong for us, since we also use "current" to target a
          -- specific split when this tree is *stacked* with the buffer
          -- picker (see open_neotree_filesystem_stacked above). That made
          -- files open inside the tree itself instead of the editor.
          -- Presenting a different position value just for the duration
          -- of the open call makes it take the normal (correct,
          -- window-cycling) path instead, without losing any of
          -- open_file's other handling (events, relative paths, etc.).
          open_in_editor = function(state)
            local original_position = state.current_position
            state.current_position = 'left'
            local ok, err = pcall(require('neo-tree.sources.common.commands').open, state)
            state.current_position = original_position
            if not ok then
              error(err)
            end
          end,
        },
        window = {
          mappings = {
            ['<cr>'] = 'open_in_editor',
          },
        },
      },
      -- Picking a buffer should open it and dismiss the picker in one step,
      -- rather than leaving the picker open (only affects the buffers
      -- source's <cr>; the regular filesystem tree's <cr> is untouched).
      buffers = {
        commands = {
          open_and_close = function(state)
            -- Not `commands.common.open(state)`: its target-window
            -- heuristic (get_appropriate_window) gets confused when the
            -- filesystem tree is *also* open as a second neo-tree window,
            -- and can pick the wrong window to open into. We already know
            -- the right window (the live-preview target, kept in sync as
            -- the cursor moves), so just open the highlighted buffer there
            -- directly and close the picker.
            local node = state.tree and state.tree:get_node()
            local bufnr = node and node.extra and node.extra.bufnr
            if
              bufnr
              and vim.api.nvim_buf_is_valid(bufnr)
              and neotree_buffers_preview_win
              and vim.api.nvim_win_is_valid(neotree_buffers_preview_win)
            then
              vim.api.nvim_win_set_buf(neotree_buffers_preview_win, bufnr)
            end
            if state.winid and vim.api.nvim_win_is_valid(state.winid) then
              vim.api.nvim_win_close(state.winid, false)
            end
            -- Land in the editor with the picked buffer, not on whatever
            -- window happened to be next in line after closing the picker
            -- (e.g. the filesystem tree, if it's also open).
            if neotree_buffers_preview_win and vim.api.nvim_win_is_valid(neotree_buffers_preview_win) then
              vim.api.nvim_set_current_win(neotree_buffers_preview_win)
            end
          end,
        },
        window = {
          mappings = {
            ['<cr>'] = 'open_and_close',
          },
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
