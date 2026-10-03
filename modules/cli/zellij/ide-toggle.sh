# Toggle the active Zellij tab between a bare shell and the dev workspace
# (yazi left, helix right, shell bottom). Bound to Alt w.
#
# Zellij keybinds cannot be conditional, so this runs as a command and picks
# the opposite layout based on whether the active tab already has a yazi pane.

tab="$(zellij action current-tab-info --json | jq -r '.tab_id')"

if zellij action list-panes --json \
  | jq -e --argjson t "$tab" \
    'any(.[]; (.tab_id == $t) and ((.pane_command // "") | test("(^|/)yazi$")))' >/dev/null; then
  zellij action override-layout --apply-only-to-active-tab shell
else
  zellij action override-layout --apply-only-to-active-tab dev
fi
