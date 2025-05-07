return {
  {
    -- "catppuccin/nvim",
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    -- name = "catppuccin",
    -- flavour = "mocha",
    priority = 1000,
    -- opts = {
      -- transparent_background = true,
      -- highlight_overrides = {
        -- all = function(colors)
          -- return {
          -- }
        -- end,
      -- },
    -- },
    opts = function()
      return {
        transparent = true,
      }
    end
  },
}
