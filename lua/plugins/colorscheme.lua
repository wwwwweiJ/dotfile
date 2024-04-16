return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    flavour = "mocha",
    opts = {
      transparent_background = true,
      highlight_overrides = {
        all = function(colors)
          return {
          }
        end,
      },
    },
  },
}
