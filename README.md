# My Comprehensive Dotfiles

Personal configuration files for my complete development environment. This includes ALL my configurations, themes, and application settings.

## What's Included

### Shell & Terminal
- **Zsh Configuration**: Complete zsh setup with Oh My Zsh
- **Powerlevel10k**: Beautiful and fast zsh theme
- **User Configurations**: Custom aliases and functions in `.user.zsh`
- **Environment Variables**: Complete environment setup in `.zshenv`

### Window Manager & Desktop
- **Hyprland**: Wayland compositor configuration
- **Waybar**: Status bar configuration
- **Rofi**: Application launcher and menu
- **Dunst**: Notification daemon
- **Wlogout**: Logout menu

### Development Tools
- **Neovim**: Complete Neovim configuration
- **VS Code**: Code settings and extensions
- **Git**: Global git configuration
- **WezTerm**: Terminal emulator configuration
- **Kitty**: Alternative terminal configuration

### Themes & Appearance
- **GTK 3.0 & 4.0**: GTK theme configurations
- **Qt5ct & Qt6ct**: Qt theme configurations
- **Kvantum**: Advanced Qt theming
- **System Icons & Themes**: Complete theming setup

### Applications
- **Spicetify**: Spotify customization
- **MPV**: Media player configuration
- **Cava**: Audio visualizer
- **Fastfetch**: System information display
- **Starship**: Cross-shell prompt
- **And much more**: All application configurations

### Other Important
- **Oh My Zsh**: Complete oh-my-zsh installation with plugins
- **Node.js/NVM**: Node Version Manager configuration
- **Various App Configs**: Cursor, GIMP, Joplin, etc.

## Quick Setup

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. For a completely new machine, run the setup script first:
   ```bash
   ./setup-new-machine.sh
   ```

3. Install the dotfiles:
   ```bash
   ./install.sh
   ```

## New Machine Setup

The `setup-new-machine.sh` script will:
- Detect your package manager (pacman, apt, dnf, etc.)
- Install all necessary dependencies
- Set up Oh My Zsh with Powerlevel10k
- Install useful zsh plugins
- Configure Node.js via NVM
- Set zsh as default shell

```bash
# Full setup
./setup-new-machine.sh

# Skip package installation
./setup-new-machine.sh --no-deps

# Skip shell setup
./setup-new-machine.sh --no-shell
```

## Selective Installation

Install specific configurations only:

```bash
# Shell configurations only
./install.sh --zsh

# Window manager setup
./install.sh --hyprland --hyde

# Development tools
./install.sh --nvim --wezterm

# Themes only
./install.sh --themes

# Config directory only
./install.sh --config

# Home dotfiles only
./install.sh --home

# Other important directories
./install.sh --other
```

## Backup Current Config

Always backup before installing:
```bash
./backup-current.sh
```

## Complete Structure

```
dotfiles/
├── config/                    # Complete ~/.config/ directory
│   ├── hypr/                  # Hyprland configuration
│   ├── waybar/                # Waybar configuration
│   ├── rofi/                  # Rofi configuration
│   ├── nvim/                  # Neovim configuration
│   ├── wezterm/               # WezTerm configuration
│   ├── dunst/                 # Notification configuration
│   ├── gtk-3.0/               # GTK3 themes
│   ├── gtk-4.0/               # GTK4 themes
│   ├── qt5ct/                 # Qt5 themes
│   ├── Kvantum/               # Kvantum themes
│   ├── spicetify/             # Spotify themes
│   ├── starship/              # Starship prompt
│   ├── fastfetch/             # System info
│   └── ... (and many more)
├── home/                      # Home directory dotfiles
│   ├── .zshrc                 # Zsh configuration
│   ├── .zshenv                # Zsh environment
│   ├── .p10k.zsh              # Powerlevel10k config
│   ├── .user.zsh              # Custom user config
│   ├── .gitconfig             # Git configuration
│   ├── .gtkrc-2.0             # GTK2 configuration
│   └── ... (all home dotfiles)
├── other/                     # Other important directories
│   ├── .oh-my-zsh/            # Complete Oh My Zsh
│   └── .spicetify/            # Spicetify installation
├── install.sh                 # Main installation script
├── backup-current.sh          # Backup existing configs
├── setup-new-machine.sh       # New machine setup
└── README.md                  # This file
```

## Safe Installation

- **Automatic Backups**: Existing configurations are automatically backed up
- **Symlinks**: Uses symlinks so you can easily update
- **Modular**: Install only what you need
- **Reversible**: Easy to remove or restore

## Post-Installation

After installing:

1. Restart your terminal or run `exec zsh`
2. If using Powerlevel10k, run `p10k configure`
3. Restart your window manager/desktop environment
4. Verify all applications load their configurations correctly

## Customization

All configurations are in the dotfiles directory. Modify them as needed:
- Edit files directly in the dotfiles directory
- Changes are immediately reflected (symlinks)
- Add new configurations by copying to the appropriate directory

## Maintenance

Keep your dotfiles updated:
```bash
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push
```

## Notes

- This setup is specifically designed for my Arch Linux + Hyprland environment
- Some configurations may need adjustment for other distributions
- The setup script includes detection for different package managers
- All important configurations are included - this is a complete backup of my setup 