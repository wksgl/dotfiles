# Dotfiles

My personal dotfiles configuration for Linux system.

## Contents

### Shell Configuration
- **Zsh**: `.zshrc`, `.zimrc`, Zim framework modules
- **Bash**: `.bashrc`, `.bash_profile`, `.bash_logout`
- **Starship**: Cross-shell prompt configuration

### Editor Configuration
- **Vim**: `.vimrc`, `.viminfo`

### Development Tools
- **Git**: `.gitconfig`
- **SSH**: SSH keys and known hosts
- **NPM**: NPM cache and configuration

### System Configuration
- **Config files**: Various `.config/` files including starship, kdeglobals, mimeapps, etc.
- **User directories**: `.config/user-dirs.dirs`, `.config/user-dirs.locale`

### Documents
- Linux font configuration notes
- Niri lock screen configuration
- Sing-box smart routing summary

### Wallpapers
- Collection of wallpapers in `Pictures/Wallpapers/`

### Network
- **Sing-box**: Configuration (located in `etc/sing-box/`)

## Installation

To use these dotfiles, you can manually copy the files to their respective locations or use the provided `copy_files.sh` script:

```bash
# Make the script executable
chmod +x copy_files.sh

# Run the script (some operations require sudo)
./copy_files.sh
```

Note: The script will copy files to appropriate locations, preserving the directory structure.

## Structure

The repository is organized to mirror the typical Linux filesystem structure:
- `home/` - User home directory files
- `.config/` - Configuration files
- `Documents/` - Documentation and notes
- `Pictures/Wallpapers/` - Wallpaper collection
- `etc/sing-box/` - System configuration

## Notes

1. SSH keys are included for reference but should be regenerated for security.
2. Some configuration files may contain personal information or system-specific paths.
3. The Zim framework modules are included as git submodules.

## License

Personal use - modify as needed for your own system.