-- Agent status per tab (Orca-style "who needs me?" at a glance)
-- Claude Code hooks run bin/agent-status, which writes <state dir>/agents/<id>.json
-- with { cwd, state = running|waiting|done, ts }. We watch that folder and map each
-- status to the tab whose tab-local cwd contains it.
local M = {}

M.dir = vim.fn.stdpath("state") .. "/agents"
M.status = {} ---@type table<string, {cwd:string, state:string, ts:integer}>  keyed by cwd
local seen = {} ---@type table<string, integer>  cwd -> ts the user already looked at

local priority = { waiting = 3, done = 2, running = 1 }
M.icons = {
  running = { "●", "AgentRunning" },
  waiting = { "", "AgentWaiting" },
  done = { "✓", "AgentDone" },
}

local MAX_AGE = 12 * 3600

local function norm(p) return (vim.fs.normalize(p):gsub("/$", "")) end

local function read_all()
  local out = {}
  local now = os.time()
  for name, t in vim.fs.dir(M.dir) do
    if t == "file" and name:match("%.json$") then
      local f = io.open(M.dir .. "/" .. name)
      if f then
        local ok, data = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if ok and type(data) == "table" and data.cwd and data.state and now - (data.ts or 0) < MAX_AGE then
          data.cwd = norm(data.cwd)
          out[data.cwd] = data
        end
      end
    end
  end
  return out
end

local function tab_cwd(tab)
  return norm(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab)))
end

-- statuses that belong to a tab: agent cwd == tab cwd, or inside it
local function statuses_for(tab)
  local cwd = tab_cwd(tab)
  local list = {}
  for scwd, s in pairs(M.status) do
    if scwd == cwd or vim.startswith(scwd, cwd .. "/") then list[#list + 1] = s end
  end
  return list
end

--- Most urgent state for a tab (done that you've already seen is hidden)
---@return string|nil
function M.for_tab(tab)
  local best
  for _, s in ipairs(statuses_for(tab)) do
    local st = s.state
    if st == "done" and (seen[s.cwd] or 0) >= s.ts then st = nil end
    if st and (not best or priority[st] > priority[best]) then best = st end
  end
  return best
end

local function mark_seen(tab)
  for _, s in ipairs(statuses_for(tab)) do
    if s.state == "done" or s.state == "waiting" then seen[s.cwd] = s.ts end
  end
end

local function tab_for_cwd(cwd)
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    local tc = tab_cwd(t)
    if cwd == tc or vim.startswith(cwd, tc .. "/") then return t end
  end
end

local function refresh()
  local new = read_all()
  local cur = vim.api.nvim_get_current_tabpage()
  for cwd, s in pairs(new) do
    local old = M.status[cwd]
    if (not old or old.state ~= s.state or old.ts ~= s.ts) and (s.state == "waiting" or s.state == "done") then
      local tab = tab_for_cwd(cwd)
      if tab and tab ~= cur then
        local name = require("config.tabs").name(tab)
        local nr = vim.api.nvim_tabpage_get_number(tab)
        local msg = s.state == "waiting" and "等你回覆 / 需要授權" or "已完成"
        vim.notify(("[%d %s] Claude %s"):format(nr, name, msg), s.state == "waiting" and vim.log.levels.WARN or vim.log.levels.INFO, { title = "Agent" })
      end
    end
  end
  M.status = new
  mark_seen(cur) -- whatever is in the current tab counts as seen
  vim.cmd.redrawtabline()
end

local timer
local function schedule_refresh()
  timer = timer or vim.uv.new_timer()
  timer:stop()
  timer:start(150, 0, vim.schedule_wrap(refresh))
end

function M.setup()
  vim.fn.mkdir(M.dir, "p")
  vim.api.nvim_set_hl(0, "AgentRunning", { link = "DiagnosticWarn", default = true })
  vim.api.nvim_set_hl(0, "AgentWaiting", { link = "DiagnosticError", default = true })
  vim.api.nvim_set_hl(0, "AgentDone", { link = "DiagnosticOk", default = true })

  M.status = read_all()
  local w = vim.uv.new_fs_event()
  if w then w:start(M.dir, {}, function() schedule_refresh() end) end

  vim.api.nvim_create_autocmd({ "TabEnter", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("user_agent_status", { clear = true }),
    callback = function()
      mark_seen(vim.api.nvim_get_current_tabpage())
      vim.cmd.redrawtabline()
    end,
  })
end

return M
