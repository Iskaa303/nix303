#!/usr/bin/env bash
set -e
PROFILE="$(cat /sys/firmware/acpi/platform_profile)"
case "${1:-show}" in
  show)
    echo "$PROFILE"
    ;;
  cycle)
    case "$PROFILE" in
      low-power)           next="balanced" ;;
      balanced)            next="balanced-performance" ;;
      balanced-performance) next="performance" ;;
      performance)         next="low-power" ;;
      *)                   next="balanced" ;;
    esac
    echo "$next" | tee /sys/firmware/acpi/platform_profile
    ;;
  set)
    echo "$2" | tee /sys/firmware/acpi/platform_profile
    ;;
  *)
    echo "Usage: lenovo-profile [show|cycle|set <mode>]" >&2
    echo "Modes: low-power balanced balanced-performance performance custom" >&2
    exit 1
    ;;
esac
