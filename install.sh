#!/usr/bin/env bash
set -euo pipefail

# Visuals
readonly BOLD="\033[1m"
readonly BOLD_RED="\033[1;31m"
readonly BOLD_YELLOW="\033[1;33m"
readonly DIM="\033[2m"
readonly RESET="\033[0m"

readonly CLR1="\033[0;32m"  # GREEN
readonly CLR1B="\033[1;32m" # BOLD_GREEN
readonly CLR2="\033[0;35m"  # MAGENTA
readonly CLR2B="\033[1;35m" # BOLD_MAGENTA

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status() {
	local status="$1"
	local message="$2"
	local color
	local icon
	case "$status" in
	"OK")
		color="$CLR2B"
		icon="*"
		;;
	"WARNING")
		color="$BOLD_YELLOW"
		icon="!"
		;;
	"FAILED")
		color="$BOLD_RED"
		icon="X"
		;;
	"INFO")
		color="$CLR1B"
		icon="ℹ"
		;;
	"PROMPT")
		color="$CLR1B"
		icon="?"
		;;
	*)
		color="$BOLD"
		icon="$status"
		;;
	esac
	echo -e "${color}${icon}${RESET} ${BOLD}${message}${RESET}"
}

prompt_input() {
	local prompt="$1"
	local var_name="$2"
	local color="${3:-$DIM}"
	echo -ne "${color}>${RESET} ${BOLD}${prompt}${RESET}"
	read -r "$var_name"
}

prompt_confirm() {
	local prompt="$1"
	local color="${2:-$DIM}"
	while true; do
		read -rp "$(echo -e "${color}>${RESET} ${BOLD}${prompt}${RESET} ${DIM}[y/n]${RESET}: ")" response
		case "$response" in
		y|Y) return 0 ;;
		n|N) return 1 ;;
		*) print_status "FAILED" "Please type 'y' or 'n'" ;;
		esac
	done
}

clear
echo ""

# Ensure root
if [[ $EUID -ne 0 ]]; then
    print_status "FAILED" "This script must be run as root"
    exit 1
fi
print_status "OK" "Running as root"
echo ""

HOST="fuck-machine"

# Target disk
print_status "PROMPT" "Select target disk"
disks=()
while read -r id size; do
    if [ -n "$id" ] && [ -n "$size" ]; then
        disks+=("$id ($size)")
    fi
done < <(ls -l /dev/disk/by-id/ | grep -v 'part' | awk '{print $9}' | while read -r id; do
    if [ -n "$id" ] && [ -e "/dev/disk/by-id/$id" ]; then
        size=$(lsblk -dno SIZE "/dev/disk/by-id/$id" 2>/dev/null || echo "Unknown")
        echo "$id $size"
    fi
done)

for i in "${!disks[@]}"; do
    echo -e "  ${CLR2}$((i + 1))${RESET} ${disks[i]}"
done

while true; do
    prompt_input "Choice: " choice "$CLR1"
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#disks[@]})); then
        disk=$(echo "${disks[choice - 1]}" | awk '{print $1}')
        DISK_ID="/dev/disk/by-id/$disk"
        break
    else
        print_status "FAILED" "Invalid selection. Please try again."
    fi
done
echo -e "${DIM}Selected Disk: $DISK_ID${RESET}\n"

# Swap size
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
DISK_GB=$(lsblk -dbno SIZE "$DISK_ID" | head -n1 | awk '{print int($1/1024/1024/1024)}')
LIMIT=$(( DISK_GB / 4 ))
DOUBLE_RAM=$(( RAM_GB * 2 ))

if [ "$DOUBLE_RAM" -lt "$LIMIT" ]; then
    DEFAULT_SWAP=$DOUBLE_RAM
else
    DEFAULT_SWAP=$LIMIT
fi

if [ "$DEFAULT_SWAP" -le 0 ]; then
    DEFAULT_SWAP=2
fi

print_status "PROMPT" "Enter swap size [Default: ${DEFAULT_SWAP}G]"
prompt_input "Size: " SWAP_SIZE "$CLR1"
SWAP_SIZE="${SWAP_SIZE:-${DEFAULT_SWAP}G}"
echo -e "${DIM}Swap configured: $SWAP_SIZE${RESET}\n"

# LUKS Password
print_status "PROMPT" "Set LUKS Encryption Password"
while true; do
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Password:${RESET} ")" PASS
    echo ""
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Confirm:${RESET} ")" PASS_CONFIRM
    echo ""
    if [[ "$PASS" == "$PASS_CONFIRM" ]]; then
        break
    fi
    print_status "FAILED" "Passwords do not match, try again"
done
echo -n "$PASS" > /tmp/secret.key
unset PASS PASS_CONFIRM
echo ""

# Root Password
print_status "PROMPT" "Set Root User Password"
while true; do
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Password:${RESET} ")" ROOT_PASS
    echo ""
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Confirm:${RESET} ")" ROOT_PASS_CONFIRM
    echo ""
    if [[ "$ROOT_PASS" == "$ROOT_PASS_CONFIRM" ]]; then
        break
    fi
    print_status "FAILED" "Passwords do not match, try again"
done
echo -e "${DIM}Generating password hash...${RESET}"
ROOT_HASH=$(mkpasswd -m sha-512 "$ROOT_PASS")
unset ROOT_PASS ROOT_PASS_CONFIRM
echo ""

# Normal User
print_status "PROMPT" "Create Normal User"
prompt_input "Username: " USERNAME "$CLR1"
echo ""

print_status "PROMPT" "Set Password for ${USERNAME}"
while true; do
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Password:${RESET} ")" USER_PASS
    echo ""
    read -rs -p "$(echo -e "${DIM}>${RESET} ${BOLD}Confirm:${RESET} ")" USER_PASS_CONFIRM
    echo ""
    if [[ "$USER_PASS" == "$USER_PASS_CONFIRM" ]]; then
        break
    fi
    print_status "FAILED" "Passwords do not match, try again"
done
if [ -n "$USER_PASS" ]; then
    echo -e "${DIM}Generating password hash...${RESET}"
    USER_HASH=$(mkpasswd -m sha-512 "$USER_PASS")
else
    USER_HASH=""
    echo -e "${DIM}No password set for ${USERNAME}.${RESET}"
fi
unset USER_PASS USER_PASS_CONFIRM
echo ""

# Confirmations
print_status "PROMPT" "Ready to format and install"
echo -e "${DIM}│${RESET} Host: ${CLR2}${HOST}${RESET}"
echo -e "${DIM}│${RESET} User: ${CLR1}${USERNAME}${RESET}"
echo -e "${DIM}│${RESET} Disk: ${CLR1}${DISK_ID}${RESET}"
echo -e "${DIM}│${RESET} Swap: ${CLR2}${SWAP_SIZE}${RESET}"
print_status "WARNING" "The chosen disk will be formatted and ALL DATA will be destroyed."

if ! prompt_confirm "Is the disk selection correct?"; then
    echo -e "\n${BOLD_RED}Aborting installation.${RESET}"
    rm -f /tmp/secret.key
    exit 0
fi
echo ""

print_status "PROMPT" "Verify disko configuration"
echo -e "${DIM}│${RESET} Disko config: ${CLR2}hosts/${HOST}/_disko.nix${RESET}"
if ! prompt_confirm "Have you verified that _disko.nix is correct?"; then
    echo -e "\n${BOLD_RED}Aborting installation.${RESET}"
    rm -f /tmp/secret.key
    exit 0
fi
echo ""

print_status "PROMPT" "Verify hardware configuration"
echo -e "${DIM}│${RESET} Hardware config: ${CLR2}hosts/${HOST}/_hardware-configuration.nix${RESET}"
if ! prompt_confirm "Does _hardware-configuration.nix look correct (or will be generated correctly)?"; then
    echo -e "\n${BOLD_RED}Aborting installation.${RESET}"
    rm -f /tmp/secret.key
    exit 0
fi
echo ""

if ! prompt_confirm "Proceed with installation?"; then
    echo -e "\n${BOLD_RED}Aborting installation.${RESET}"
    rm -f /tmp/secret.key
    exit 0
fi
echo ""

# Installation
print_status "INFO" "Formatting and mounting disks..."
nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode destroy,format,mount \
    --yes-wipe-all-disks \
    --arg device '"'"${DISK_ID}"'"' \
    --arg swapSize '"'"${SWAP_SIZE}"'"' \
    "$SCRIPT_DIR/hosts/$HOST/_disko.nix"
echo ""

print_status "INFO" "Setting up passwords..."
mkdir -p /mnt/persist/passwords
echo -n "$ROOT_HASH" > /mnt/persist/passwords/root
chmod 600 /mnt/persist/passwords/root

if [ -n "$USER_HASH" ]; then
    echo -n "$USER_HASH" > "/mnt/persist/passwords/$USERNAME"
    chmod 600 "/mnt/persist/passwords/$USERNAME"
fi
echo ""

print_status "INFO" "Generating user configuration..."
cat <<EOF > "$SCRIPT_DIR/hosts/$HOST/_user.nix"
{ ... }: {
  users.users."$USERNAME" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "usb" "video" "networkmanager" ];
    $(if [ -n "$USER_HASH" ]; then echo "hashedPasswordFile = \"/persist/passwords/$USERNAME\";"; fi)
  };
}
EOF
git -C "$SCRIPT_DIR" add "hosts/$HOST/_user.nix"
echo ""

print_status "INFO" "Generating hardware configurations..."
nixos-generate-config --show-hardware-config --root /mnt \
    > "$SCRIPT_DIR/hosts/$HOST/_hardware-configuration.nix"
git -C "$SCRIPT_DIR" add "hosts/$HOST/_hardware-configuration.nix"
echo ""

print_status "INFO" "Installing NixOS..."
nixos-install --no-root-password --flake "$SCRIPT_DIR#$HOST"
echo ""

# Cleanup
rm -f /tmp/secret.key

echo -e "${CLR1B}*** Installation Complete! Reboot your system. ***${RESET}"