-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", opts)

-- copy file path
keymap.set("n", "<C-p>", "<cmd>let @* = expand('%')<cr><esc>")

keymap.set("n", "<tab>", ":tabnext<Return>")
keymap.set("n", "fg", "$", opts)
keymap.set("n", "<S-f>", "<cmd>Spectre<cr>", opts)
