-- Multi-agent management via sidekick.nvim
-- Sessions are keyed by (tool, cwd): give each tab its own dir (<leader><tab>p / :tcd)
-- and each tab gets its own independent claude / codex / gemini.
local cli = function() return require("sidekick.cli") end

local open = function(name) return function() require("config.agent_open").open(name) end end

return {
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    opts = {
      nes = { enabled = false }, -- no Copilot Next Edit Suggestions
      cli = {
        win = { layout = "right", split = { width = 90 } },
        -- tmux keeps agent sessions alive after you quit nvim; reattach with <leader>as
        mux = { backend = "tmux", enabled = true },
      },
    },
    keys = {
      { "<c-.>", function() require("config.agent_open").focus_here() end, mode = { "n", "t", "i", "x" }, desc = "Agent focus" },
      { "<leader>aa", function() require("config.agent_open").toggle_here() end, desc = "Agent toggle" },
      { "<leader>as", function() cli().select({ filter = { installed = true } }) end, desc = "Agent select / attach (all projects)" },
      { "<leader>ad", function() cli().close() end, desc = "Agent detach" },
      { "<leader>ac", open("claude"), desc = "Claude" },
      { "<leader>cc", open("claude"), desc = "Claude" },
      { "<leader>ax", open("codex"), desc = "Codex" },
      { "<leader>ag", open("gemini"), desc = "Gemini" },
      { "<leader>at", function() cli().send({ msg = "{this}" }) end, mode = { "n", "x" }, desc = "Send this" },
      { "<leader>af", function() cli().send({ msg = "{file}" }) end, desc = "Send file" },
      { "<leader>av", function() cli().send({ msg = "{selection}" }) end, mode = "x", desc = "Send selection" },
      { "<leader>ap", function() cli().prompt() end, mode = { "n", "x" }, desc = "Agent prompt library" },
    },
  },
}
