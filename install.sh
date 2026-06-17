#!/usr/bin/env bash
#
# install.sh — Dotfiles Bootstrap Installer
#
# Symlinks all config files from this repository to their proper locations.
# Creates backups of existing configs before overwriting.
#
# Usage: ./install.sh [--help] [--no-backup]
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/Backups/dotfiles-$(date +%Y%m%d-%H%M%S)"
DO_BACKUP=true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

cleanup() {
    local src="$1"
    local dest="$2"
    if [[ -L "$dest" ]]; then
        rm -f "$dest"
        log_info "Removed existing symlink: $dest"
    fi
}

backup() {
    local dest="$1"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -rL "$dest" "$BACKUP_DIR/${dest##*/}" 2>/dev/null || true
        log_warn "Backed up $dest → $BACKUP_DIR"
    fi
}

install_symlink() {
    local src="$1"
    local dest="$2"

    if [[ ! -e "$src" ]]; then
        log_warn "Source not found: $src (skipping)"
        return
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"

    # Remove existing symlink
    [[ -L "$dest" ]] && rm -f "$dest"

    # Backup existing file/directory
    if $DO_BACKUP; then
        backup "$dest"
    fi

    # Remove existing file/directory
    [[ -e "$dest" ]] && rm -rf "$dest"

    # Create symlink
    ln -s "$src" "$dest"
    log_ok "Linked $src → $dest"
}

# ── Parse arguments ──────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            echo "Usage: $0 [--no-backup]"
            exit 0
            ;;
        --no-backup)
            DO_BACKUP=false
            ;;
    esac
done

# ── Pre-flight checks ────────────────────────────────────────────────────────

if [[ ! -d "$DOTFILES_DIR/config" ]]; then
    log_error "Could not find config/ directory. Run this script from the dotfiles root."
    exit 1
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Dotfiles Installer                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Link ~/.config/* directories ──────────────────────────────────────

log_info "Linking config directories to ~/.config/..."

while IFS= read -r -d '' config_dir; do
    dir_name=$(basename "$config_dir")
    dest="$HOME/.config/$dir_name"

    # Skip special dirs
    [[ "$dir_name" == "user" ]] && continue
    [[ "$dir_name" == "generated" ]] && continue

    install_symlink "$config_dir" "$dest"
done < <(find "$DOTFILES_DIR/config" -maxdepth 1 -mindepth 1 -type d -print0)

# ── Step 2: Link home dotfiles ────────────────────────────────────────────────

log_info "Linking home dotfiles..."

if [[ -d "$DOTFILES_DIR/home" ]]; then
    while IFS= read -r -d '' file; do
        filename=$(basename "$file")
        dest="$HOME/$filename"
        install_symlink "$file" "$dest"
    done < <(find "$DOTFILES_DIR/home" -maxdepth 1 -type f -print0)
fi

# ── Step 3: Link utility scripts ──────────────────────────────────────────────

log_info "Linking scripts to ~/.local/bin/..."

mkdir -p "$HOME/.local/bin"

if [[ -d "$DOTFILES_DIR/scripts" ]]; then
    while IFS= read -r -d '' script; do
        script_name=$(basename "$script")
        dest="$HOME/.local/bin/$script_name"

        # Skip env files (handled separately)
        [[ "$script_name" == "env" || "$script_name" == "env.fish" ]] && continue

        chmod +x "$script" 2>/dev/null || true
        install_symlink "$script" "$dest"
    done < <(find "$DOTFILES_DIR/scripts" -maxdepth 1 -type f -print0)
fi

# ── Step 4: Set up PATH helper ────────────────────────────────────────────────

log_info "Setting up PATH helper..."

ENV_SRC="$DOTFILES_DIR/scripts/env"
ENV_FISH_SRC="$DOTFILES_DIR/scripts/env.fish"
ENV_DEST="$HOME/.local/share/../bin/env"
ENV_FISH_DEST="$HOME/.local/share/../bin/env.fish"

if [[ -f "$ENV_SRC" ]]; then
    mkdir -p "$(dirname "$ENV_DEST")"
    cp "$ENV_SRC" "$ENV_DEST"
    log_ok "Installed env → $ENV_DEST"
fi

if [[ -f "$ENV_FISH_SRC" ]]; then
    mkdir -p "$(dirname "$ENV_FISH_DEST")"
    cp "$ENV_FISH_SRC" "$ENV_FISH_DEST"
    log_ok "Installed env.fish → $ENV_FISH_DEST"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""

if $DO_BACKUP && [[ -d "$BACKUP_DIR" ]]; then
    log_info "Backups saved to: $BACKUP_DIR"
fi

log_info "You may need to log out and back in for all changes to take effect."
echo ""
log_warn "Next steps:"
echo "  1. Verify keybindings: Super + T (terminal), Super + M (close)"
echo "  2. Generate colors: matugen image ~/wallpaper.jpg"
echo "  3. Restart waybar: waybar & disown"
echo ""

# ── Secret scan reminder ──────────────────────────────────────────────────────

if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    log_warn "REMINDER: Run a secret scan before pushing to GitHub:"
    echo "  cd $DOTFILES_DIR"
    echo "  git diff --cached | grep -iE '(api[_-]?key|secret|token|password|credential)' || true"
    echo ""
fi
