# dotfile

My macOS setup.

| Folder | What | Linked to |
|---|---|---|
| `nvim/` | Hand-written Neovim config (lazy.nvim, not LazyVim): multi-agent via sidekick.nvim, worktree workspaces, per-tab buffers, HTML keymap cheat sheet (`<leader>?`) | `~/.config/nvim` |
| `ghostty/` | Ghostty terminal: JetBrains Mono, frosted-glass transparency | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `fastfetch/` | Fastfetch with a custom ASCII logo | `~/.config/fastfetch` |

## New machine

1. **Clone and symlink**

   ```sh
   git clone https://github.com/wwwwweiJ/dotfile.git ~/dotfile
   ~/dotfile/install.sh
   ```

   `install.sh` symlinks each folder into place. Anything already there is moved aside to `*.pre-dotfile-<timestamp>` first, so re-running it is safe.

2. **Open Neovim**

   ```sh
   nvim
   ```

   On first launch, lazy.nvim installs the plugins and Mason installs the LSP servers and formatters (including the `tree-sitter` CLI).
   If Treesitter parsers fail to compile on that first launch, wait for Mason to finish, restart nvim, and run `:TSUpdate`.

3. **(Optional) Agent status in the tabline**

   To show whether each agent is running, waiting for you, or done, add the hooks to Claude Code. Run this once; it keeps any existing hooks:

   ```sh
   ~/.config/nvim/bin/install-agent-hooks
   ```

Design notes, keymaps and how to verify changes are in [`nvim/CLAUDE.md`](nvim/CLAUDE.md). Inside Neovim, press `<leader>?` to open the keymap cheat sheet.
