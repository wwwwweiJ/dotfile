local parsers = {
  "bash", "c", "css", "diff", "dockerfile", "gitignore", "graphql", "html", "http",
  "javascript", "jsdoc", "json", "lua", "luadoc", "markdown", "markdown_inline",
  "python", "query", "regex", "ruby", "rust", "scss", "sql", "toml", "tsx",
  "typescript", "vim", "vimdoc", "vue", "xml", "yaml", "embedded_template",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },
}
