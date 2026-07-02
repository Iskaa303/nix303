---
name: nixos-env
description: NixOS impermanence, nushell shell, and available CLI tools. Use when making system changes, running commands, or managing the system.
---

# NixOS Environment

This system runs **NixOS** with the following setup:

- **Impermanence**: `/` is tmpfs, only `/persist` survives reboots.
  - System config: `/persist/etc/nixos`
  - User passwords: `/persist/passwords`
  - Any changes to `/etc/` or other non-persist paths are lost on reboot.
- **Default shell**: Nushell for user `iskaa303`. Use `nu`-style commands.
- **Available CLI tools**: nushell, nix, git, helix, yazi, starship, fd, ripgrep, bat, zoxide, btop, fastfetch, atuin, television, ghostty.
- **System management**:
  - `sudo nixos-rebuild switch --flake /persist/etc/nixos#fuck-machine` for system rebuilds.
  - Flake at `/persist/etc/nixos/flake.nix` with host `fuck-machine`.
  - Home-manager managed via `hm` alias in Nix config.
- **Persistent directories** (survive reboots):
  - `/persist/etc/nixos` - system configuration
  - `/persist/var/log` - system logs
  - `/persist/home/iskaa303/` - user home (Documents, Projects, Games, .ssh, etc.)
  - `~/.pi` - pi agent data

When making changes that affect system files, always persist them under `/persist`.
