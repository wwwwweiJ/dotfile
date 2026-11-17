-- Core keymaps (no plugin needed). Plugin keymaps live next to their plugin spec.
-- Cheat sheet: <leader>? (HTML in browser) or ;k (telescope search)
local map = vim.keymap.set
local yank = require("config.yank")

-- Save / quit ---------------------------------------------------------------
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Registers: x never clobbers your clipboard, <leader>p pastes last yank --------
map({ "n", "x" }, "x", '"_x', { desc = "Delete char (no yank)" })
map({ "n", "x" }, "<leader>p", '"0p', { desc = "Paste last yank" })
map({ "n", "x" }, "<leader>P", '"0P', { desc = "Paste last yank (before)" })

-- Yank paths (paste into agents) -------------------------------------------
map("n", "<C-p>", yank.relative, { desc = "Copy relative path" })
map("n", "<leader>yy", yank.relative, { desc = "Relative path" })
map("n", "<leader>yf", yank.relative_line, { desc = "Relative path#Lline" })
map("n", "<leader>yp", yank.absolute_line, { desc = "Absolute path#Lline" })
map("x", "<leader>yc", yank.codeblock, { desc = "Selection as code block" })

-- Movement ------------------------------------------------------------------
map("n", "fg", "$", { desc = "End of line" })
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })
map("x", "<", "<gv")
map("x", ">", ">gv")
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch" })

-- Windows -------------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Taller" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Wider" })

-- Buffers (scoped to the current tab) ----------------------------------------
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Diagnostics ---------------------------------------------------------------
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]e", function() vim.diagnostic.jump({ count = 1, float = true, severity = "ERROR" }) end, { desc = "Next error" })
map("n", "[e", function() vim.diagnostic.jump({ count = -1, float = true, severity = "ERROR" }) end, { desc = "Prev error" })

-- Tools ---------------------------------------------------------------------
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy (plugins)" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason (tools)" })

-- Cheat sheet (HTML, generated from live keymaps) ------------------------------
map("n", "<leader>?", function() require("config.cheatsheet").open() end, { desc = "Keymap cheat sheet (browser)" })
vim.api.nvim_create_user_command("Keymaps", function() require("config.cheatsheet").open() end, {})

-- Worktree workspaces (Orca-compatible: ~/orca/workspaces/<repo>/<name>) ----------
map("n", "<leader>gw", function() require("config.worktree").pick() end, { desc = "Worktrees" })
map("n", "<leader>gW", function() require("config.worktree").create() end, { desc = "New worktree (+ tab + agent)" })
