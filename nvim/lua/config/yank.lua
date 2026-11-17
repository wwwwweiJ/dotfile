-- Copy file locations / code to the system clipboard (great for pasting into agents)
local M = {}

local function put(text, msg)
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. (msg or text))
end

local function rel() return vim.fn.expand("%:.") end

function M.relative() put(rel()) end
function M.relative_line() put(rel() .. "#L" .. vim.fn.line(".")) end
function M.absolute_line() put(vim.fn.expand("%:p") .. "#L" .. vim.fn.line(".")) end

-- Visual selection -> ```ruby filename="app/models/user.rb" lines=10-20
function M.codeblock()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  if s > e then s, e = e, s end
  vim.cmd("normal! \27") -- leave visual mode
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  local lang = ({ typescriptreact = "tsx", javascriptreact = "jsx", typescript = "ts", javascript = "js" })[vim.bo.filetype]
    or vim.bo.filetype
  local range = s == e and tostring(s) or (s .. "-" .. e)
  put(("```%s filename=%q lines=%s\n%s\n```"):format(lang, rel(), range, table.concat(lines, "\n")), #lines .. " lines as code block")
end

return M
