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
if [ -f "$manager" ] && ! grep -q 'ENOENT.*_logWarn.*isExecutable' "$manager" 2>/dev/null; then
  node - <<'NODEEOF'
const fs = require('fs');
const src = fs.readFileSync(process.env.manager, 'utf8');
const old = '_logWarn("isExecutable", `statSync failed for ${filePath}`, err);';
const neu = 'if (err.code !== "ENOENT") ' + old;
if (src.includes(old)) {
  fs.writeFileSync(process.env.manager, src.replace(old, neu), 'utf8');
}
NODEEOF
fi
