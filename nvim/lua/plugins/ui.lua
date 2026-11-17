return {
  { "nvim-mini/mini.icons", lazy = true, opts = {}, init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end },

  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      lazygit = { enabled = true, configure = true }, -- theme follows nvim; `e` opens files in this nvim
      notifier = { enabled = true, timeout = 1050 },
      input = { enabled = true },
      indent = { enabled = true },
      words = { enabled = true },
      dashboard = {
        preset = {
          header = [[
██╗    ██╗███████╗██╗     ██╗    ██╗  ██╗███████╗██╗   ██╗
██║    ██║██╔════╝██║     ██║    ██║  ██║██╔════╝██║   ██║
██║ █╗ ██║█████╗  ██║     ██║    ███████║███████╗██║   ██║
██║███╗██║██╔══╝  ██║██   ██║    ██╔══██║╚════██║██║   ██║
╚███╔███╔╝███████╗██║╚█████╔╝    ██║  ██║███████║╚██████╔╝
 ╚══╝╚══╝ ╚══════╝╚═╝ ╚════╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files hidden=true" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "c", desc = "Config", action = ":lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log_file() end, desc = "Lazygit file history" },
      { ";n", function() Snacks.notifier.show_history() end, desc = "Notifications" },
      { "<C-/>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Terminal" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- <leader>u = UI toggles (which-key shows on/off state)
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("relativenumber", { name = "Relative number" }):map("<leader>ul")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.zen():map("<leader>uz")
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto", globalstatus = true, component_separators = "", section_separators = "" },
      sections = {
        lualine_c = { { "filename", path = 1, symbols = { modified = "", readonly = "📚" } } },
        lualine_x = { "diagnostics", "filetype" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      -- centered floating panel, wide enough to lay keys out in 2-3 columns
      win = {
        no_overlap = false, -- stay centered even if it covers the cursor
        width = 0.55,
        height = { min = 0.6, max = 0.85 }, -- 60%~85% of the screen height
        col = 0.5,
        row = 0.5,
        border = "rounded",
        padding = { 1, 3 },
        title = true,
        title_pos = "center",
      },
      layout = { width = { min = 38 }, spacing = 4 },
      spec = {
        { "<leader>a", group = "agents" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diff" },
        { "<leader>f", group = "file" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quit" },
        { "<leader>s", group = "search/replace" },
        { "<leader>u", group = "toggle" },
        { "<leader>w", group = "window" },
        { "<leader>y", group = "yank path" },
        { ";", group = "pickers" },
        { "<leader>1", hidden = true }, { "<leader>2", hidden = true }, { "<leader>3", hidden = true },
        { "<leader>4", hidden = true }, { "<leader>5", hidden = true }, { "<leader>6", hidden = true },
        { "<leader>7", hidden = true }, { "<leader>8", hidden = true }, { "<leader>9", hidden = true },
      },
    },
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = { plugins = { gitsigns = true, tmux = true, kitty = { enabled = false, font = "+2" } } },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" } },
  },

  { "ukyouz/syntax-highlighted-cursor.nvim", event = "VeryLazy", opts = {} },

  -- File name floating at the top-right of every window (handy with splits + agent pane)
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {
      window = { margin = { vertical = 0, horizontal = 1 }, zindex = 10 },
      hide = { cursorline = "smart", only_win = true },
      ignore = { buftypes = { "terminal", "nofile", "prompt" } },
      render = function(props)
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if name == "" then name = "[No Name]" end
        local icon, hl = require("mini.icons").get("file", name)
        local mod = vim.bo[props.buf].modified and " ●" or ""
        return { { icon, group = hl }, " ", { name, gui = props.focused and "bold" or "none" }, mod }
      end,
    },
  },
}
