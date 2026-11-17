# dotfile

My macOS setup.

| Folder | What | Linked to |
|---|---|---|
| `nvim/` | Hand-written Neovim config (lazy.nvim, not LazyVim): multi-agent via sidekick.nvim, worktree workspaces, per-tab buffers, HTML keymap cheat sheet (`<leader>?`) | `~/.config/nvim` |
| `ghostty/` | Ghostty terminal: JetBrains Mono, frosted-glass transparency | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `fastfetch/` | Fastfetch with a custom ASCII logo | `~/.config/fastfetch` |

## Install

```sh
git clone https://github.com/wwwwweiJ/dotfile.git ~/dotfile
~/dotfile/install.sh
```

`install.sh` symlinks each folder into place; anything already there is moved aside to `*.pre-dotfile-<timestamp>` first. Re-running it is safe.

Neovim details (design, keymaps, how to verify changes) are in [`nvim/CLAUDE.md`](nvim/CLAUDE.md).

The Neovim agent-status tabline needs Claude Code hooks: run `~/.config/nvim/bin/install-agent-hooks` once.
