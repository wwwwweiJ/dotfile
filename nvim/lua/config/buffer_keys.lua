-- Buffer-local keymaps that only exist once LSP / gitsigns attach.
-- Defined here (not inline) so the cheat sheet can list them even when nothing is attached.
local M = {}

local tb = function(name) return function() require("telescope.builtin")[name]() end end

local function source_definition()
  -- TS/Vue: jump to the real source instead of .d.ts; otherwise implementation
  local ts = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
  if not ts then return require("telescope.builtin").lsp_implementations() end
  local params = vim.lsp.util.make_position_params(0, "utf-16")
  ts:request("workspace/executeCommand", {
    command = "typescript.goToSourceDefinition",
    arguments = { params.textDocument.uri, params.position },
  }, function(err, result)
    if err then return vim.notify("goToSourceDefinition: " .. err.message, vim.log.levels.ERROR) end
    if result and #result > 0 then
      vim.lsp.util.show_document(result[1], "utf-16", { focus = true })
    else
      vim.notify("No source definition found")
    end
  end, 0)
end

-- { lhs, rhs, desc, mode? }
M.lsp = {
  { "gd", tb("lsp_definitions"), "Goto definition" },
  { "gr", tb("lsp_references"), "References" },
  { "gI", source_definition, "Goto source definition / implementation" },
  { "gy", tb("lsp_type_definitions"), "Goto type definition" },
  { "gD", vim.lsp.buf.declaration, "Goto declaration" },
  { "K", vim.lsp.buf.hover, "Hover" },
  { "gK", vim.lsp.buf.signature_help, "Signature help" },
  { "<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" } },
  { "<leader>cr", vim.lsp.buf.rename, "Rename symbol" },
  { "<leader>cR", function() Snacks.rename.rename_file() end, "Rename file (update imports)" },
  { "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP info" },
}

local gs = function(fn, ...)
  local args = { ... }
  return function() require("gitsigns")[fn](unpack(args)) end
end

M.git = {
  { "]h", gs("nav_hunk", "next"), "Next hunk" },
  { "[h", gs("nav_hunk", "prev"), "Prev hunk" },
  { "<leader>gp", gs("preview_hunk_inline"), "Preview hunk" },
  { "<leader>gr", gs("reset_hunk"), "Reset hunk", { "n", "x" } },
  { "<leader>gh", gs("stage_hunk"), "Stage / unstage hunk", { "n", "x" } },
  {
    "<leader>gs",
    function()
      local g = require("gitsigns")
      if #(g.get_hunks() or {}) > 0 then g.stage_buffer() else g.reset_buffer_index() end
    end,
    "Stage / unstage file",
  },
  { "<leader>gB", gs("blame"), "Blame (whole file)" },
  { "<leader>dd", gs("diffthis"), "Diff file vs index" },
}

function M.attach(list, buf)
  for _, k in ipairs(M[list]) do
    vim.keymap.set(k[4] or "n", k[1], k[2], { buffer = buf, desc = k[3] })
  end
end

return M
