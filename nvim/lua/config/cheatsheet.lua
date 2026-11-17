-- Generates an HTML cheat sheet from the LIVE keymaps (always in sync with your config)
-- and opens it in the browser.  <leader>?  or  :Keymaps
local M = {}

-- Category rules: first match wins. Patterns are Lua patterns on the display lhs.
local categories = {
  { "Agents (AI CLI)", { "^Space a", "^<C%-%.>" } },
  { "Tabs", { "^Space <Tab>", "^Space %d$", "^<Tab>", "^<S%-Tab>" } },
  { "Pickers  ( ; )", { "^;", "^Space Space", "^Space /", "^\\\\", "^Space f" } },
  { "Files", { "^Space [eE]$", "^sf$" } },
  { "General", { "^Space %?$", "^Space l$", "^Space q", "^<C%-[sS]>$", "^<Esc>$", "^<C%-/>$" } },
  { "Buffers", { "^Space b", "^[HL]$", "^[%[%]]b$" } },
  { "Code / LSP", { "^Space c", "^g[dDIKy]$", "^gr$", "^K$", "^gK$" } },
  { "Git", { "^Space g", "^[%[%]]h$" } },
  { "Diff / Review", { "^Space d" } },
  { "Search & Replace", { "^Space s", "^<S%-f>$", "^F$", "^[%[%]]t$" } },
  { "Yank & Paste", { "^Space y", "^Space [pP]$", "^<C%-[pP]>$", "^x$" } },
  { "Toggles", { "^Space u", "^Space z$" } },
  { "Windows", { "^<C%-W>", "^Space w", "^Space [%-|]$", "^<C%-[hjklHJKL]>$", "^<C%-[UD][po]w?n?>", "^<C%-Up>", "^<C%-Down>", "^<C%-Left>", "^<C%-Right>" } },
  { "Motion & Editing", { "^[sS]$", "^gs", "^gc", "^fg$", "^<[AM]%-", "^<C%-[aAxX]>$", "^[ai]n$", "^[%[%]]n$", "^[%[%]]Space$" } },
  { "Diagnostics & Jumps", { "^[%[%]]" } },
}

local function display_lhs(lhs)
  lhs = vim.fn.keytrans(lhs)
  lhs = lhs:gsub("<Space>", "Space "):gsub("<lt>", "<"):gsub("%s+$", "")
  return lhs
end

local function skip(m)
  local d = m.desc
  if not d or d == "" then return true end
  if m.lhs:match("^<Plug>") or m.lhs:match("^<SNR>") then return true end
  if d:match("^:") or d:match("Nvim builtin") then return true end -- builtin :cnext-style defaults
  if d:match("^which%-key") then return true end
  if d:match("^vim%.") then return true end -- builtin gra/grn/... (you have <leader>ca etc.)
  return false
end

local function collect()
  local seen, list = {}, {}
  local function add(m, scope)
    if skip(m) then return end
    local lhs = display_lhs(m.lhs)
    local key = lhs .. "\0" .. m.desc
    if seen[key] then
      if not seen[key].modes:find(m.mode, 1, true) then seen[key].modes = seen[key].modes .. m.mode end
      return
    end
    local item = { lhs = lhs, desc = m.desc, modes = m.mode, scope = scope }
    seen[key] = item
    list[#list + 1] = item
  end
  for _, mode in ipairs({ "n", "x", "o", "i", "t" }) do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do add(m, "global") end
    -- buffer-local maps (LSP, gitsigns, ...) from every normal file buffer
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "" then
        for _, m in ipairs(vim.api.nvim_buf_get_keymap(b, mode)) do
          m.mode = mode
          add(m, "buffer")
        end
      end
    end
  end
  -- LSP / gitsigns maps, even if nothing is attached right now
  local bk = require("config.buffer_keys")
  for _, group in ipairs({ "lsp", "git" }) do
    for _, k in ipairs(bk[group]) do
      local modes = k[4] or "n"
      for _, mode in ipairs(type(modes) == "table" and modes or { modes }) do
        add({ lhs = vim.keycode(k[1]), desc = k[3], mode = mode }, "buffer")
      end
    end
  end
  -- Vim native keys (not mappings). Hide the modes where you've remapped that exact key.
  local function norm(l) return (l:gsub("<([CMAS])%-(%a)>", function(m, c) return "<" .. m .. "-" .. c:upper() .. ">" end)) end
  local taken = {}
  for _, it in ipairs(list) do
    for ch in it.modes:gmatch(".") do taken[norm(it.lhs) .. "\0" .. ch] = true end
  end
  for _, group in ipairs(require("config.cheatsheet_vim")) do
    for _, k in ipairs(group) do
      local lhs, modes = k[1], k[4] or "n"
      local simple = not lhs:find("[%s{]") and not lhs:match("^:")
      local keep = ""
      for ch in modes:gmatch(".") do
        if not (simple and taken[norm(lhs) .. "\0" .. ch]) then keep = keep .. ch end
      end
      if keep ~= "" then
        list[#list + 1] = { lhs = lhs, desc = k[2], zh = k[3], modes = keep, scope = "native", cat = group.cat }
      end
    end
  end
  return list
end

local function categorize(list)
  local groups, order = {}, {}
  for _, c in ipairs(categories) do
    groups[c[1]] = {}
    order[#order + 1] = c[1]
  end
  groups["Other"] = {}
  order[#order + 1] = "Other"
  for _, group in ipairs(require("config.cheatsheet_vim")) do
    groups[group.cat] = {}
    order[#order + 1] = group.cat
  end
  for _, item in ipairs(list) do
    local placed = item.cat ~= nil
    if placed then table.insert(groups[item.cat], item) end
    for _, c in ipairs(categories) do
      for _, pat in ipairs(c[2]) do
        if item.lhs:match(pat) then
          table.insert(groups[c[1]], item)
          placed = true
          break
        end
      end
      if placed then break end
    end
    if not placed then table.insert(groups["Other"], item) end
  end
  for _, g in pairs(groups) do
    if not (g[1] and g[1].cat) then -- native groups keep their hand-written order
      table.sort(g, function(a, b) return a.lhs:lower() < b.lhs:lower() end)
    end
  end
  return groups, order
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function kbd(lhs, native)
  if native then
    if lhs:match("^:") then
      return '<kbd class="cmd">' .. esc(lhs):gsub("{(.-)}", '<span class="ph">%1</span>') .. "</kbd>"
    end
    if lhs:find(" ") then -- "h j k l" / "iw aw": alternatives
      local parts = {}
      for part in lhs:gmatch("%S+") do parts[#parts + 1] = kbd(part, true) end
      return table.concat(parts, '<span class="alt">/</span>')
    end
  end
  -- split into tokens: <...> chords, {placeholder}, "Space", or single chars
  local out, i = {}, 1
  while i <= #lhs do
    local c = lhs:sub(i, i)
    if native and c == "{" and lhs:find("}", i, true) then
      local j = lhs:find("}", i, true)
      local ph = ({ c = "字元", m = "範圍", r = "暫存器", a = "標記", n = "數字", pat = "關鍵字" })[lhs:sub(i + 1, j - 1)] or lhs:sub(i + 1, j - 1)
      out[#out + 1] = '<span class="ph">' .. esc(ph) .. "</span>"
      i = j + 1
    elseif c == "<" and (not native or lhs:find("^<[%w-]+>", i)) then
      local j = lhs:find(">", i, true)
      if j then
        out[#out + 1] = "<kbd>" .. esc(lhs:sub(i + 1, j - 1)) .. "</kbd>"
        i = j + 1
      else
        out[#out + 1] = "<kbd>&lt;</kbd>"
        i = i + 1
      end
    elseif lhs:sub(i, i + 5) == "Space " or lhs:sub(i) == "Space" then
      out[#out + 1] = '<kbd class="leader">Space</kbd>'
      i = i + 6
    elseif c == " " then
      i = i + 1
    else
      out[#out + 1] = "<kbd>" .. esc(c) .. "</kbd>"
      i = i + 1
    end
  end
  return table.concat(out, "")
end

local mode_names = { n = "N", x = "V", o = "O", i = "I", t = "T" }

local function render(groups, order)
  local zh = require("config.cheatsheet_zh")
  local cards = {}
  local total = 0
  for _, name in ipairs(order) do
    local g = groups[name]
    if #g > 0 then
      local rows = {}
      for _, it in ipairs(g) do
        total = total + 1
        local modes = {}
        for ch in it.modes:gmatch(".") do
          modes[#modes + 1] = '<span class="mode m-' .. ch .. '">' .. (mode_names[ch] or ch) .. "</span>"
        end
        local zhd = it.zh or zh.get(it.desc)
        local desc_html = zhd and ('<span class="zh">%s</span><span class="en">%s</span>'):format(esc(zhd), esc(it.desc))
          or ('<span class="zh">%s</span>'):format(esc(it.desc))
        rows[#rows + 1] = ('<tr data-s="%s"><td class="k">%s</td><td class="d">%s%s</td><td class="md">%s</td></tr>'):format(
          esc((it.lhs .. " " .. it.desc .. " " .. (zhd or "") .. " " .. name .. " " .. (zh.categories[name] or "")):lower()),
          kbd(it.lhs, it.scope == "native"),
          desc_html,
          it.scope == "buffer" and ' <span class="buf" title="檔案 attach LSP / git 後才有的按鍵">buf</span>' or "",
          table.concat(modes)
        )
      end
      local src = g[1].scope == "native" and "native" or "custom"
      cards[#cards + 1] = ('<section class="card" data-src="' .. src .. '"><h2>%s <span class="h-en">%s</span> <span class="n">%d</span></h2><table>%s</table></section>'):format(
        esc(zh.categories[name] or name), zh.categories[name] and esc(name) or "", #g, table.concat(rows, "\n")
      )
    end
  end

  return ([[<!doctype html>
<html lang="zh-Hant"><head><meta charset="utf-8">
<title>Neovim 快捷鍵</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root{--bg:#001419;--card:#0b2a33cc;--line:#1d4450;--fg:#c0cacb;--dim:#6b8a91;--accent:#b28500;--cyan:#29a298;--blue:#268bd2;--magenta:#c94c8a;--green:#5c9a00}
*{box-sizing:border-box}
body{margin:0;font:14px/1.45 "JetBrainsMono NFM","JetBrains Mono",ui-monospace,Menlo,monospace;color:var(--fg);
 background:radial-gradient(1200px 600px at 10%% -10%%,#0d3a46 0,transparent 60%%),radial-gradient(900px 500px at 110%% 10%%,#2a1f3d 0,transparent 55%%),var(--bg);min-height:100vh}
header{position:sticky;top:0;z-index:5;padding:18px 28px 14px;backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);background:#00141999;border-bottom:1px solid var(--line);display:flex;gap:18px;align-items:center;flex-wrap:wrap}
h1{margin:0;font-size:18px;color:var(--accent);letter-spacing:.5px}
.meta{color:var(--dim);font-size:12px}
input{flex:1;min-width:240px;max-width:520px;padding:9px 14px;border-radius:10px;border:1px solid var(--line);background:#00000055;color:var(--fg);font:inherit;outline:none}
input:focus{border-color:var(--cyan);box-shadow:0 0 0 3px #29a29833}
.legend{display:flex;gap:6px;align-items:center;color:var(--dim);font-size:12px}
main{columns:440px;column-gap:18px;padding:22px 28px 60px}
.card{break-inside:avoid;margin:0 0 18px;background:var(--card);border:1px solid var(--line);border-radius:14px;padding:12px 14px 8px;backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);box-shadow:0 8px 30px #0006}
h2{margin:2px 2px 8px;font-size:13px;text-transform:uppercase;letter-spacing:1px;color:var(--cyan)}
h2 .n{color:var(--dim);font-weight:normal;margin-left:6px}
h2 .h-en{color:var(--dim);font-weight:normal;font-size:11px;letter-spacing:.5px;margin-left:4px}
td.d .zh{display:block;color:var(--fg);font-family:"PingFang TC","Noto Sans TC",system-ui,sans-serif}
td.d .en{display:block;color:var(--dim);font-size:11px;line-height:1.3}
table{width:100%%;border-collapse:collapse}
tr{border-top:1px solid #ffffff0d}
tr:first-child{border-top:0}
td{padding:5px 4px;vertical-align:middle}
td.k{white-space:nowrap;width:1%%;padding-right:14px}
td.md{text-align:right;white-space:nowrap;width:1%%}
kbd{display:inline-block;min-width:20px;padding:1px 6px;margin:0 2px 0 0;border-radius:6px;border:1px solid #2f5b66;border-bottom-width:2px;background:#0f343e;color:#e6e6d9;font:12px/1.5 inherit;text-align:center}
kbd.leader{background:#3a2e00;border-color:#6b5500;color:#f0c94a}
.mode{display:inline-block;width:18px;margin-left:3px;text-align:center;border-radius:4px;font-size:11px;color:#001419;font-weight:bold}
.m-n{background:var(--blue)}.m-x{background:var(--magenta)}.m-o{background:var(--dim)}.m-i{background:var(--green)}.m-t{background:var(--accent)}
.buf{font-size:10px;color:var(--dim);border:1px solid var(--line);border-radius:4px;padding:0 4px;margin-left:4px}
.hide{display:none}
kbd.cmd{background:#2a1f3d;border-color:#4b3a6b;color:#d8c8ff}
.ph{display:inline-block;padding:0 5px;margin:0 2px 0 0;border:1px dashed #4a6d76;border-radius:5px;color:var(--dim);font-size:11px;font-family:"PingFang TC",system-ui,sans-serif}
kbd .ph{border:0;padding:0;margin:0}
.alt{color:var(--dim);margin:0 4px 0 1px}
.filters{display:flex;gap:4px;background:#00000055;border:1px solid var(--line);border-radius:10px;padding:3px}
.filters button{font:inherit;font-size:12px;color:var(--dim);background:none;border:0;border-radius:7px;padding:5px 10px;cursor:pointer}
.filters button.on{background:var(--blue);color:#001419;font-weight:bold}
section[data-src="native"] h2{color:var(--magenta)}
mark{background:#b2850055;color:inherit;border-radius:3px}
</style></head><body>
<header>
 <h1>⌨ Neovim 快捷鍵</h1>
 <input id="q" placeholder="搜尋按鍵或說明（中英皆可）…  按 / 聚焦，Esc 清除" autofocus>
 <div class="filters"><button data-f="all" class="on">全部</button><button data-f="custom">自訂</button><button data-f="native">Vim 原生</button></div>
 <div class="legend"><span class="mode m-n">N</span>一般 <span class="mode m-x">V</span>選取 <span class="mode m-i">I</span>插入 <span class="mode m-t">T</span>終端 <kbd class="leader">Space</kbd>= leader <span class="buf">buf</span>= 檔案 attach 後才有</div>
 <div class="meta">共 %d 個 · 產生於 %s · 按 <code>&lt;leader&gt;?</code> 重新產生</div>
</header>
<main id="m">%s</main>
<script>
const q=document.getElementById('q');
let src='all';
document.querySelectorAll('.filters button').forEach(b=>b.addEventListener('click',()=>{
 src=b.dataset.f;document.querySelectorAll('.filters button').forEach(x=>x.classList.toggle('on',x===b));f()}));
function f(){const v=q.value.trim().toLowerCase();
 document.querySelectorAll('.card').forEach(c=>{let any=false;
  if(src!=='all'&&c.dataset.src!==src){c.classList.add('hide');return}
  c.querySelectorAll('tr').forEach(r=>{const ok=!v||r.dataset.s.includes(v);r.classList.toggle('hide',!ok);any=any||ok});
  c.classList.toggle('hide',!any)})}
q.addEventListener('input',f);
document.addEventListener('keydown',e=>{if(e.key==='/'&&document.activeElement!==q){e.preventDefault();q.focus()}
 if(e.key==='Escape'){q.value='';f();q.blur()}});
</script></body></html>]]):format(total, os.date("%Y-%m-%d %H:%M"), table.concat(cards, "\n"))
end

function M.write()
  local groups, order = categorize(collect())
  local path = vim.fn.stdpath("cache") .. "/keymaps.html"
  local f = assert(io.open(path, "w"))
  f:write(render(groups, order))
  f:close()
  return path
end

function M.open()
  vim.ui.open(M.write())
end

return M
