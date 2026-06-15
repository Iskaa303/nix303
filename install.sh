#!/usr/bin/env bash
set -euo pipefail

# Visuals
readonly BOLD="\033[1m"
readonly BOLD_RED="\033[1;31m"
readonly CLR1B="\033[1;32m" # GREEN
readonly CLR2B="\033[1;35m" # MAGENTA
readonly DIM="\033[2m"
readonly RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="fuck-machine"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${BOLD_RED}This script must be run as root.${RESET}"
    exit 1
fi

# Prompt target disk (by-id)
echo -e "${CLR2B}*${RESET} ${BOLD}Select target disk:${RESET}"
echo -e "${BOLD_RED}!!! WARNING: This will erase all data on the selected disk.${RESET}"

# Create an array of options
options=()
while read -r id size; do
    if [ -n "$id" ] && [ -n "$size" ]; then
        options+=("$id ($size)")
    fi
done < <(ls -l /dev/disk/by-id/ | grep -v 'part' | awk '{print $9}' | while read -r id; do
    if [ -n "$id" ] && [ -e "/dev/disk/by-id/$id" ]; then
        size=$(lsblk -dno SIZE "/dev/disk/by-id/$id" 2>/dev/null || echo "Unknown")
        echo "$id $size"
    fi
done)

# Display the menu
select choice in "${options[@]}"; do
    if [ -n "$choice" ]; then
        disk=$(echo "$choice" | awk '{print $1}')
        DISK_ID="/dev/disk/by-id/$disk"
        break
    else
        echo -e "${BOLD_RED}Invalid selection. Please try again.${RESET}"
    fi
done

echo -e "${DIM}Selected Disk: $DISK_ID${RESET}\n"
echo -e "${BOLD_RED}!!! WARNING: Wiping all signatures and partition tables on $DISK_ID !!!${RESET}"

# Forcefully clear all filesystem, RAID, and partition signatures
wipefs --all --force "$DISK_ID"

# Zero out the first 100MB to obliterate primary GPT/MBR data structures
dd if=/dev/zero of="$DISK_ID" bs=1M count=100 conv=fdatasync status=none

# Inform the kernel of partition changes so it drops old nodes
partprobe "$DISK_ID" || true
udevadm settle

echo -e "${CLR1B}Disk successfully wiped clean.${RESET}\n"

# Auto-calculate and prompt swap size
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
DISK_GB=$(lsblk -bno SIZE "$DISK_ID" | awk '{print int($1/1024/1024/1024)}')
DEFAULT_SWAP=$(( RAM_GB * 2 < DISK_GB / 4 ? RAM_GB * 2 : DISK_GB / 4 ))

read -p "$(echo -e "${CLR1B}?${RESET} ${BOLD}Enter swap size [Default: ${DEFAULT_SWAP}G]:${RESET} ")" SWAP_SIZE
SWAP_SIZE="${SWAP_SIZE:-${DEFAULT_SWAP}G}"
echo -e "${DIM}Swap configured: $SWAP_SIZE${RESET}\n"

# Set LUKS Encryption Passphrase
echo -e "${CLR1B}?${RESET} ${BOLD}Set LUKS Encryption Password:${RESET}"
read -rs -p "Password: " PASS
echo ""
echo -e "${CLR2B}*${RESET} ${BOLD}Confirm LUKS Password:${RESET}"
read -rs -p "Retype Password: " PASS_CONFIRM
echo ""

if [[ "$PASS" != "$PASS_CONFIRM" ]]; then
    echo -e "${BOLD_RED}Passwords do not match. Aborting.${RESET}"
    exit 1
fi

# Write password to temporary keyfile for disko
echo -n "$PASS" > /tmp/secret.key
unset PASS PASS_CONFIRM

# Set Root Password
echo -e "${CLR1B}?${RESET} ${BOLD}Set Root User Password:${RESET}"
read -rs -p "Password: " ROOT_PASS
echo ""
echo -e "${CLR2B}*${RESET} ${BOLD}Confirm Root Password:${RESET}"
read -rs -p "Retype Password: " ROOT_PASS_CONFIRM
echo ""

if [[ "$ROOT_PASS" != "$ROOT_PASS_CONFIRM" ]]; then
    echo -e "${BOLD_RED}Root passwords do not match. Aborting.${RESET}"
    exit 1
fi

echo -e "${DIM}Generating password hash...${RESET}"
ROOT_HASH=$(mkpasswd -m sha-512 "$ROOT_PASS")
unset ROOT_PASS ROOT_PASS_CONFIRM

# Run Disko Partitioning / Formatting
echo -e "${CLR2B}*${RESET} ${BOLD}Formatting and mounting disks...${RESET}"
nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode destroy,format,mount \
    --yes-wipe-all-disks \
    --arg device '"'"${DISK_ID}"'"' \
    --arg swapSize '"'"${SWAP_SIZE}"'"' \
    "$SCRIPT_DIR/modules/hosts/$HOST/disko.nix"

# Setup passwords in persist
echo -e "${CLR2B}*${RESET} ${BOLD}Setting up root password hash...${RESET}"
mkdir -p /mnt/persist/passwords
echo -n "$ROOT_HASH" > /mnt/persist/passwords/root
chmod 600 /mnt/persist/passwords/root

# Generate Hardware Configurations
echo -e "${CLR2B}*${RESET} ${BOLD}Generating hardware configurations...${RESET}"
nixos-generate-config --show-hardware-config --root /mnt \
    > "$SCRIPT_DIR/modules/hosts/$HOST/hardware-configuration.nix"

# Git track hardware-configuration.nix so flake can evaluate it
git -C "$SCRIPT_DIR" add "modules/hosts/$HOST/hardware-configuration.nix"

# Install NixOS
echo -e "${CLR2B}*${RESET} ${BOLD}Installing NixOS...${RESET}"
nixos-install --no-root-password --flake "$SCRIPT_DIR#$HOST"

# Cleanup secret keyfile from ramdisk
rm -f /tmp/secret.key

echo -e "${CLR1B}*** Installation Complete! Reboot your system. ***${RESET}"