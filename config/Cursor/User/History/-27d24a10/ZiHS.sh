#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks to your dotfiles configurations

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
    
    local home_files=(
        ".zshrc"
        ".zshenv"
        ".gitconfig"
        ".p10k.zsh"
        ".gtkrc-2.0"
    )
    
    for file in "${home_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/home/$file" ]]; then
            create_symlink "$DOTFILES_DIR/home/$file" "$HOME/$file"
        fi
    done
}

# Function to install config directory
install_config_dotfiles() {
    print_status "Installing .config directory dotfiles..."
    
    # Find all directories in dotfiles/config and link them
    if [[ -d "$DOTFILES_DIR/config" ]]; then
        for config_dir in "$DOTFILES_DIR/config"/*; do
            if [[ -d "$config_dir" ]]; then
                local dir_name=$(basename "$config_dir")
                create_symlink "$config_dir" "$HOME/.config/$dir_name"
            fi
        done
    fi
}

# Function to show help
show_help() {
    cat << EOF
Dotfiles Installation Script

Usage: $0 [OPTIONS]

OPTIONS:
    --home          Install only home directory dotfiles
    --config        Install only .config directory dotfiles
    --zsh           Install only zsh configurations
    --hyprland      Install only Hyprland configuration
    --hyde          Install only HyDE configuration
    --nvim          Install only Neovim configuration
    --help, -h      Show this help message

Default behavior (no options): Install all dotfiles

Examples:
    $0                  # Install all dotfiles
    $0 --zsh --nvim     # Install only zsh and nvim configs
    $0 --home           # Install only home directory dotfiles

EOF
}

# Main installation function
main() {
    print_status "Starting dotfiles installation..."
    print_status "Dotfiles directory: $DOTFILES_DIR"
    
    # Parse command line arguments
    install_all=true
    install_home=false
    install_config=false
    
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
            --zsh)
                install_all=false
                create_symlink "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
                create_symlink "$DOTFILES_DIR/home/.zshenv" "$HOME/.zshenv"
                create_symlink "$DOTFILES_DIR/home/.p10k.zsh" "$HOME/.p10k.zsh"
                shift
                ;;
            --hyprland)
                install_all=false
                if [[ -d "$DOTFILES_DIR/config/hypr" ]]; then
                    create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
                fi
                shift
                ;;
            --hyde)
                install_all=false
                if [[ -d "$DOTFILES_DIR/config/hyde" ]]; then
                    create_symlink "$DOTFILES_DIR/config/hyde" "$HOME/.config/hyde"
                fi
                shift
                ;;
            --nvim)
                install_all=false
                if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
                    create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
                fi
                shift
                ;;
            --wezterm)
                install_all=false
                if [[ -d "$DOTFILES_DIR/config/wezterm" ]]; then
                    create_symlink "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"
                fi
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
    else
        if [[ "$install_home" == true ]]; then
            install_home_dotfiles
        fi
        if [[ "$install_config" == true ]]; then
            install_config_dotfiles
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
}

# Run main function
main "$@" 