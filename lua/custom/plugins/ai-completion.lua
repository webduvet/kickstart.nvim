-- All three AI code-suggestion backends are always installed, but only one
-- is ever loaded, chosen by the NVIM_AI_COMPLETION environment variable
-- (set it in your shell profile -- different per machine, e.g. 'copilot' on
-- a work laptop tied to a company subscription, 'supermaven' or 'minuet'
-- elsewhere). Defaults to 'copilot' if unset. Restart Neovim to switch.
--
-- `cond` (not `enabled`) gates each plugin: lazy.nvim keeps a plugin
-- installed on disk when its `cond` is false, it just skips loading it --
-- so switching providers never needs a re-clone, only a restart.
local provider = (os.getenv 'NVIM_AI_COMPLETION' or 'copilot'):lower()

local function is(name) return provider == name end

return {
  -- GitHub Copilot -- requires `:Copilot auth` with a Copilot subscription
  {
    'zbirenbaum/copilot.lua',
    cond = is 'copilot',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      -- blink-cmp-copilot surfaces suggestions through blink.cmp's own
      -- popup; copilot.lua's built-in suggestion/panel UI would otherwise
      -- fight it for the same completions
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  { 'giuxtaposition/blink-cmp-copilot', cond = is 'copilot' },

  -- Supermaven -- separate account from Copilot, own free tier
  {
    'supermaven-inc/supermaven-nvim',
    cond = is 'supermaven',
    opts = {
      disable_inline_completion = true, -- let blink.cmp show suggestions instead
      disable_keymaps = true, -- let blink.cmp's own keymaps drive accept/cycle
      log_level = 'off', -- silence the "nvim-cmp not available" notice; we use blink.cmp
    },
  },
  { 'huijiro/blink-cmp-supermaven', cond = is 'supermaven' },

  -- Minuet + Codestral -- bring-your-own-key via Mistral's fill-in-the-middle
  -- endpoint (export CODESTRAL_API_KEY). Runs as its own ghost-text overlay
  -- (like Copilot's classic UX) rather than a blink.cmp popup item -- separate
  -- UI layer, so it doesn't touch blink.cmp's sources/config at all.
  {
    'milanglacier/minuet-ai.nvim',
    cond = is 'minuet',
    opts = {
      provider = 'codestral',
      virtualtext = {
        auto_trigger_ft = { '*' }, -- ghost text on every filetype, no manual invoke needed
        -- minuet ships with every keymap unset by default (no accept/dismiss
        -- binding at all) despite the README's example implying otherwise
        keymap = {
          accept = '<A-A>', -- accept the whole suggestion
          accept_line = '<A-a>', -- accept just the next line
          next = '<A-]>',
          prev = '<A-[>',
          dismiss = '<A-e>',
        },
      },
    },
  },

  {
    'saghen/blink.cmp',
    opts = is 'copilot' and {
      sources = {
        default = { 'copilot' },
        providers = {
          copilot = { name = 'copilot', module = 'blink-cmp-copilot', score_offset = 100, async = true },
        },
      },
    } or is 'supermaven' and {
      sources = {
        default = { 'supermaven' },
        providers = {
          supermaven = { name = 'supermaven', module = 'blink-cmp-supermaven', score_offset = 100, async = true },
        },
      },
    } or {},
    -- minuet runs its own virtual-text overlay when active, independent of
    -- blink.cmp -- nothing to wire up here for it
  },
}
