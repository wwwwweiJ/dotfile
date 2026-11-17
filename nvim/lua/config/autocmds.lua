local group = vim.api.nvim_create_augroup("user", { clear = true })
local au = function(ev, o) o.group = group; vim.api.nvim_create_autocmd(ev, o) end

-- Highlight on yank
au("TextYankPost", { callback = function() vim.hl.on_yank() end })

-- Reload file if changed outside
au({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

-- Equalize splits on resize
au("VimResized", { command = "tabdo wincmd =" })

-- Restore last cursor position
au("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close helper windows with q
au("FileType", {
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "notify", "grug-far" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Wrap + spell for prose
au("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function() vim.opt_local.wrap = true; vim.opt_local.spell = true end,
})

-- MDX
vim.filetype.add({ extension = { mdx = "mdx" } })
vim.treesitter.language.register("markdown", "mdx")

-- Cursorline only in the focused window (easy to see focus with many splits)
au({ "VimEnter", "WinEnter", "BufWinEnter" }, { callback = function() vim.wo.cursorline = true end })
au("WinLeave", { callback = function() vim.wo.cursorline = false end })
