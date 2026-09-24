# dotfiles

Arch Linux + Hyprland (Wayland) on an AMD Ryzen AI 7 350 / RTX 5060 laptop.

- `config/` -> `~/.config/`
- `home/` -> `~/`
- `etc/` -> reference copies of system files (`/etc/locale.gen`, `pacman.conf`, ...). Not auto-applied.
- `packages/` -> `pacman -Qqen` (native) and `pacman -Qqem` (AUR)

Restore packages: `sudo pacman -S --needed - < packages/pacman-native.txt`
