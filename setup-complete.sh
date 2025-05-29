#!/bin/bash

# Complete System Setup Script
# This single script will set up your entire system exactly like your current setup

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
    if [[ -d "$HOME/HyDE" ]]; then
        print_status "HyDE directory found at $HOME/HyDE"
        print_status "Running HyDE installation script..."
        
        cd "$HOME/HyDE/Scripts"
        
        # Run HyDE install script with default options
        print_status "Starting HyDE installation (this may take a while)..."
        if ./install.sh -d; then
            print_success "HyDE installation completed successfully"
        else
            print_warning "HyDE installation encountered issues, but continuing..."
        fi
        
        cd "$DOTFILES_DIR"
    else
        print_warning "HyDE directory not found at $HOME/HyDE"
        print_status "Cloning HyDE repository..."
        
        cd "$HOME"
        git clone --depth 1 https://github.com/prasanthrangan/hyprdots.git HyDE
        
        if [[ -d "$HOME/HyDE" ]]; then
            print_success "HyDE repository cloned successfully"
            cd "$HOME/HyDE/Scripts"
            
            print_status "Running HyDE installation..."
            if ./install.sh -d; then
                print_success "HyDE installation completed successfully"
            else
                print_warning "HyDE installation encountered issues, but continuing..."
            fi
            
            cd "$DOTFILES_DIR"
        else
            print_error "Failed to clone HyDE repository"
            print_error "Please install HyDE manually from: https://github.com/prasanthrangan/hyprdots"
            exit 1
        fi
    fi
}

# Function to install additional packages not covered by HyDE
install_additional_packages() {
    print_header "INSTALLING ADDITIONAL PACKAGES"
    
    # Check if we have pacman (Arch Linux)
    if command_exists pacman; then
        print_status "Installing additional packages..."
        
        local additional_packages=(
            "wezterm"           # Your preferred terminal
            "neovim"            # Your editor
            "lazygit"           # Git TUI
            "thefuck"           # Command correction
        )
        
        sudo pacman -S --needed --noconfirm "${additional_packages[@]}" || print_warning "Some additional packages failed to install"
        
        # Install AUR packages if yay is available
        if command_exists yay; then
            print_status "Installing additional AUR packages..."
            local aur_packages=(
                "spicetify-cli"
                "visual-studio-code-bin"
            )
            yay -S --needed --noconfirm "${aur_packages[@]}" || print_warning "Some AUR packages failed to install"
        fi
    else
        print_warning "Not on Arch Linux - skipping additional package installation"
        print_warning "Please install wezterm, neovim, and other tools manually"
    fi
    
    print_success "Additional packages installation completed"
}

# Function to install Node.js and tools
setup_nodejs() {
    print_header "SETTING UP NODE.JS ENVIRONMENT"
    
    # Check both common NVM locations
    if [[ ! -d "$HOME/.nvm" && ! -d "$HOME/.config/nvm" ]]; then
        print_status "Installing NVM and Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Source NVM - check multiple possible locations
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            source "$NVM_DIR/nvm.sh"
        elif [[ -s "$HOME/.config/nvm/nvm.sh" ]]; then
            export NVM_DIR="$HOME/.config/nvm"
            source "$NVM_DIR/nvm.sh"
        else
            print_error "NVM installation failed - nvm.sh not found"
            return 1
        fi
        
        # Install Node.js versions
        print_status "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        
        print_status "Installing latest Node.js..."
        nvm install node
        
        print_success "Node.js installed via NVM"
    else
        print_warning "NVM already installed"
        
        # Try to source existing NVM
        if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
            export NVM_DIR="$HOME/.nvm"
            source "$NVM_DIR/nvm.sh"
        elif [[ -s "$HOME/.config/nvm/nvm.sh" ]]; then
            export NVM_DIR="$HOME/.config/nvm"
            source "$NVM_DIR/nvm.sh"
        fi
        
        # Check if nvm is available now
        if command_exists nvm; then
            print_status "NVM is available and ready to use"
        else
            print_warning "NVM installed but not available in current session"
            print_warning "You may need to restart your terminal to use Node.js"
        fi
    fi
}

# Function to install Spicetify
setup_spicetify() {
    print_header "SETTING UP SPICETIFY"
    
    # Install Spicetify if not available via package manager
    if ! command_exists spicetify; then
        print_status "Installing Spicetify..."
        curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
        print_success "Spicetify installed"
    else
        print_warning "Spicetify already installed"
    fi
}

# Function to backup existing configurations
backup_existing_configs() {
    print_header "BACKING UP EXISTING CONFIGURATIONS"
    
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local items_to_backup=(
        ".zshrc" ".zshenv" ".p10k.zsh" ".user.zsh"
        ".gitconfig" ".gtkrc-2.0" ".bashrc"
        ".config/hypr" ".config/waybar" ".config/rofi"
        ".config/dunst" ".config/nvim" ".config/wezterm"
        ".config/kitty" ".config/gtk-3.0" ".config/gtk-4.0"
        ".config/qt5ct" ".config/qt6ct" ".config/Kvantum"
        ".config/starship" ".config/fastfetch" ".config/cava"
        ".config/mpv" ".config/spicetify" ".config/hyde"
        ".config/wlogout" ".config/swayidle"
    )
    
    local backed_up=false
    for item in "${items_to_backup[@]}"; do
        local source="$HOME/$item"
        if [[ -e "$source" && ! -L "$source" ]]; then
            if [[ "$backed_up" == false ]]; then
                mkdir -p "$backup_dir"
                backed_up=true
            fi
            local target="$backup_dir/$item"
            mkdir -p "$(dirname "$target")"
            cp -r "$source" "$target"
            print_status "Backed up $item"
        fi
    done
    
    if [[ "$backed_up" == true ]]; then
        print_success "Backup completed: $backup_dir"
    else
        print_status "No existing configurations to backup"
    fi
}

# Function to install dotfiles
install_dotfiles() {
    print_header "INSTALLING DOTFILES"
    
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
    
    # Install home dotfiles
    print_status "Installing home directory dotfiles..."
    if [[ -d "$DOTFILES_DIR/home" ]]; then
        for file in "$DOTFILES_DIR/home"/*; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                create_symlink "$file" "$HOME/$filename"
            fi
        done
    fi
    
    # Install config dotfiles
    print_status "Installing .config directory dotfiles..."
    if [[ -d "$DOTFILES_DIR/config" ]]; then
        for item in "$DOTFILES_DIR/config"/*; do
            if [[ -e "$item" ]]; then
                local item_name=$(basename "$item")
                create_symlink "$item" "$HOME/.config/$item_name"
            fi
        done
    fi
    
    # Install other important directories
    print_status "Installing other important configurations..."
    if [[ -d "$DOTFILES_DIR/other" ]]; then
        for item in "$DOTFILES_DIR/other"/*; do
            if [[ -e "$item" ]]; then
                local item_name=$(basename "$item")
                create_symlink "$item" "$HOME/$item_name"
            fi
        done
    fi
    
    print_success "Dotfiles installation completed!"
}

# Function to run HyDE restore if available
run_hyde_restore() {
    print_header "RUNNING HYDE CONFIGURATION RESTORE"
    
    if [[ -f "$HOME/HyDE/Scripts/restore_cfg.sh" ]]; then
        print_status "Running HyDE configuration restore..."
        cd "$HOME/HyDE/Scripts"
        
        # Run HyDE restore script
        if ./restore_cfg.sh; then
            print_success "HyDE configuration restore completed"
        else
            print_warning "HyDE restore encountered issues, but continuing..."
        fi
        
        cd "$DOTFILES_DIR"
    else
        print_warning "HyDE restore script not found - skipping HyDE restore"
    fi
}

# Function to show final instructions
show_final_instructions() {
    print_header "SETUP COMPLETED!"
    
    echo -e "${GREEN}🎉 Your system has been set up with your complete configuration!${NC}"
    echo ""
    print_status "What was installed:"
    print_status "✓ Complete HyDE (Hyprland Desktop Environment)"
    print_status "✓ All essential packages via HyDE installer"
    print_status "✓ Your custom dotfiles and configurations"
    print_status "✓ Development tools and environments"
    print_status "✓ Node.js and Spicetify"
    echo ""
    print_status "Next steps:"
    print_status "1. Restart your system (recommended for first-time HyDE setup)"
    print_status "2. Choose Hyprland from your display manager login screen"
    print_status "3. Your system should now be identical to your original setup!"
    echo ""
    print_status "HyDE-specific features available:"
    print_status "- Super+T: Change themes"
    print_status "- Super+Shift+T: Toggle wallpaper"
    print_status "- Super+Ctrl+T: Toggle waybar"
    print_status "- Check KEYBINDINGS.md in HyDE directory for full list"
    echo ""
    print_warning "If you encounter any issues:"
    print_warning "- Check HyDE documentation at ~/HyDE/"
    print_warning "- Run 'Hyde restore' to restore HyDE configurations"
    print_warning "- Check logs in ~/.cache/hyde/logs/"
}

# Main function
main() {
    clear
    print_header "COMPLETE HYDE + DOTFILES SETUP"
    echo -e "${BLUE}This script will set up your entire system to match your original configuration.${NC}"
    echo -e "${BLUE}It will install HyDE (complete Hyprland environment) and your personal dotfiles.${NC}"
    echo ""
    echo -e "${YELLOW}This process includes:${NC}"
    echo -e "${YELLOW}1. Installing HyDE (Hyprland Desktop Environment)${NC}"
    echo -e "${YELLOW}2. Installing additional packages${NC}"
    echo -e "${YELLOW}3. Setting up development environment${NC}"
    echo -e "${YELLOW}4. Linking your personal dotfiles${NC}"
    echo -e "${YELLOW}5. Running HyDE configuration restore${NC}"
    echo ""
    print_warning "This will take some time and requires internet connection"
    echo ""
    
    # Confirm before proceeding
    read -p "Do you want to proceed with the complete setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled."
        exit 0
    fi
    
    # Run all setup steps
    backup_existing_configs
    install_hyde
    install_additional_packages
    setup_nodejs
    setup_spicetify
    install_dotfiles
    run_hyde_restore
    show_final_instructions
}

# Check if we're in the right directory
if [[ ! -d "$DOTFILES_DIR/config" || ! -d "$DOTFILES_DIR/home" ]]; then
    print_error "This script must be run from the dotfiles directory"
    print_error "Make sure you have the complete dotfiles structure with config/ and home/ directories"
    exit 1
fi

# Run main function
main "$@" 