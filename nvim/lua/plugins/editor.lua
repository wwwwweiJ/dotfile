local tb = function(name, opts)
  return function() require("telescope.builtin")[name](opts or {}) end
end

return {
  ---------------------------------------------------------------------------
  -- Telescope  ( ; = quick pickers )
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    event = "VeryLazy", -- so vim.ui.select uses telescope
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { ";f", tb("find_files", { hidden = true }), desc = "Files" },
      { "<leader><space>", tb("find_files", { hidden = true }), desc = "Files" },
      { ";r", tb("live_grep"), desc = "Grep" },
      { "<leader>/", tb("live_grep"), desc = "Grep" },
      { ";w", tb("grep_string"), mode = { "n", "x" }, desc = "Grep word / selection" },
      { "\\\\", function() require("config.tabs").buffers() end, desc = "Buffers (all tabs)" },
      { ";o", tb("oldfiles", { only_cwd = true }), desc = "Recent files" },
      { ";;", tb("resume"), desc = "Resume picker" },
      { ";e", tb("diagnostics"), desc = "Diagnostics" },
      { ";s", tb("lsp_document_symbols"), desc = "Symbols (LSP)" },
      { ";S", tb("treesitter"), desc = "Symbols (treesitter)" },
      { ";c", tb("lsp_incoming_calls"), desc = "Incoming calls" },
      { ";g", tb("git_status"), desc = "Git changed files" },
      { ";t", tb("help_tags"), desc = "Help" },
      { ";k", tb("keymaps"), desc = "Keymaps" },
      { ";h", tb("highlights"), desc = "Highlights" },
      { "<leader>fc", tb("find_files", { cwd = vim.fn.stdpath("config") }), desc = "Config files" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          wrap_results = true,
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          winblend = 0, -- transparency comes from the colorscheme + Ghostty
        },
        pickers = {
          diagnostics = { theme = "ivy", initial_mode = "normal", layout_config = { preview_cutoff = 9999 } },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  ---------------------------------------------------------------------------
  -- File explorers:  sf = oil (edit dirs like text)   <leader>e = mini.files (columns)
  ---------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    lazy = false, -- replaces netrw for `nvim .`
    keys = {
      { "sf", function() require("oil").open_float(nil, { preview = {} }) end, desc = "Oil (file dir)" },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        { "permissions", highlight = "Type" },
        { "size", highlight = "String" },
        { "mtime", highlight = "Keyword" },
      },
      keymaps = {
        ["h"] = { "actions.parent", mode = "n" },
        ["l"] = { "actions.select", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
      },
      view_options = { show_hidden = true },
      float = { border = "rounded", max_width = 200 },
      preview_win = { update_on_cursor_moved = true },
      -- renames/moves tell the LSP so imports get updated
      lsp_file_methods = { enabled = true, timeout_ms = 1000, autosave_changes = true },
    },
  },

  {
    "nvim-mini/mini.files",
    keys = {
      { "<leader>e", function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end, desc = "Explorer (file dir)" },
      { "<leader>E", function() require("mini.files").open(vim.uv.cwd(), true) end, desc = "Explorer (cwd)" },
    },
    opts = { windows = { preview = true, width_preview = 50 } },
  },

  ---------------------------------------------------------------------------
  -- Motion / search & replace
  ---------------------------------------------------------------------------
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    name = "leap.nvim",
    keys = {
      { "s", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "Leap forward" },
      { "S", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "Leap backward" },
      { "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "Leap from window" },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80 },
    keys = {
      { "<S-f>", function() require("grug-far").open() end, desc = "Search & replace" },
      { "<leader>sr", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Replace word" },
      { "<leader>sf", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end, desc = "Replace in file" },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { ";T", "<cmd>TodoTelescope<cr>", desc = "TODOs" },
    },
  },

  ---------------------------------------------------------------------------
  -- Git  ( <leader>g = git, <leader>d = diff )
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d %H:%M:%S> - <summary>",
      current_line_blame_opts = { virt_text_pos = "eol", delay = 500 },
      on_attach = function(buf) require("config.buffer_keys").attach("git", buf) end,
    },
  },

  {
    "dinhhuy258/git.nvim",
    keys = {
      { "<leader>gb", function() require("git.blame").blame() end, desc = "Blame window" },
      { "<leader>go", function() require("git.browse").open(false) end, desc = "Open in browser" },
      { "<leader>go", function() require("git.browse").open(true) end, mode = "x", desc = "Open lines in browser" },
    },
    opts = { default_mappings = false },
  },

  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>dv", "<cmd>CodeDiff<cr>", desc = "Review changes (CodeDiff)" },
      { "<leader>dh", "<cmd>CodeDiff history %<cr>", desc = "File history" },
      { "<leader>dH", "<cmd>CodeDiff history<cr>", desc = "Repo history" },
    },
    opts = {
      explorer = { width = 50, view_mode = "tree", line_stats = { enabled = true } },
      diff = { compact = true, compact_context_lines = 8 },
    },
  },

  ---------------------------------------------------------------------------
  -- Small editing helpers
  ---------------------------------------------------------------------------
  {
    "nvim-mini/mini.hipatterns",
    event = "BufReadPre",
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color(),
          hsl_color = {
            pattern = "hsl%(%d+,? %d+,? %d+%)",
            group = function(_, match)
              local h, s, l = match:match("hsl%((%d+),? (%d+),? (%d+)%)")
              local hex = require("solarized-osaka.hsl").hslToHex(tonumber(h), tonumber(s), tonumber(l))
              return hi.compute_hex_color_group(hex, "bg")
            end,
          },
        },
      }
    end,
  },

  {
    "nvim-mini/mini.bracketed",
    event = "BufReadPost",
    opts = {
      file = { suffix = "" },
      window = { suffix = "" },
      quickfix = { suffix = "" },
      yank = { suffix = "" },
      treesitter = { suffix = "n" },
    },
  },

  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "let", "const" } }),
        },
      })
    end,
  },

  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = { add = "gsa", delete = "gsd", replace = "gsr", find = "", find_left = "", highlight = "", update_n_lines = "" },
    },
  },
}
