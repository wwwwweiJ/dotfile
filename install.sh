#!/bin/sh
# Symlink these dotfiles into place. Safe to re-run.
# Anything already at a target (and not already our link) is moved to <target>.pre-dotfile-<date>.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

link() { # link <source-in-repo> <target>
  src="$DIR/$1"; dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "ok      $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.pre-dotfile-$STAMP"; echo "backup  $dst -> $dst.pre-dotfile-$STAMP"; fi
  ln -s "$src" "$dst"; echo "linked  $dst -> $src"
}

link nvim      "$HOME/.config/nvim"
link fastfetch "$HOME/.config/fastfetch"
link ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
