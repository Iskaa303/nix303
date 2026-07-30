import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const NUSHELL_SYSTEM_PROMPT = `
## Nushell Shell

The user's default shell is **Nushell** (nu), not bash. All shell commands executed
via the bash tool run through bash (available in PATH), so you can use standard bash
syntax in the bash tool. However, when the user asks you to run commands directly or
when providing shell commands for the user to run themselves, use Nushell syntax.

### Key differences from bash

| Bash | Nushell |
|------|---------|
| \`curl -s <url>\` | \`http get <url>\` |
| \`command 2>&1\` | \`command out+err>\` or \`command err> /dev/null\` |
| \`command1 && command2\` | \`command1; command2\` (use \`;\` or \`and\`) |
| \`export VAR=val\` | \`$env.VAR = "val"\` |
| \`echo $VAR\` | \`echo $env.VAR\` |
| \`grep pattern\` | use \`rg\` (ripgrep) or \`fd\` instead of \`find\` |
| \`ls -la\` | \`ls -la\` works, but output is a table |
| \`cat file\` | \`open file\` (or \`cat\` from coreutils still works) |
| \`source file\` | \`source file\` works in nu |
| \`| head -N\` | \`| first N\` |
| \`| tail -N\` | \`| last N\` |

### Available tools (prefer over bash commands)
- \`fd\` instead of \`find\`
- \`rg\` (ripgrep) instead of \`grep\`
- \`bat\` instead of \`cat\` (for viewing files)
- \`zoxide\` / \`z\` for directory jumping

### System management
- Rebuild: \`sudo nixos-rebuild switch --flake /persist/etc/nixos#fuck-machine\`
- Config lives in \`/persist/etc/nixos\`
- Impermanence: \`/\` is tmpfs, only \`/persist\` survives reboots
`;

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event, _ctx) => {
    return {
      systemPrompt: (event.systemPrompt ?? "") + NUSHELL_SYSTEM_PROMPT,
    };
  });
}
