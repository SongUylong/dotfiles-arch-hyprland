#!/bin/bash

# Simplified System Setup Script
# This script will install HyDE first, then add additional packages and configs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install HyDE
install_hyde() {
    print_header "INSTALLING HYDE ENVIRONMENT"
    
    # Check if HyDE directory exists
    if [[ ! -d "$HOME/HyDE" ]]; then
        print_status "Cloning HyDE repository..."
        cd "$HOME"
        git clone --depth 1 https://github.com/prasanthrangan/hyprdots.git HyDE
    else
        print_status "HyDE directory found at $HOME/HyDE"
    fi

    if [[ -d "$HOME/HyDE" ]]; then
        cd "$HOME/HyDE/Scripts"
        
        print_status "Starting HyDE installation..."
        print_warning "Please follow the HyDE installer prompts to complete the installation"
        print_warning "Choose your preferred configuration options when prompted"
        
        if ./install.sh; then
            print_success "HyDE installation completed successfully"
        else
            print_error "HyDE installation failed"
            exit 1
        fi
        
        cd "$DOTFILES_DIR"
    else
        print_error "Failed to find or clone HyDE repository"
        exit 1
    fi
}

# Function to install additional packages
install_additional_packages() {
    print_header "INSTALLING ADDITIONAL PACKAGES"
    
    if command_exists pacman; then
        print_status "Installing additional packages..."
        
        local additional_packages=(
            "wezterm"           # Terminal
            "firefox"           # Browser
            "neovim"           # Editor
            "lazygit"          # Git TUI
            "thefuck"          # Command correction
            "btop"             # System monitor
            "ripgrep"          # Fast search
            "fd"               # Fast find
            "fzf"              # Fuzzy finder
        )
        
        sudo pacman -S --needed --noconfirm "${additional_packages[@]}" || print_warning "Some packages failed to install"
        
        # Install AUR packages if yay is available
        if command_exists yay; then
            print_status "Installing additional AUR packages..."
            local aur_packages=(
                "visual-studio-code-bin"
            )
            yay -S --needed --noconfirm "${aur_packages[@]}" || print_warning "Some AUR packages failed to install"
        fi
    else
        print_error "Pacman not found - this script requires Arch Linux"
        exit 1
    fi
    
    print_success "Additional packages installation completed"
}

# Function to install dotfiles
install_dotfiles() {
    print_header "INSTALLING PERSONAL DOTFILES"
    
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
        
        # Remove existing file/symlink
        if [[ -e "$target" || -L "$target" ]]; then
            rm -rf "$target"
        fi
        
        # Create symlink
        ln -sf "$source" "$target"
        print_success "Linked $source -> $target"
    }
    
    # Install config files
    if [[ -d "$DOTFILES_DIR/config" ]]; then
        print_status "Installing .config files..."
        for item in "$DOTFILES_DIR/config"/*; do
            if [[ -e "$item" ]]; then
                local item_name=$(basename "$item")
                create_symlink "$item" "$HOME/.config/$item_name"
            fi
        done
    fi
    
    # Install home dotfiles
    if [[ -d "$DOTFILES_DIR/home" ]]; then
        print_status "Installing home dotfiles..."
        for file in "$DOTFILES_DIR/home"/*; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                create_symlink "$file" "$HOME/$filename"
            fi
        done
    fi
    
    print_success "Personal dotfiles installation completed"
}

# Function to show final instructions
show_final_instructions() {
    print_header "SETUP COMPLETED!"
    
    echo -e "${GREEN}🎉 Your system has been set up successfully!${NC}"
    echo ""
    print_status "What was installed:"
    print_status "✓ HyDE (Hyprland Desktop Environment)"
    print_status "✓ Additional packages (WezTerm, Firefox, Neovim, etc.)"
    print_status "✓ Your personal dotfiles"
    echo ""
    print_status "Next steps:"
    print_status "1. Restart your system to ensure all changes take effect"
    print_status "2. Choose Hyprland from your display manager login screen"
    echo ""
    print_warning "If you encounter any issues:"
    print_warning "- Check HyDE documentation at ~/HyDE/"
    print_warning "- Run 'hyprctl reload' to reload Hyprland config"
    print_warning "- Check logs in ~/.cache/hypr/hyprland.log"
}

# Main function
main() {
    clear
    print_header "SYSTEM SETUP SCRIPT"
    echo -e "${BLUE}This script will:${NC}"
    echo -e "${YELLOW}1. Install HyDE (Hyprland Desktop Environment)${NC}"
    echo -e "${YELLOW}2. Install additional packages${NC}"
    echo -e "${YELLOW}3. Install your personal dotfiles${NC}"
    echo ""
    print_warning "This will take some time and requires internet connection"
    print_warning "You will need to interact with the HyDE installer"
    echo ""
    
    # Confirm before proceeding
    read -p "Do you want to proceed with the setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled."
        exit 0
    fi
    
    # Run setup steps
    install_hyde
    install_additional_packages
    install_dotfiles
    show_final_instructions
}

# Check if running on Arch Linux
if ! command_exists pacman; then
    print_error "This script requires Arch Linux"
    exit 1
fi

# Run main function
main "$@" 