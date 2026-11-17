-- Mason packages to auto-install (LSP servers + formatters + tools)
local tools = {
  "lua-language-server", "vtsls", "vue-language-server", "pyright", "ruff",
  "rust-analyzer", "json-lsp", "yaml-language-server", "html-lsp", "css-lsp",
  "tailwindcss-language-server", "eslint-lsp", "taplo",
  "stylua", "prettier", "shellcheck", "shfmt", "tree-sitter-cli",
}

-- Servers to enable (configs come from nvim-lspconfig's lsp/ dir, overrides below)
-- ruby_lsp uses the ruby-lsp from your rbenv (not Mason), so it follows each project's Ruby.
local servers = {
  "lua_ls", "vtsls", "vue_ls", "pyright", "ruff", "rust_analyzer", "jsonls",
  "yamlls", "html", "cssls", "tailwindcss", "eslint", "taplo", "ruby_lsp",
}

return {
  { "mason-org/mason.nvim", lazy = false, opts = {} },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    lazy = false,
    opts = { ensure_installed = tools },
  },

  { "b0o/SchemaStore.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 4, prefix = "●" },
        float = { border = "rounded", source = true },
        underline = true,
        update_in_insert = false,
      })

      -- Vue: vtsls loads @vue/typescript-plugin (hybrid mode)
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
        languages = { "vue" },
        configNamespace = "typescript",
      }
      vim.lsp.config("vtsls", {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        settings = { vtsls = { tsserver = { globalPlugins = { vue_plugin } } } },
      })

      vim.lsp.config("jsonls", {
        settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
      })
      vim.lsp.config("yamlls", {
        settings = { yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() } },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
            check = { command = "clippy", extraArgs = { "--no-deps" } },
            procMacro = { enable = true },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { workspace = { checkThirdParty = false }, completion = { callSnippet = "Replace" } } },
      })

      -- Add blink.cmp capabilities to every server
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
        callback = function(ev)
          require("config.buffer_keys").attach("lsp", ev.buf)

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end
        end,
      })
    end,
  },
}
