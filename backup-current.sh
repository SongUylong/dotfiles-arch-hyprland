#!/bin/bash

# Backup Current Configurations Script
# This script backs up your current dotfiles before installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to backup file or directory
backup_item() {
    local item="$1"
    local source="$HOME/$item"
    
    if [[ -e "$source" && ! -L "$source" ]]; then
        local target="$BACKUP_DIR/$item"
        mkdir -p "$(dirname "$target")"
        cp -r "$source" "$target"
        print_success "Backed up $item"
    elif [[ -L "$source" ]]; then
        print_warning "$item is a symlink, skipping backup"
    else
        print_warning "$item not found, skipping"
    fi
}

main() {
    print_status "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    print_status "Backing up current configurations..."
    
    # Home directory dotfiles
    local home_files=(
        ".zshrc"
        ".zshenv" 
        ".gitconfig"
        ".p10k.zsh"
        ".gtkrc-2.0"
    )
    
    for file in "${home_files[@]}"; do
        backup_item "$file"
    done
    
    # Config directories
    local config_dirs=(
        ".config/hypr"
        ".config/hyde"
        ".config/waybar"
        ".config/rofi"
        ".config/nvim"
        ".config/wezterm"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/qt5ct"
        ".config/qt6ct"
        ".config/Kvantum"
        ".config/dunst"
        ".config/wlogout"
        ".config/starship"
        ".config/fastfetch"
    )
    
    for dir in "${config_dirs[@]}"; do
        backup_item "$dir"
    done
    
    print_success "Backup completed!"
    print_status "Backup saved to: $BACKUP_DIR"
    print_status "You can restore any configuration by copying from this backup directory"
}

main "$@" 