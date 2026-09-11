-- this highlights the word under cursor across the buffer
return {
  'yamatsum/nvim-cursorline',
  config = function ()
    require('nvim-cursorline').setup {
      -- The line highlight itself is handled by native 'cursorline' (see
      -- init.lua) so it's always on, not just after an idle timeout.
      cursorline = {
        enable = false,
      },
      cursorword = {
        enable = true,
        min_length = 5,
        hl = { underline = true },
      }
    }
  end,
}
