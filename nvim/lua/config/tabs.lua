-- Named tabs + custom tabline + tab keymaps + telescope tab picker
local M = {}

---@param tab integer tabpage handle
function M.name(tab)
  local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
  if ok and name ~= "" then return name end
  local nr = vim.api.nvim_tabpage_get_number(tab)
  return vim.fn.fnamemodify(vim.fn.getcwd(-1, nr), ":t")
end

function M.rename(name)
  local function set(n)
    if n == nil then return end
    vim.t.name = n -- empty string falls back to cwd basename
    vim.cmd.redrawtabline()
  end
  if name then return set(name) end
  vim.ui.input({ prompt = "Tab name: ", default = vim.t.name or "" }, set)
end

-- New tab rooted at a directory (tab-local cwd => its own agents too)
function M.new_project()
  vim.ui.input({ prompt = "Tab dir: ", default = vim.fn.getcwd() .. "/", completion = "dir" }, function(dir)
    if not dir or dir == "" then return end
    dir = vim.fn.fnamemodify(vim.fn.expand(dir), ":p")
    if vim.fn.isdirectory(dir) == 0 then
      return vim.notify("Not a directory: " .. dir, vim.log.levels.WARN)
    end
    vim.cmd("tabnew")
    vim.cmd.tcd(vim.fn.fnameescape(dir))
    vim.t.name = vim.fn.fnamemodify(dir:gsub("/$", ""), ":t")
    require("mini.files").open(dir, false)
  end)
end

local function hl(group, text) return "%#" .. group .. "#" .. text end

-- Tabline colours (solarized-osaka palette). Re-applied on every :colorscheme.
local C = {
  fill = "NONE",
  active = "#268bd2", -- blue: current tab
  idle = "#2b3a46", -- frost: other tabs
  waiting = "#dc322f", -- red: an agent needs you
  done = "#859900", -- green: an agent finished
  running = "#b58900", -- yellow dot: an agent is working
  dark = "#001419",
  light = "#eee8d5",
  dim = "#839496",
}

function M.highlights()
  local set = vim.api.nvim_set_hl
  local pills = { Active = C.active, Idle = C.idle, Waiting = C.waiting, Done = C.done }
  for name, bg in pairs(pills) do
    local fg = name == "Idle" and C.dim or C.dark
    set(0, "TabPill" .. name, { fg = fg, bg = bg, bold = name ~= "Idle" })
    set(0, "TabPill" .. name .. "Cap", { fg = bg, bg = C.fill })
    set(0, "TabPill" .. name .. "Run", { fg = name == "Idle" and C.running or C.dark, bg = bg, bold = true })
  end
  set(0, "TabBufCurrent", { fg = C.light, bold = true, underline = true, sp = C.active })
  set(0, "TabBufOther", { fg = C.dim })
  set(0, "TabBufModified", { fg = C.running, bold = true })
  set(0, "TabLineFill", { bg = C.fill })
  set(0, "WinBar", { bg = C.fill })
  set(0, "WinBarNC", { bg = C.fill })
end

local L, R = "\u{e0b6}", "\u{e0b4}" -- rounded pill caps (Nerd Font)

function M.tabline()
  local s = {}

  -- Left: named tabs as pills (clickable)
  local status = require("config.agent_status")
  local curtab = vim.api.nvim_get_current_tabpage()
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    local nr = vim.api.nvim_tabpage_get_number(t)
    local st = status.for_tab(t)
    local style = (t == curtab and "Active") or (st == "waiting" and "Waiting") or (st == "done" and "Done") or "Idle"
    local g = "TabPill" .. style
    local icon = st and (status.icons[st][1] .. " ") or ""
    s[#s + 1] = "%" .. nr .. "T" .. hl("TabLineFill", " ") .. hl(g .. "Cap", L)
    if st == "running" then s[#s + 1] = hl(g .. "Run", icon) icon = "" end
    s[#s + 1] = hl(g, ("%s%d %s"):format(icon, nr, M.name(t))) .. hl(g .. "Cap", R)
  end
  s[#s + 1] = "%T" .. hl("TabLineFill", " ")

  return table.concat(s)
end

-- Second row: buffers of the current tab (scope.nvim keeps buflisted per tab),
-- shown as the winbar of the top-left code window only.
function M.bufline()
  local s = {}
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
      if name == "" then name = "[No Name]" end
      s[#s + 1] = hl("TabLineFill", " ") .. hl(b == cur and "TabBufCurrent" or "TabBufOther", name)
      if vim.bo[b].modified then s[#s + 1] = hl("TabBufModified", " ●") end
      s[#s + 1] = hl("TabLineFill", " ")
    end
  end
  return table.concat(s) .. hl("TabLineFill", "")
end

local BUFLINE = "%!v:lua.require'config.tabs'.bufline()"

local function is_code_win(w)
  if vim.api.nvim_win_get_config(w).relative ~= "" then return false end
  local b = vim.api.nvim_win_get_buf(w)
  return vim.bo[b].buftype == "" or vim.bo[b].filetype == "oil"
end

function M.update_winbars()
  local target, best
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_code_win(w) then
      local pos = vim.api.nvim_win_get_position(w)
      if not best or pos[1] < best[1] or (pos[1] == best[1] and pos[2] < best[2]) then
        target, best = w, pos
      end
    end
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w == target then
      if vim.wo[w].winbar ~= BUFLINE then vim.wo[w].winbar = BUFLINE end
    elseif vim.wo[w].winbar == BUFLINE then
      vim.wo[w].winbar = ""
    end
  end
end

function M.pick()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")

  local items = {}
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    local nr = vim.api.nvim_tabpage_get_number(t)
    local files = {}
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
      local b = vim.api.nvim_win_get_buf(w)
      local n = vim.api.nvim_buf_get_name(b)
      if n ~= "" and vim.bo[b].buftype == "" then files[#files + 1] = vim.fn.fnamemodify(n, ":t") end
    end
    local st = require("config.agent_status").for_tab(t)
    local label = ({ waiting = " 等你", done = "✓ 完成", running = "● 執行中" })[st] or "       "
    items[#items + 1] = {
      nr = nr,
      rank = ({ waiting = 0, done = 1, running = 2 })[st] or 3,
      text = ("%d  %-8s %-20s %s  %s"):format(nr, label, M.name(t), vim.fn.fnamemodify(vim.fn.getcwd(-1, nr), ":~"), table.concat(files, ", ")),
    }
  end
  table.sort(items, function(a, b) return a.rank == b.rank and a.nr < b.nr or a.rank < b.rank end)

  pickers.new({}, {
    prompt_title = "Tabs",
    finder = finders.new_table({
      results = items,
      entry_maker = function(i) return { value = i, display = i.text, ordinal = i.text } end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if e then vim.cmd.tabnext(e.value.nr) end
      end)
      return true
    end,
  }):find()
end

-- Buffers from ALL tabs. Picking one jumps to the window already showing it
-- (in any tab); otherwise switches to its tab, or opens it here.
function M.buffers()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  local make_entry = require("telescope.make_entry")

  pcall(function() require("scope.core").revalidate() end)
  local cache = package.loaded["scope.core"] and require("scope.core").cache or {}
  local cur = vim.api.nvim_get_current_tabpage()
  local seen, items = {}, {}
  local function add(buf, tab)
    if seen[buf] or not vim.api.nvim_buf_is_valid(buf) then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or vim.bo[buf].buftype ~= "" then return end
    seen[buf] = true
    items[#items + 1] = { buf = buf, tab = tab, path = name }
  end
  for _, b in ipairs(cache[cur] or {}) do add(b, cur) end
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    for _, b in ipairs(cache[t] or {}) do add(b, t) end
  end

  local displayer = require("telescope.pickers.entry_display").create({
    separator = " ",
    items = { { width = 14 }, { remaining = true } },
  })

  pickers.new({}, {
    prompt_title = "Buffers (all tabs)",
    finder = finders.new_table({
      results = items,
      entry_maker = function(i)
        local tabname = vim.api.nvim_tabpage_is_valid(i.tab)
            and (vim.api.nvim_tabpage_get_number(i.tab) .. " " .. M.name(i.tab)) or ""
        local rel = vim.fn.fnamemodify(i.path, ":~:.")
        return {
          value = i, bufnr = i.buf, filename = i.path, lnum = 1,
          ordinal = tabname .. " " .. rel,
          display = function()
            return displayer({ { tabname, i.tab == cur and "TelescopeResultsIdentifier" or "Comment" }, rel })
          end,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if not e then return end
        local buf, tab = e.value.buf, e.value.tab
        for _, t in ipairs(vim.api.nvim_list_tabpages()) do
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
            if vim.api.nvim_win_get_buf(w) == buf then
              vim.api.nvim_set_current_tabpage(t)
              return vim.api.nvim_set_current_win(w)
            end
          end
        end
        if tab ~= cur and vim.api.nvim_tabpage_is_valid(tab) then vim.api.nvim_set_current_tabpage(tab) end
        vim.api.nvim_set_current_buf(buf)
      end)
      return true
    end,
  }):find()
end

function M.setup()
  require("config.agent_status").setup()
  M.highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = M.highlights })
  vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "WinResized", "BufWinEnter", "TabEnter", "VimResized", "FileType" }, {
    group = vim.api.nvim_create_augroup("user_bufline", { clear = true }),
    callback = function() vim.schedule(M.update_winbars) end,
  })
  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.require'config.tabs'.tabline()"

  local map = vim.keymap.set
  map("n", "<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })
  map("n", "<S-tab>", "<cmd>tabprevious<cr>", { desc = "Prev tab" })
  map("n", "<leader><tab><tab>", function() vim.cmd("tabnew"); M.rename() end, { desc = "New tab" })
  map("n", "<leader><tab>p", M.new_project, { desc = "New tab at directory" })
  map("n", "<leader><tab>r", function() M.rename() end, { desc = "Rename tab" })
  map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
  map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
  map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
  map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Prev tab" })
  map("n", "<leader><tab>>", "<cmd>+tabmove<cr>", { desc = "Move tab right" })
  map("n", "<leader><tab><", "<cmd>-tabmove<cr>", { desc = "Move tab left" })
  map("n", "<leader><tab>f", M.pick, { desc = "Find tab" })
  map("n", "<leader>ft", M.pick, { desc = "Find tab" })
  for i = 1, 9 do
    map("n", "<leader>" .. i, "<cmd>tabnext " .. i .. "<cr>", { desc = "Tab " .. i })
  end

  vim.api.nvim_create_user_command("TabRename", function(o) M.rename(o.args) end, { nargs = "?" })
end

return M
