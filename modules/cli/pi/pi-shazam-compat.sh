#!/usr/bin/env bash
# pi-shazam compatibility patches for NixOS
# 1. Create real vscode-jsonrpc/node.js (not HM symlink) so relative require works
# 2. Suppress isExecutable ENOENT warnings (NixOS doesn't have those paths)
# 3. Remove empty ~/.pi/hooks/ (triggers "Hooks renamed to extensions" warning)
# 4. Suppress git stderr in getGitHooksDir (fatal: not a git repository leak)
# 5. Skip git pre-commit hook install in non-git repos (no warnings, no hooks)
set -eu

# -- 1. vscode-jsonrpc compat shim -------------------------------------------
target="$HOME/.pi/agent/npm/node_modules/vscode-jsonrpc/node.js"
if [ -L "$target" ]; then rm -f "$target"; fi
if [ ! -f "$target" ]; then
  cat > "$target" << 'EOF'
'use strict';
module.exports = require('./lib/node/main.js');
EOF
fi

# -- 2. Suppress isExecutable ENOENT warnings (NixOS) ------------------------
manager="$HOME/.pi/agent/npm/node_modules/pi-shazam/dist/lsp/manager.js"
if [ -f "$manager" ]; then
  # Only patch if not already patched
  if ! grep -q 'ENOENT.*_logWarn.*isExecutable' "$manager" 2>/dev/null; then
    # Use sed with @ delimiter to avoid escaping issues with /
    # Pattern: add ENOENT guard before _logWarn("isExecutable", ...)
    sed -i 's@_logWarn("isExecutable", `statSync failed for ${filePath}`, err);@if (err.code !== "ENOENT") _logWarn("isExecutable", `statSync failed for ${filePath}`, err);@' "$manager"
  fi
fi

# -- 3. Remove empty ~/.pi/hooks/ (triggers pi hooks→extensions warning) -----
hooks_dir="$HOME/.pi/hooks"
if [ -d "$hooks_dir" ] && [ -z "$(ls -A "$hooks_dir" 2>/dev/null)" ]; then
  rmdir "$hooks_dir"
fi

# -- 4. Suppress git stderr in getGitHooksDir (fatal: not a git repo leak) ---
git_hooks="$HOME/.pi/agent/npm/node_modules/pi-shazam/dist/core/git-hooks.js"
if [ -f "$git_hooks" ]; then
  # Add stdio suppression after timeout: 5000, to match isGitRepo pattern
  if ! grep -q 'stdio.*ignore.*pipe.*ignore' "$git_hooks" 2>/dev/null; then
    sed -i '/timeout: 5000,/a\            stdio: ["ignore", "pipe", "ignore"],' "$git_hooks"
  fi
fi

# -- 5. Skip git pre-commit hook install in non-git repos --------------------
if [ -f "$git_hooks" ]; then
  # Guard isPreCommitHookInstalled: return true (skip install) for non-git repos
  # Patch: add early-return after the function declaration
  if ! grep -q 'if.*existsSync.*join.*\.git.*return true' "$git_hooks" 2>/dev/null; then
    sed -i '/^export function isPreCommitHookInstalled(projectRoot) {$/a\    if (!existsSync(join(projectRoot, ".git"))) { return true; }' "$git_hooks"
  fi

  # Guard installPreCommitHook: silent no-op for non-git repos (defense-in-depth)
  if ! grep -q 'if.*existsSync.*join.*\.git.*return null' "$git_hooks" 2>/dev/null; then
    sed -i '/^export function installPreCommitHook(projectRoot) {$/a\    if (!existsSync(join(projectRoot, ".git"))) { return null; }' "$git_hooks"
  fi
fi
