-- Open an agent for THIS tab's project without a picker.
-- sidekick's toggle({name=...}) lists every session of that tool on the machine (other projects too)
-- and pops a picker, which also swallows the next keys (e.g. <Space> → no which-key).
local M = {}

local function State() return require("sidekick.cli.state") end

-- sidekick keeps ONE window per session no matter which tab it is in, so toggling from
-- another tab would jump back to the tab holding that window. Close it there first so it
-- re-opens in the current tab instead.
local function adopt(states)
  local cur = vim.api.nvim_get_current_tabpage()
  for _, t in ipairs(states) do
    local term = t.terminal
    if term and term.win and vim.api.nvim_win_is_valid(term.win) and vim.api.nvim_win_get_tabpage(term.win) ~= cur then
      pcall(vim.api.nvim_win_close, term.win, true)
      term.win = nil
    end
  end
end

--- Reuse the session in the current cwd if there is one, otherwise start a new one here.
function M.open(name)
  local S = State()
  local here = S.get({ name = name, cwd = true })
  if #here > 0 then
    adopt(here)
    return require("sidekick.cli").toggle({ filter = { name = name, cwd = true }, focus = true })
  end
  for _, t in ipairs(S.get({ name = name })) do
    if not t.session then return S.attach(t, { show = true, focus = true }) end
  end
  vim.notify(name .. " is not installed", vim.log.levels.WARN)
end

--- Toggle whatever agent this project already has; otherwise ask which tool to start.
function M.toggle_here()
  local here = State().get({ cwd = true })
  if #here > 0 then
    adopt(here)
    require("sidekick.cli").toggle({ filter = { cwd = true } })
  else
    require("sidekick.cli").select({ filter = { installed = true } })
  end
end

--- <C-.>: focus this project's agent (bringing its window into the current tab)
function M.focus_here()
  local here = State().get({ cwd = true })
  if #here == 0 then return M.toggle_here() end
  adopt(here)
  require("sidekick.cli").focus({ filter = { cwd = true } })
end

return M
