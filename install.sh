#!/bin/bash

# Comprehensive Dotfiles Installation Script
# This script creates symlinks to your complete dotfiles configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing file/directory
backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        print_warning "Backing up existing $target"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        return 0
    elif [[ -L "$target" ]]; then
        print_warning "Removing existing symlink $target"
        rm "$target"
        return 0
    fi
    return 1
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -e "$source" ]]; then
        print_warning "Source $source does not exist, skipping..."
        return 1
    fi
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file if needed
    backup_if_exists "$target"
    
    # Create symlink
    ln -sf "$source" "$target"
    print_success "Linked $source -> $target"
}

# Function to install home dotfiles
install_home_dotfiles() {
    print_status "Installing home directory dotfiles..."
    
    # Get all files in dotfiles/home directory
    if [[ -d "$DOTFILES_DIR/home" ]]; then
        for file in "$DOTFILES_DIR/home"/*; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                create_symlink "$file" "$HOME/$filename"
            fi
        done
    fi
}

# Function to install config directory
install_config_dotfiles() {
    print_status "Installing .config directory dotfiles..."
    
    # Link all directories and files in dotfiles/config
    if [[ -d "$DOTFILES_DIR/config" ]]; then
        for item in "$DOTFILES_DIR/config"/*; do
            if [[ -e "$item" ]]; then
                local item_name=$(basename "$item")
                create_symlink "$item" "$HOME/.config/$item_name"
            fi
        done
    fi
}

# Function to install other important directories
install_other_dotfiles() {
    print_status "Installing other important configurations..."
    
    if [[ -d "$DOTFILES_DIR/other" ]]; then
        for item in "$DOTFILES_DIR/other"/*; do
            if [[ -e "$item" ]]; then
                local item_name=$(basename "$item")
                create_symlink "$item" "$HOME/$item_name"
            fi
        done
    fi
}

# Function to show help
show_help() {
    cat << EOF
Comprehensive Dotfiles Installation Script

Usage: $0 [OPTIONS]

OPTIONS:
    --home          Install only home directory dotfiles
    --config        Install only .config directory dotfiles
    --other         Install only other configurations (oh-my-zsh, spicetify, etc.)
    --zsh           Install only zsh configurations
    --hyprland      Install only Hyprland configuration
    --hyde          Install only HyDE configuration
    --nvim          Install only Neovim configuration
    --wezterm       Install only WezTerm configuration
    --themes        Install only theme configurations
    --help, -h      Show this help message

Default behavior (no options): Install all dotfiles

Examples:
    $0                  # Install all dotfiles
    $0 --zsh --nvim     # Install only zsh and nvim configs
    $0 --home           # Install only home directory dotfiles
    $0 --config --other # Install config and other directories

EOF
}

# Main installation function
main() {
    print_status "Starting comprehensive dotfiles installation..."
    print_status "Dotfiles directory: $DOTFILES_DIR"
    
    # Parse command line arguments
    install_all=true
    install_home=false
    install_config=false
    install_other=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --home)
                install_all=false
                install_home=true
                shift
                ;;
            --config)
                install_all=false
                install_config=true
                shift
                ;;
            --other)
                install_all=false
                install_other=true
                shift
                ;;
            --zsh)
                install_all=false
                [[ -f "$DOTFILES_DIR/home/.zshrc" ]] && create_symlink "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
                [[ -f "$DOTFILES_DIR/home/.zshenv" ]] && create_symlink "$DOTFILES_DIR/home/.zshenv" "$HOME/.zshenv"
                [[ -f "$DOTFILES_DIR/home/.p10k.zsh" ]] && create_symlink "$DOTFILES_DIR/home/.p10k.zsh" "$HOME/.p10k.zsh"
                [[ -f "$DOTFILES_DIR/home/.user.zsh" ]] && create_symlink "$DOTFILES_DIR/home/.user.zsh" "$HOME/.user.zsh"
                [[ -d "$DOTFILES_DIR/other/.oh-my-zsh" ]] && create_symlink "$DOTFILES_DIR/other/.oh-my-zsh" "$HOME/.oh-my-zsh"
                shift
                ;;
            --hyprland)
                install_all=false
                [[ -d "$DOTFILES_DIR/config/hypr" ]] && create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
                shift
                ;;
            --hyde)
                install_all=false
                [[ -d "$DOTFILES_DIR/config/hyde" ]] && create_symlink "$DOTFILES_DIR/config/hyde" "$HOME/.config/hyde"
                shift
                ;;
            --nvim)
                install_all=false
                [[ -d "$DOTFILES_DIR/config/nvim" ]] && create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
                shift
                ;;
            --wezterm)
                install_all=false
                [[ -d "$DOTFILES_DIR/config/wezterm" ]] && create_symlink "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"
                shift
                ;;
            --themes)
                install_all=false
                [[ -d "$DOTFILES_DIR/config/gtk-3.0" ]] && create_symlink "$DOTFILES_DIR/config/gtk-3.0" "$HOME/.config/gtk-3.0"
                [[ -d "$DOTFILES_DIR/config/gtk-4.0" ]] && create_symlink "$DOTFILES_DIR/config/gtk-4.0" "$HOME/.config/gtk-4.0"
                [[ -d "$DOTFILES_DIR/config/qt5ct" ]] && create_symlink "$DOTFILES_DIR/config/qt5ct" "$HOME/.config/qt5ct"
                [[ -d "$DOTFILES_DIR/config/qt6ct" ]] && create_symlink "$DOTFILES_DIR/config/qt6ct" "$HOME/.config/qt6ct"
                [[ -d "$DOTFILES_DIR/config/Kvantum" ]] && create_symlink "$DOTFILES_DIR/config/Kvantum" "$HOME/.config/Kvantum"
                [[ -f "$DOTFILES_DIR/home/.gtkrc-2.0" ]] && create_symlink "$DOTFILES_DIR/home/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Install based on flags
    if [[ "$install_all" == true ]]; then
        install_home_dotfiles
        install_config_dotfiles
        install_other_dotfiles
    else
        if [[ "$install_home" == true ]]; then
            install_home_dotfiles
        fi
        if [[ "$install_config" == true ]]; then
            install_config_dotfiles
        fi
        if [[ "$install_other" == true ]]; then
            install_other_dotfiles
        fi
    fi
    
    print_success "Dotfiles installation completed!"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        print_status "Backups saved to: $BACKUP_DIR"
    fi
    
    print_status "You may need to:"
    print_status "  - Restart your shell or run 'source ~/.zshrc'"
    print_status "  - Restart your window manager/desktop environment"
    print_status "  - Reopen applications to load new configurations"
    print_status "  - Run 'p10k configure' if using Powerlevel10k"
}

# Run main function
main "$@" 