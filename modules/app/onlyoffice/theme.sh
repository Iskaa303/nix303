#!/usr/bin/env bash
set -euo pipefail

CONF_PATH="$1"
THEME="$2"

mkdir -p "$(dirname "$CONF_PATH")"

if [ ! -f "$CONF_PATH" ]; then
    JSON_DATA="{\"uiscaling\":\"0\",\"uitheme\":\"$THEME\"}"
    BASE64_DATA=$(echo -n "$JSON_DATA" | base64 -w 0)
    echo '[General]' > "$CONF_PATH"
    echo "appdata=\"@ByteArray($BASE64_DATA)\"" >> "$CONF_PATH"
    exit 0
fi

APPDATA_LINE=$(grep "^appdata=" "$CONF_PATH" || true)

if [ -n "$APPDATA_LINE" ]; then
    B64=$(echo "$APPDATA_LINE" | sed -E 's/^appdata="?@ByteArray\(([^)]+)\)"?/\1/')
    DECODED=$(echo "$B64" | base64 -d)
    if echo "$DECODED" | grep -q '"uitheme":'; then
        NEW_DECODED=$(echo "$DECODED" | sed -E "s/\"uitheme\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"uitheme\":\"$THEME\"/")
    else
        NEW_DECODED=$(echo "$DECODED" | sed -E "s/\{/{\"uitheme\":\"$THEME\",/")
        NEW_DECODED=$(echo "$NEW_DECODED" | sed 's/,"}/}/')
    fi
    NEW_B64=$(echo -n "$NEW_DECODED" | base64 -w 0)
    sed -i "s|^appdata=.*|appdata=\"@ByteArray($NEW_B64)\"|" "$CONF_PATH"
else
    JSON_DATA="{\"uiscaling\":\"0\",\"uitheme\":\"$THEME\"}"
    BASE64_DATA=$(echo -n "$JSON_DATA" | base64 -w 0)
    NEW_LINE="appdata=\"@ByteArray($BASE64_DATA)\""
    if grep -q "^\[General\]" "$CONF_PATH"; then
        sed -i "/^\[General\]/a $NEW_LINE" "$CONF_PATH"
    else
        echo -e "[General]\n$NEW_LINE" >> "$CONF_PATH"
    fi
fi
