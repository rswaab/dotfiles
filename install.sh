#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"
echo ""

# Helper: create symlink, backing up any existing file
link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    # Already a symlink — remove and recreate
    rm "$dest"
  elif [ -f "$dest" ]; then
    # Existing real file — back it up
    echo "  Backing up $dest -> ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dest")"

  ln -sf "$src" "$dest"
  echo "  Linked $dest -> $src"
}

echo "--- Shell ---"
link "$DOTFILES/zsh/.zshrc"       "$HOME/.zshrc"
link "$DOTFILES/zsh/.zprofile"    "$HOME/.zprofile"

echo "--- Tmux ---"
link "$DOTFILES/tmux/.tmux.conf"  "$HOME/.tmux.conf"

echo "--- Git ---"
link "$DOTFILES/git/.gitconfig"   "$HOME/.gitconfig"

echo "--- npm ---"
link "$DOTFILES/npm/.npmrc"       "$HOME/.npmrc"

echo "--- WezTerm ---"
link "$DOTFILES/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

echo "--- Karabiner ---"
link "$DOTFILES/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

echo "--- GitHub CLI ---"
link "$DOTFILES/gh/config.yml"    "$HOME/.config/gh/config.yml"

echo ""
echo "Done! All dotfiles are symlinked."
echo ""
echo "Optional next steps:"
echo "  - Run 'brew bundle' in $DOTFILES to install Homebrew packages"
echo "  - Run 'bash $DOTFILES/scripts/finder_master_setup.sh' to configure Finder"
