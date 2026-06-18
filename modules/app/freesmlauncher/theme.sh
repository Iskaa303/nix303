#!/usr/bin/env bash
set -euo pipefail

CFG_PATH="$1"
THEME="$2"

CFG_DIR=$(dirname "$CFG_PATH")
mkdir -p "$CFG_DIR"

if [ ! -f "$CFG_PATH" ]; then
    echo -e "[General]\nApplicationTheme=$THEME" > "$CFG_PATH"
else
    if grep -q "^WidgetTheme=stylix" "$CFG_PATH"; then
        sed -i '/^WidgetTheme=stylix/d' "$CFG_PATH"
    fi

    if grep -q "^ApplicationTheme=" "$CFG_PATH"; then
        sed -i "s/^ApplicationTheme=.*/ApplicationTheme=$THEME/" "$CFG_PATH"
    else
        if grep -q "^\[General\]" "$CFG_PATH"; then
            sed -i "/^\[General\]/a ApplicationTheme=$THEME" "$CFG_PATH"
        else
            echo -e "[General]\nApplicationTheme=$THEME" >> "$CFG_PATH"
        fi
    fi
fi
