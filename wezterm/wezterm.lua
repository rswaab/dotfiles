local wezterm = require 'wezterm'

return {
  enable_wayland = false,
  enable_tab_bar = true,
  use_fancy_tab_bar = false,

  -- Clipboard behavior
  enable_kitty_keyboard = false,
  selection_word_boundary = " \t\n{}[]()\"'`,;:",

  -- Make sure copy/paste use system clipboard
  mouse_bindings = {
    -- Right-click paste
    {
      event = { Down = { streak = 1, button = "Right" } },
      mods = "NONE",
      action = wezterm.action.PasteFrom "Clipboard",
    },
  },
}
