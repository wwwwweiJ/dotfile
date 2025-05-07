return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" },
      },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      timeout = 1050,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local LazyVim = require("lazyvim.util")
      opts.sections.lualine_c[4] = {
        LazyVim.lualine.pretty_path({
          length = 0,
          relative = "cwd",
          modified_h1 = "MatchParen",
          directory_h1 = "",
          filename_h1 = "Bold",
          modified_sign = "",
          readonly_icon = "📚"
        })
      }
    end
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
██╗    ██╗███████╗██╗     ██╗    ██╗  ██╗███████╗██╗   ██╗
██║    ██║██╔════╝██║     ██║    ██║  ██║██╔════╝██║   ██║
██║ █╗ ██║█████╗  ██║     ██║    ███████║███████╗██║   ██║
██║███╗██║██╔══╝  ██║██   ██║    ██╔══██║╚════██║██║   ██║
╚███╔███╔╝███████╗██║╚█████╔╝    ██║  ██║███████║╚██████╔╝
 ╚══╝╚══╝ ╚══════╝╚═╝ ╚════╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ 
                                                          

      ]],
                }
            }
      }

  },
}
