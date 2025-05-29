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

# Function to detect package manager
detect_package_manager() {
    if command_exists pacman; then
        echo "pacman"
    elif command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists zypper; then
        echo "zypper"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Function to install packages based on package manager
install_packages() {
    local pm="$1"
    shift
    local packages=("$@")
    
    case "$pm" in
        pacman)
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        apt)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
        zypper)
            sudo zypper install -y "${packages[@]}"
            ;;
        brew)
            brew install "${packages[@]}"
            ;;
        *)
            print_error "Unknown package manager. Please install packages manually."
            echo "Required packages: ${packages[*]}"
            return 1
            ;;
    esac
}

# Function to install essential packages
install_essential_packages() {
    print_header "INSTALLING ESSENTIAL PACKAGES"
    
    local pm=$(detect_package_manager)
    print_status "Detected package manager: $pm"
    
    case "$pm" in
        pacman)
            local packages=(
                "zsh" "git" "curl" "wget" "base-devel"
                "neovim" "wezterm" "kitty"
                "hyprland" "waybar" "rofi-wayland" "dunst" "wlogout"
                "fastfetch" "starship" "cava" "mpv"
                "gtk3" "gtk4" "qt5ct" "qt6ct" "kvantum"
                "nvm" "thefuck" "lazygit"
                "ttf-fira-code" "ttf-jetbrains-mono" "noto-fonts"
                "pipewire" "pipewire-pulse" "pavucontrol"
                "firefox" "nautilus" "code"
            )
            install_packages "$pm" "${packages[@]}"
            
            # Install yay if not present
            if ! command_exists yay; then
                print_status "Installing yay AUR helper..."
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay
                makepkg -si --noconfirm
                cd "$DOTFILES_DIR"
                rm -rf /tmp/yay
            fi
            
            # Install AUR packages
            if command_exists yay; then
                print_status "Installing AUR packages..."
                local aur_packages=(
                    "hyde-cli-git"
                    "spicetify-cli"
                    "visual-studio-code-bin"
                    "spotify"
                    "discord"
                )
                yay -S --needed --noconfirm "${aur_packages[@]}" || print_warning "Some AUR packages failed to install"
            fi
            ;;
        apt)
            # Update package list
            sudo apt update
            
            local packages=(
                "zsh" "git" "curl" "wget" "build-essential"
                "neovim" "kitty"
                "rofi" "dunst"
                "fastfetch" "cava" "mpv"
                "qt5ct"
                "fonts-firacode" "fonts-jetbrains-mono"
                "pipewire" "pavucontrol"
                "firefox" "nautilus" "code"
            )
            install_packages "$pm" "${packages[@]}"
            print_warning "Some packages like Hyprland, WezTerm, Waybar might need manual installation on Ubuntu/Debian"
            print_warning "You may need to add additional repositories for some packages"
            ;;
        *)
            print_warning "Please install the required packages manually for your distribution"
            ;;
    esac
    
    print_success "Essential packages installation completed"
}

# Function to install Oh My Zsh and plugins
setup_zsh() {
    print_header "SETTING UP ZSH ENVIRONMENT"
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_warning "Oh My Zsh already installed"
    fi
    
    # Install Powerlevel10k
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        print_success "Powerlevel10k installed"
    else
        print_warning "Powerlevel10k already installed"
    fi
    
    # Install useful zsh plugins
    print_status "Installing useful zsh plugins..."
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    fi
    
    # zsh-completions
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$plugins_dir/zsh-completions"
    fi
    
    print_success "Zsh plugins installed"
    
    # Set zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_status "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        print_success "Zsh set as default shell (will take effect on next login)"
    else
        print_warning "Zsh is already the default shell"
    fi
}

# Function to install Node.js and tools
setup_nodejs() {
    print_header "SETTING UP NODE.JS ENVIRONMENT"
    
    if [[ ! -d "$HOME/.config/nvm" ]]; then
        print_status "Installing NVM and Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.config/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install node
        nvm install --lts
        nvm use --lts
        print_success "Node.js installed via NVM"
    else
        print_warning "NVM already installed"
    fi
}

# Function to install additional tools
setup_additional_tools() {
    print_header "INSTALLING ADDITIONAL TOOLS"
    
    # Install Spicetify
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

# Function to show final instructions
show_final_instructions() {
    print_header "SETUP COMPLETED!"
    
    echo -e "${GREEN}🎉 Your system has been set up with your complete configuration!${NC}"
    echo ""
    print_status "What was installed:"
    print_status "✓ All essential packages for your environment"
    print_status "✓ Zsh with Oh My Zsh and Powerlevel10k"
    print_status "✓ All your application configurations"
    print_status "✓ Complete theme and appearance settings"
    print_status "✓ Development tools and environments"
    echo ""
    print_status "Next steps:"
    print_status "1. Restart your terminal or run 'exec zsh'"
    print_status "2. Run 'p10k configure' to set up Powerlevel10k"
    print_status "3. Restart your window manager/desktop environment"
    print_status "4. Open applications to verify configurations loaded correctly"
    echo ""
    print_status "Your system should now be identical to your original setup!"
    echo ""
    print_warning "Remember to:"
    print_warning "- Update your Git configuration if needed"
    print_warning "- Install any additional applications you use"
    print_warning "- Set up your wallpapers and personal preferences"
}

# Main function
main() {
    clear
    print_header "COMPLETE SYSTEM SETUP"
    echo -e "${BLUE}This script will set up your entire system to match your original configuration.${NC}"
    echo -e "${BLUE}It will install packages, configure shell, and link all your dotfiles.${NC}"
    echo ""
    
    # Confirm before proceeding
    read -p "Do you want to proceed with the complete setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled."
        exit 0
    fi
    
    # Run all setup steps
    install_essential_packages
    setup_zsh
    setup_nodejs
    setup_additional_tools
    backup_existing_configs
    install_dotfiles
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