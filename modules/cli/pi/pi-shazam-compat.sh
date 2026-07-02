#!/usr/bin/env bash
# pi-shazam compatibility patches for NixOS
# 1. Create real vscode-jsonrpc/node.js (not HM symlink) so relative require works
# 2. Suppress isExecutable ENOENT warnings (NixOS doesn't have those paths)
set -eu

target="$HOME/.pi/agent/npm/node_modules/vscode-jsonrpc/node.js"
if [ -L "$target" ]; then rm -f "$target"; fi
if [ ! -f "$target" ]; then
  cat > "$target" << 'EOF'
'use strict';
module.exports = require('./lib/node/main.js');
EOF
fi

manager="$HOME/.pi/agent/npm/node_modules/pi-shazam/dist/lsp/manager.js"
if [ -f "$manager" ]; then
  # Only patch if not already patched
  if ! grep -q 'ENOENT.*_logWarn.*isExecutable' "$manager" 2>/dev/null; then
    # Use sed with @ delimiter to avoid escaping issues with /
    # Pattern: add ENOENT guard before _logWarn("isExecutable", ...)
    sed -i 's@_logWarn("isExecutable", `statSync failed for ${filePath}`, err);@if (err.code !== "ENOENT") _logWarn("isExecutable", `statSync failed for ${filePath}`, err);@' "$manager"
  fi
fi
