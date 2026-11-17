-- Frosted-glass popups:
--   Ghostty has `background-opacity-cells = true`, so cells WITH a background colour
--   are also drawn at background-opacity (0.66) + blur.
--   Floats get a tint slightly lighter than the editor, so they read as a separate
--   pane of frosted glass while the wallpaper still shows through.
local frost = "#2b3a46" -- popup tint: lighter = more contrast, darker = more see-through feel

return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = { floats = "dark", sidebars = "transparent" },
      on_colors = function(c)
        c.bg_float = frost
      end,
      on_highlights = function(hl, c)
        hl.TelescopeBorder = { fg = c.base01, bg = frost }
        hl.TelescopeTitle = { fg = c.yellow500, bg = frost, bold = true }
        hl.TelescopeSelection = { bg = "#3b4f5e", bold = true }
        hl.FloatBorder = { fg = c.base01, bg = frost }
      end,
    },
    config = function(_, opts)
      require("solarized-osaka").setup(opts)
      vim.cmd.colorscheme("solarized-osaka")
    end,
  },
}
