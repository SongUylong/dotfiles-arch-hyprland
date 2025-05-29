# My Dotfiles

Personal configuration files for my development environment.

## What's Included

- **Shell Configuration**: Zsh with Oh My Zsh, Powerlevel10k theme
- **Terminal**: Kitty terminal configuration
- **Window Manager**: Hyprland configuration
- **Status Bar**: Waybar configuration
- **Launcher**: Rofi configuration
- **Editor**: Neovim and VS Code settings
- **Git**: Global git configuration
- **Themes**: GTK, Qt, and system theming
- **Applications**: Various app configurations

## Quick Setup

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the install script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. For first-time setup on a new machine:
   ```bash
   ./setup-new-machine.sh
   ```

## Manual Setup

If you prefer manual installation, you can selectively link configurations:

```bash
# Link specific configurations
./install.sh --zsh
./install.sh --hyprland
./install.sh --nvim
# etc.
```

## Backup Current Config

Before installing, backup your current configurations:
```bash
./backup-current.sh
```

## Structure

```
dotfiles/
├── config/           # ~/.config/ contents
├── home/             # Home directory dotfiles
├── scripts/          # Utility scripts
├── install.sh        # Main installation script
├── backup-current.sh # Backup existing configs
└── setup-new-machine.sh # Initial setup for new machines
```

## Customization

Feel free to modify any configurations to suit your needs. The scripts are designed to be modular and safe. 