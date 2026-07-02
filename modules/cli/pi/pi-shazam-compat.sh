#!/usr/bin/env bash
# pi-shazam compatibility patches for NixOS
# 1. Create real vscode-jsonrpc/node.js (not HM symlink) so relative require works
# 2. Suppress isExecutable ENOENT warnings (NixOS doesn't have those paths)
# 3. Remove empty ~/.pi/hooks/ (triggers "Hooks renamed to extensions" warning)
# 4. Fully disable git pre-commit hooks (stub all functions in git-hooks.js)
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
  if ! grep -q 'ENOENT.*_logWarn.*isExecutable' "$manager" 2>/dev/null; then
    sed -i 's@_logWarn("isExecutable", `statSync failed for ${filePath}`, err);@if (err.code !== "ENOENT") _logWarn("isExecutable", `statSync failed for ${filePath}`, err);@' "$manager"
  fi
fi

# -- 3. Remove empty ~/.pi/hooks/ (triggers pi hooks→extensions warning) -----
hooks_dir="$HOME/.pi/hooks"
if [ -d "$hooks_dir" ] && [ -z "$(ls -A "$hooks_dir" 2>/dev/null)" ]; then
  rmdir "$hooks_dir"
fi

# -- 4. Fully disable git pre-commit hooks -----------------------------------
# Stub every function in git-hooks.js so pi-shazam never installs or runs
# pre-commit hooks, even in git repos. Also suppresses getGitHooksDir warnings.
git_hooks="$HOME/.pi/agent/npm/node_modules/pi-shazam/dist/core/git-hooks.js"
if [ -f "$git_hooks" ]; then
  # Only patch if not already stubbed (check for our signature)
  if ! grep -q 'ponytail: fully stubbed by NixOS compat' "$git_hooks" 2>/dev/null; then
    # installPreCommitHook → silent no-op
    sed -i 's/^export function installPreCommitHook(projectRoot) {/export function installPreCommitHook(projectRoot) { return null; \/\/ ponytail: fully stubbed by NixOS compat/' "$git_hooks"

    # isPreCommitHookInstalled → always true (skips auto-install in index.js)
    sed -i 's/^export function isPreCommitHookInstalled(projectRoot) {/export function isPreCommitHookInstalled(projectRoot) { return true; \/\/ ponytail: fully stubbed by NixOS compat/' "$git_hooks"

    # removePreCommitHook → silent no-op
    sed -i 's/^export function removePreCommitHook(projectRoot) {/export function removePreCommitHook(projectRoot) { return true; \/\/ ponytail: fully stubbed by NixOS compat/' "$git_hooks"

    # runPreCommitVerify → always PASS (even if called directly)
    sed -i 's/^export function runPreCommitVerify(projectRoot) {/export function runPreCommitVerify(projectRoot) { return { verdict: "PASS", message: "Pre-commit hooks disabled by NixOS config (ponytail: stubbed)" }; \/\/ ponytail: fully stubbed by NixOS compat/' "$git_hooks"
  fi
fi
