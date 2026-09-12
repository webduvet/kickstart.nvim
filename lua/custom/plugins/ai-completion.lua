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

  -- Minuet + Codestral -- bring-your-own-key via Mistral's low-latency
  -- fill-in-the-middle endpoint (export CODESTRAL_API_KEY)
  {
    'milanglacier/minuet-ai.nvim',
    cond = is 'minuet',
    opts = { provider = 'codestral' },
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
    } or is 'minuet' and {
      sources = {
        default = { 'minuet' },
        providers = {
          minuet = { name = 'minuet', module = 'minuet.blink', async = true, timeout_ms = 3000, score_offset = 50 },
        },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    } or {},
  },
}
