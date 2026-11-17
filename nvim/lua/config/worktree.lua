-- Git worktree workspaces (Orca-compatible layout: ~/orca/workspaces/<repo>/<name>)
--   <leader>gw  pick worktree -> jump to its tab (or open a new tab rooted there)
--               in picker: <C-n> new, <C-d> delete
--   <leader>gW  new worktree (+ tab + optional agent)
local M = {}

M.root = vim.fn.expand("~/orca/workspaces")

-- gitignored files that a fresh worktree needs (same as what Orca links in).
-- Each is symlinked from the main repo's copy (symlinks resolved) if it exists there.
M.links = {
  ".claude/settings.local.json", -- per-project Claude login (ANTHROPIC_BASE_URL / token)
  "config/credentials/development.key", -- Rails dev credentials key (some Rails apps)
}

local function git(args, cwd)
  local r = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
  return r.code == 0, vim.trim(r.stdout or ""), vim.trim(r.stderr or "")
end

local function norm(p) return (vim.fs.normalize(p):gsub("/$", "")) end

--- main repo of the current tab (works from inside any of its worktrees)
function M.main_repo()
  local ok, common = git({ "rev-parse", "--path-format=absolute", "--git-common-dir" }, vim.fn.getcwd())
  if not ok then return nil end
  return norm(vim.fs.dirname(common))
end

function M.list(repo)
  local ok, out = git({ "worktree", "list", "--porcelain" }, repo)
  if not ok then return {} end
  local list, cur = {}, nil
  for line in (out .. "\n"):gmatch("([^\n]*)\n") do
    local path = line:match("^worktree (.+)")
    if path then
      cur = { path = norm(path), branch = "(detached)" }
      list[#list + 1] = cur
    elseif cur and line:match("^branch ") then
      cur.branch = line:match("^branch refs/heads/(.+)") or line:sub(8)
    elseif cur and line == "bare" then
      cur.bare = true
    end
  end
  return vim.tbl_filter(function(w) return not w.bare end, list)
end

local function tab_with_cwd(path)
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    if norm(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(t))) == path then return t end
  end
end

--- Focus the tab for `path`, or open a new tab rooted there
function M.open(path, name)
  local tab = tab_with_cwd(path)
  if tab then return vim.api.nvim_set_current_tabpage(tab) end
  vim.cmd("tabnew")
  vim.cmd.tcd(vim.fn.fnameescape(path))
  vim.t.name = name or vim.fs.basename(path)
  vim.cmd.edit(vim.fn.fnameescape(path)) -- oil shows the directory
end

local function ask_agent()
  vim.ui.select({ "Claude", "Codex", "Gemini", "先不要" }, { prompt = "要在這個 worktree 開 agent 嗎？" }, function(choice)
    if not choice or choice == "先不要" then return end
    require("config.agent_open").open(choice:lower())
  end)
end

-- "leo/feat/PROJ-123/my_task" -> "PROJ-123-my_task"
local function default_dirname(branch)
  local jira, desc = branch:match("([A-Z]+%-%d+)/([^/]+)$")
  if jira then return jira .. "-" .. desc end
  return (branch:gsub(".*/", ""))
end

--- symlink M.links from the main repo into a new worktree; returns linked paths
function M.link_files(repo, path)
  local done = {}
  for _, rel in ipairs(M.links) do
    local src = vim.uv.fs_realpath(repo .. "/" .. rel)
    local dst = path .. "/" .. rel
    if src and not vim.uv.fs_lstat(dst) then
      vim.fn.mkdir(vim.fs.dirname(dst), "p")
      if vim.uv.fs_symlink(src, dst) then done[#done + 1] = rel end
    end
  end
  return done
end

local function default_base(repo)
  for _, b in ipairs({ "master", "main" }) do
    if git({ "rev-parse", "--verify", "--quiet", b }, repo) then return b end
  end
  return "HEAD"
end

function M.create()
  local repo = M.main_repo()
  if not repo then return vim.notify("目前 tab 不在 git repo 裡", vim.log.levels.WARN) end
  vim.ui.input({ prompt = "Branch: ", default = "leo/feat/" }, function(branch)
    if not branch or branch == "" or branch:match("/$") then return end
    vim.ui.input({ prompt = "Worktree 名稱: ", default = default_dirname(branch) }, function(dirname)
      if not dirname or dirname == "" then return end
      local path = ("%s/%s/%s"):format(M.root, vim.fs.basename(repo), dirname)
      if vim.uv.fs_stat(path) then return vim.notify("已存在: " .. path, vim.log.levels.WARN) end

      local exists = git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. branch }, repo)
      local base = default_base(repo)
      local args = exists and { "worktree", "add", path, branch } or { "worktree", "add", "-b", branch, path, base }
      vim.notify(("建立 worktree %s（%s）…"):format(dirname, exists and "既有 branch" or ("從 " .. base)))
      vim.system(vim.list_extend({ "git" }, args), { cwd = repo, text = true }, vim.schedule_wrap(function(r)
        if r.code ~= 0 then return vim.notify("git worktree add 失敗:\n" .. (r.stderr or ""), vim.log.levels.ERROR) end
        local linked = M.link_files(repo, path)
        if #linked > 0 then vim.notify("已連結: " .. table.concat(linked, ", ")) end
        M.open(path, dirname)
        ask_agent()
      end))
    end)
  end)
end

function M.remove(w, repo)
  if norm(w.path) == repo then return vim.notify("不能刪除主 repo", vim.log.levels.WARN) end
  local _, dirty = git({ "status", "--porcelain" }, w.path)
  local warn = dirty ~= "" and "（⚠ 有未 commit 的變更，會一起丟掉）" or ""
  vim.ui.select({ "刪除", "取消" }, { prompt = ("刪除 worktree %s？branch 會保留%s"):format(vim.fs.basename(w.path), warn) }, function(c)
    if c ~= "刪除" then return end
    local tab = tab_with_cwd(w.path)
    if tab then
      if #vim.api.nvim_list_tabpages() == 1 then vim.cmd("tabnew") end
      vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab))
    end
    local args = { "worktree", "remove", w.path }
    if dirty ~= "" then table.insert(args, "--force") end
    local ok, _, err = git(args, repo)
    vim.notify(ok and ("已刪除 " .. w.path) or ("刪除失敗: " .. err), ok and vim.log.levels.INFO or vim.log.levels.ERROR)
  end)
end

function M.pick()
  local repo = M.main_repo()
  if not repo then return vim.notify("目前 tab 不在 git repo 裡", vim.log.levels.WARN) end
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  local status = require("config.agent_status")

  local function finder()
    return finders.new_table({
      results = M.list(repo),
      entry_maker = function(w)
        local tab = tab_with_cwd(w.path)
        local st = tab and status.for_tab(tab)
        local mark = ({ waiting = "", done = "✓", running = "●" })[st] or (tab and "▪" or " ")
        local text = ("%s %-32s %s"):format(mark, vim.fs.basename(w.path), w.branch)
        return { value = w, display = text, ordinal = w.path .. " " .. w.branch }
      end,
    })
  end

  pickers.new({}, {
    prompt_title = "Worktrees  (Enter 開啟 · C-n 新增 · C-d 刪除)",
    finder = finder(),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr, map)
      actions.select_default:replace(function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if e then M.open(e.value.path, vim.fs.basename(e.value.path)) end
      end)
      map({ "i", "n" }, "<C-n>", function()
        actions.close(bufnr)
        M.create()
      end)
      map({ "i", "n" }, "<C-d>", function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if e then M.remove(e.value, repo) end
      end)
      return true
    end,
  }):find()
end

return M
