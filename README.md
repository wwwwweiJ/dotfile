# dotfile

My macOS setup.

| Folder | What | Linked to |
|---|---|---|
| `nvim/` | Hand-written Neovim config (lazy.nvim, not LazyVim): multi-agent via sidekick.nvim, worktree workspaces, per-tab buffers, HTML keymap cheat sheet (`<leader>?`) | `~/.config/nvim` |
| `ghostty/` | Ghostty terminal: JetBrains Mono, frosted-glass transparency | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `fastfetch/` | Fastfetch with a custom ASCII logo | `~/.config/fastfetch` |

## 換新電腦 / New machine

1. **Clone 並建立 symlink**

   ```sh
   git clone https://github.com/wwwwweiJ/dotfile.git ~/dotfile
   ~/dotfile/install.sh
   ```

   `install.sh` 會把每個資料夾 symlink 到對應位置；原本已經存在的檔案會先改名成 `*.pre-dotfile-<時間>` 備份。重複執行是安全的。

2. **打開 nvim**

   ```sh
   nvim
   ```

   第一次開啟時，lazy.nvim 會自動安裝插件，Mason 會自動安裝 LSP 和格式化工具（`tree-sitter` CLI 也是由 Mason 安裝）。
   如果第一次開啟時 Treesitter parser 編譯失敗，等 Mason 裝完後重開 nvim 再執行 `:TSUpdate` 即可。

3. **（選用）tabline 的 agent 狀態**

   要讓 tabline 顯示每個 agent 正在執行 / 等你回覆 / 已完成，需要把 hook 加進 Claude Code（只需要執行一次，不會覆蓋既有的 hook）：

   ```sh
   ~/.config/nvim/bin/install-agent-hooks
   ```

Neovim 的設計、快捷鍵和驗證方式寫在 [`nvim/CLAUDE.md`](nvim/CLAUDE.md)；在 nvim 裡按 `<leader>?` 可以打開快捷鍵速查頁。
