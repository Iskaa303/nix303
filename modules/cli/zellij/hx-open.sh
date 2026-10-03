# Open files in the Zellij Helix pane.
#
# Used as yazi's opener so that hitting Enter in the file tree opens the file
# in the editor pane on the right, instead of spawning Helix inside the yazi
# pane. Falls back to a normal Helix launch when there is no Zellij session
# or no running Helix pane.
#
# usage: hx-open [--vsplit|--hsplit] <file>...

flag=""
case "${1:-}" in
  --vsplit) flag=":vsplit"; shift ;;
  --hsplit) flag=":hsplit"; shift ;;
esac

[ "$#" -gt 0 ] || exit 0

editor=""
if [ -n "${ZELLIJ:-}" ]; then
  editor="$(zellij action list-panes --json \
    | jq -r '[.[] | select((.pane_command // "") | test("(^|/)(hx|helix)$"))][0].id // empty')"
fi

if [ -z "$editor" ]; then
  exec "${EDITOR:-hx}" "$@"
fi

pane="terminal_$editor"
zellij action write --pane-id "$pane" 27 # Esc -> normal mode
if [ -n "$flag" ]; then
  zellij action write-chars --pane-id "$pane" "$flag"
  zellij action write --pane-id "$pane" 13 # Enter
fi
for f in "$@"; do
  zellij action write-chars --pane-id "$pane" ":open $f"
  zellij action write --pane-id "$pane" 13 # Enter
done
zellij action focus-pane-id "$pane"
