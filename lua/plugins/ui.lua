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
      timeout = 500,
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
        
██╗    ██╗███████╗██╗     ██╗    ██╗  ██╗███████╗██╗   ██╗
██║    ██║██╔════╝██║     ██║    ██║  ██║██╔════╝██║   ██║
██║ █╗ ██║█████╗  ██║     ██║    ███████║███████╗██║   ██║
██║███╗██║██╔══╝  ██║██   ██║    ██╔══██║╚════██║██║   ██║
╚███╔███╔╝███████╗██║╚█████╔╝    ██║  ██║███████║╚██████╔╝
 ╚══╝╚══╝ ╚══════╝╚═╝ ╚════╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ 
                                                          

      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
