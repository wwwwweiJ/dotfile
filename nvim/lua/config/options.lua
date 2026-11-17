local o = vim.opt

vim.scriptencoding = "utf-8"
o.encoding = "utf-8"
o.fileencoding = "utf-8"

-- UI
o.title = true
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.laststatus = 3
o.showmode = false
o.scrolloff = 10
o.sidescrolloff = 8
o.wrap = false
o.pumblend = 10
o.pumheight = 10
o.winborder = "rounded"
o.list = true
o.fillchars = { eob = " " }

-- Editing
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.shiftround = true
o.smartindent = true
o.autoindent = true
o.smarttab = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.undofile = true
o.undolevels = 10000
o.confirm = true
o.virtualedit = "block"

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "nosplit"
o.grepprg = "rg --vimgrep"
o.grepformat = "%f:%l:%c:%m"

-- Splits / timing
o.splitright = true
o.splitbelow = true
o.splitkeep = "cursor"
o.updatetime = 200
o.timeoutlen = 300

-- Folding (treesitter)
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
