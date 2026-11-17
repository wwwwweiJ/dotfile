# Leo 的 Neovim 設定

自己寫的設定（**不是 LazyVim**），用 lazy.nvim 當插件管理器。
2026-11-05 從 LazyVim 搬過來；舊設定備份在 `~/.config/nvim.bak-lazyvim-20261105`（還有 `~/.local/{share,state}/nvim.bak-lazyvim-20261105`、`~/.cache/nvim.bak-lazyvim-20261105`）。

環境：Neovim 0.12 · macOS · Ghostty 終端 · tmux · `vi` 是 `nvim` 的 alias。

**位置**：實體檔案在 `~/dotfile/nvim`（repo：github.com/wwwwweiJ/dotfile，**公開**），`~/.config/nvim` 是指過去的 symlink。
不要把公司內部網域、token、Jira 單號寫進這個資料夾的任何檔案。

## 目標（改設定時要守住的原則）

1. **整天待在 nvim 裡，不用切到 Orca**：worktree 工作區、每個工作區各自的 agent、審查改動、一眼看出哪個 agent 需要我 —— 這四件事都在 nvim 內完成。
   Orca 的「派工 / ask-reply / Codex 審 Claude」編排功能我沒在用，不需要複製。
2. **一個 tab = 一個工作區**：tab-local cwd（`:tcd`）決定 buffer 列表、agent session、agent 狀態歸屬。
3. **保留的習慣**：telescope 的 `;f ;r ;; \\`、leap 的 `s/S`、lualine statusline、`<C-s>` 存檔、`<C-p>` 複製路徑、`fg` 到行尾、`<space><space>` 找檔案。
4. **不要自動格式化**（原本就關掉的），只用 `<leader>cf` 手動格式化。
5. 外觀：solarized-osaka、透明背景、浮動視窗是「毛玻璃」。

## 檔案結構

```
init.lua                    載入順序：options → lazy → keymaps → autocmds → tabs.setup()
bin/
  agent-status              Claude Code hook 呼叫：寫 agent 狀態檔（見下方）
  install-agent-hooks       把 hook 追加進 ~/.claude/settings.json（可重複執行）
lua/config/
  options.lua               基本選項（leader = Space，localleader = \）
  lazy.lua                  lazy.nvim bootstrap
  keymaps.lua               不依賴插件的核心 keymap + worktree + 速查頁
  autocmds.lua              yank 高亮、回到上次位置、cursorline 只在目前視窗…
  tabs.lua                  自製 tabline（第一行：具名 tab 膠囊，顏色顯示 agent 狀態）＋ buffer 列（第二行，用左上角程式碼視窗的 winbar 顯示本 tab 的 buffer）、tab keymap、
                            tab picker、跨 tab buffer picker（\\）
  agent_status.lua          監看 ~/.local/state/nvim/agents/*.json → tabline 狀態圖示 + 通知
  worktree.lua              git worktree 建立 / 切換 / 刪除（Orca 相容路徑）
  buffer_keys.lua           LSP / gitsigns 的 buffer-local keymap 定義（attach 時綁、速查頁也讀）
  yank.lua                  複製 路徑#L行號 / code block（貼給 agent 用）
  cheatsheet.lua            <leader>? 產生 HTML 速查頁（從實際 keymap 即時產生）
  cheatsheet_zh.lua         速查頁的繁中翻譯（desc → 中文、分類名）
lua/plugins/
  colorscheme.lua           solarized-osaka + 毛玻璃浮動視窗顏色
  ui.lua                    snacks（dashboard/notifier/toggles/lazygit）、lualine、which-key、incline、zen-mode
  editor.lua                telescope、oil、mini.files、leap、grug-far、todo-comments、gitsigns、
                            git.nvim、codediff、mini.*、dial
  coding.lua                blink.cmp、autopairs、lazydev、conform
  lsp.lua                   mason + mason-tool-installer + nvim-lspconfig（0.12 原生 vim.lsp.config/enable）
  treesitter.lua            nvim-treesitter（main branch）
  agents.lua                sidekick.nvim（多 agent CLI）
  tabs.lua                  scope.nvim（每個 tab 自己的 buffer 列表）
lua/config/agent_open.lua   開 agent 的 helper（只看本專案的 session、不跳選單）
```

## 關鍵設計與原因

### 多 agent（sidekick.nvim）
- sidekick 的 session 以 **(工具, window cwd)** 為 key → 每個 tab `tcd` 到不同 worktree，就各有獨立的 claude/codex/gemini。
- `mux = tmux`：agent 跑在 tmux session 裡，關 nvim 不會斷，`<leader>as` 接回。副作用：tmux session 會累積，要自己 `tmux ls` / `kill-session` 清。
- NES（Copilot Next Edit Suggestions）關掉了。
- 取代了原本的 claude-code.nvim；`<leader>cc` 保留為「開 Claude」。
- **不要直接用 `cli.toggle({ name = ... })`**：它會列出整台電腦所有該工具的 session（包含別的專案），跳出 Telescope 選單，
  而且選單會吃掉接下來的按鍵（症狀：按空白鍵沒有 which-key 提示）。改用 `config/agent_open.lua`：
  目前 cwd 已有 session → 直接接上；沒有 → 直接開新的（找 `State.get()` 裡沒有 session 的那一筆再 `State.attach`）。
  注意 sidekick 的 filter `started = false` 不會命中「新 session」那筆（它的 started 是 nil）。
  跨專案挑 session 用 `<leader>as`。
- **agent 視窗跟著 tab 走**：sidekick 每個 session 只記一個視窗、不分 tab，從別的 tab 開會「跳回」原本那個 tab。
  `agent_open.lua` 的 `adopt()` 會先把它在別的 tab 的視窗關掉，再在目前 tab 重開（`<leader>ac/ax/ag/aa`、`<C-.>` 都會）。
- **同一個資料夾 = 同一個 agent**（設計如此，兩個 agent 改同一份檔案會打架）。`<leader><tab><tab>`/`:tabnew` 不會換資料夾；
  要各自獨立的 agent，tab 要用 `<leader><tab>p`（指定目錄）或 `<leader>gw/gW`（worktree）開。

### Agent 狀態（Orca 的「誰在等我」）
流程：Claude Code hook → `bin/agent-status <state>` → 寫 `~/.local/state/nvim/agents/<sha(cwd)>.json`（`{cwd, state, tool, ts}`）→ `agent_status.lua` 用 `vim.uv` fs_event 監看 → tabline 顯示、跳通知。
- 狀態：`running ●`（黃）/ `waiting `（紅，需要授權或回覆）/ `done ✓`（綠，切到該 tab 看過後消失）。
- tabline 樣式（`tabs.lua` 的 `C` 色表 + `M.highlights()`，換 colorscheme 時自動重套）：tab 是圓角膠囊靠左；
  目前 tab 藍底粗體、其他 tab 深灰；**非目前 tab 有 agent 在等你 → 整顆變紅、完成 → 整顆變綠**、執行中 → 黃點。
- 狀態歸屬：agent cwd 等於或位於某 tab 的 tab-local cwd 底下。
- hook（`install-agent-hooks` 追加，全部 async）：UserPromptSubmit→running、PostToolUse→running、Notification→waiting、Stop→done。
- **Claude Code 不允許 agent 自己改 `~/.claude/settings.json`**（auto mode 會擋），所以 hook 要由 Leo 手動執行 `! ~/.config/nvim/bin/install-agent-hooks`。Orca 可能重寫 hooks，標記消失時重跑即可。
- 超過 12 小時的狀態檔忽略（agent 被強制中斷時「執行中」會殘留到那時）。
- 目前只有 Claude 會回報；Codex/Gemini 未接。

### Worktree（`worktree.lua`）
- 路徑：`~/orca/workspaces/<repo 名>/<名稱>`，與 Orca 相同 → 兩邊互通。
- branch 預設 `leo/feat/`，名稱由 branch 推導：`leo/feat/INS-42/my_task` → `INS-42-my_task`。
- 新 branch 從 `master`（沒有就 `main`，再沒有就 HEAD）開；branch 已存在就直接 checkout。
- 刪除：確認後關 tab、`git worktree remove`（有未 commit 變更時加 `--force` 並警告），**branch 保留**。
- **建立後自動 symlink 被 gitignore 的必要檔案**（`M.links`，與 Orca 行為一致；來源是主 repo 那份、symlink 會先解析成實體路徑）：
  - `.claude/settings.local.json` → **每個專案的 Claude 登入**（`env.ANTHROPIC_BASE_URL` = 公司的 Claude gateway + `ANTHROPIC_AUTH_TOKEN`）。少了它，該 worktree 的 Claude 會改用個人預設登入。
  - `config/credentials/development.key` → Rails 開發金鑰（部分 Rails 專案需要）。
  - 其他專案還需要別的檔案時，加進 `M.links` 即可（主 repo 沒有的會自動略過）。

### 每個專案用不同的 Claude 登入
不是 Orca 管的（`orca account list` 是空的），是 **Claude Code 本身會讀專案根目錄的 `.claude/settings.local.json`**。
sidekick 以 tab 的 cwd 啟動 agent，所以只要該目錄有這個檔案，nvim 裡開的 Claude 就跟 Orca 吃同一份登入。
公司專案的主 repo 與 Orca 建的 worktree 都已經有；nvim 新建的 worktree 由上面的 `M.links` 補上。
不要把 token 印出來或寫進任何文件。

### Tab / buffer
- scope.nvim 讓 buflisted 依 tab 分開 → `S-h/S-l`、bufferline 式列表都只看本 tab。
- tabline 是自己寫的（`tabs.lua`），因為 bufferline 不能替 tab 命名。tab 名稱存在 `vim.t.name`，沒設就用 tab cwd 的資料夾名。**重開 nvim 不保留 tab 名稱**。
- `\\` 列出**所有 tab** 的 buffer（讀 scope.core.cache），選到已在某視窗開著的就直接跳過去。

### 外觀：毛玻璃
- Ghostty 設定（`~/Library/Application Support/com.mitchellh.ghostty/config`）：`background-opacity = 0.66`、`background-blur-radius = 15`、**`background-opacity-cells = true`**（讓有底色的格子也半透明＋模糊；備份 `config.bak-20261105`）。
- nvim 浮動視窗底色 `#2b3a46`（`colorscheme.lua` 的 `frost`），比編輯區亮一點 → 看得出是另一層玻璃。調亮/調暗改 `frost`；整體透明度改 Ghostty。
- telescope `winblend = 0`（winblend 只能混 nvim 內容，透不到桌布，留著只會讓字變淡）。

### LSP
- 0.12 原生 `vim.lsp.config()` / `vim.lsp.enable()`，設定來自 nvim-lspconfig 的 `lsp/`。工具由 mason-tool-installer 自動裝。
- Ruby 用 **rbenv 裡的 ruby-lsp**（不是 Mason），會跟專案的 `.ruby-version` 走。全域 Ruby 是 system，沒裝 ruby-lsp → 沒 `.ruby-version` 的資料夾不會啟動（正常）。第一次開專案 ruby-lsp 會先裝 gem，要等幾十秒。
- Vue：vtsls + `@vue/typescript-plugin`（hybrid mode）+ vue_ls。
- `gI`：TS/Vue 跳到真正原始碼（vtsls `goToSourceDefinition`），不是 `.d.ts`。

### Treesitter
- nvim-treesitter **main** branch，需要 `tree-sitter` CLI（由 Mason 的 `tree-sitter-cli` 提供）。全新安裝時第一次啟動 parser 會編譯失敗，等 Mason 裝完再 `:TSUpdate` 即可。

## Keymap 規則

完整清單：`<leader>?`（HTML 速查頁，中英對照，從實際 keymap 即時產生）或 `;k`（telescope）。

| 前綴 | 用途 |
|---|---|
| `;` | 快速 picker（`;f` 檔案 `;r` grep `;w` 字 `;o` 最近 `;s` 符號 `;g` git 變更 `;e` 診斷 `;T` TODO `;n` 通知 `;k` keymap `;;` 回上次） |
| `<leader>a` | agent（`ac` Claude `ax` Codex `ag` Gemini `as` 選擇/接回 `at/af/av` 送內容 `ap` 提示詞） |
| `<leader><tab>` / `<leader>1-9` / `<tab>` `<S-tab>` | tab |
| `<leader>b` | buffer |
| `<leader>c` | 程式碼 / LSP |
| `<leader>d` | diff / 審查（`dv` CodeDiff） |
| `<leader>g` | git（`gw` worktree 列表、`gW` 新 worktree、`gh` stage hunk…） |
| `<leader>s` | 搜尋取代（grug-far；`<S-f>` 全專案） |
| `<leader>u` | 開關（snacks toggle） |
| `<leader>w` | 視窗 |
| `<leader>y` | 複製路徑（`yf` 路徑#L行號、選取後 `yc` code block） |

新增 keymap 時：
- 一定要寫 `desc`（which-key 和速查頁都靠它）。
- 在 `cheatsheet_zh.lua` 補中文翻譯；沒補只會顯示英文，不會壞。
- LSP / gitsigns 這類 buffer-local 的鍵加在 `buffer_keys.lua`，速查頁才能在沒 attach 時也列出。
- 速查頁分類規則在 `cheatsheet.lua` 的 `categories`（Lua pattern，比對顯示用 lhs，leader 顯示為 `Space `）。
- **Vim 原生鍵**（不是 mapping，`nvim_get_keymap` 看不到）手寫在 `cheatsheet_vim.lua`，每筆 `{ lhs, 英文, 中文, modes }`，
  `{c}`/`{m}`/`{r}`… 是佔位符、`:` 開頭是 ex 指令、空白分隔表示「或」。你自己 remap 過的同一個鍵＋模式會自動隱藏原生版本。
  頁面有「全部 / 自訂 / Vim 原生」篩選。

## 驗證方式（改完設定跑這些）

```sh
# 啟動無錯誤 + 啟動時間（目前約 60–70ms）
nvim --headless --startuptime /tmp/st.log +qa && tail -1 /tmp/st.log

# 同步插件
nvim --headless "+Lazy! sync" +qa

# 某個 keymap 是否存在（VeryLazy 綁的鍵在 headless 要手動觸發）
nvim --headless -c "lua vim.api.nvim_exec_autocmds('User',{pattern='VeryLazy'}) print(vim.fn.maparg('<leader>uh','n'))" +qa

# 重新產生速查頁（不開瀏覽器）
nvim --headless -c "lua require('config.cheatsheet').write()" +qa   # → ~/.cache/nvim/keymaps.html
```

注意：
- headless 不會觸發 `VeryLazy`，toggle / which-key 相關的鍵要手動 `nvim_exec_autocmds`。
- 測試時開的 sidekick/tmux session 要記得關，別留在 `tmux ls`。
- 不要替 Leo commit（這個資料夾有 `git init`，但 commit 由 Leo 自己做）。
