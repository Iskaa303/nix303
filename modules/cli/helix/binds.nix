{ ... }: {
  flake.modules.nixos.cli_helix = {
    hm.programs.helix.settings.keys = {
      # ── Normal · Editing ───────────────────────────────────────
      # Vim muscle-memory: Esc drops extra cursors, keeps the primary.
      normal.esc = [ "collapse_selection" "keep_primary_selection" ];
      normal."C-s" = ":write";
      normal."C-q" = ":quit";
      normal."0" = "goto_line_start";
      normal."C-;" = "flip_selections";
      select."C-;" = "flip_selections";

      # ── Normal · Files ─────────────────────────────────────────
      normal."C-p" = "file_picker";
      # Buffer navigation stays on the defaults: g n / g p

      # ── Normal · Splits (skip the C-w prefix) ──────────────────
      normal."C-h" = "jump_view_left";
      normal."C-j" = "jump_view_down";
      normal."C-k" = "jump_view_up";
      normal."C-l" = "jump_view_right";

      # ── Normal · Git (lazygit) ─────────────────────────────────
      # >/dev/tty lets the TUI render; reload-all picks up new commits.
      normal."C-g" = [
        ":write-all"
        ":insert-output lazygit >/dev/tty"
        ":redraw"
        ":reload-all"
      ];

      # ── Normal · Search & replace (serpl + ripgrep / ast-grep) ──
      # Interactive project-wide search/replace; reload picks up edits.
      normal."C-r" = [
        ":write-all"
        ":insert-output serpl >/dev/tty"
        ":redraw"
        ":reload-all"
      ];

      # ── Normal · Fuzzy find (television) ───────────────────────
      # t = files, T = live grep (opens at the matched line).
      # Aborting tv leaves the temp file empty -> benign :open error.
      normal."space".t = [
        ":insert-output tv files > /tmp/hx-tv"
        ":open %sh{cat /tmp/hx-tv}"
        ":redraw"
      ];
      normal."space".T = [
        ":insert-output tv text > /tmp/hx-tv"
        ":open %sh{cat /tmp/hx-tv}"
        ":redraw"
      ];

      # ── Normal · File explorer (yazi) ──────────────────────────
      # Replaces the built-in explorer. e = workspace, E = buffer's dir.
      normal."space".e = [
        ":sh rm -f /tmp/hx-yazi"
        ":insert-output yazi --chooser-file=/tmp/hx-yazi"
        '':sh printf "\x1b[?1049h\x1b[?2004h" >/dev/tty''
        ":open %sh{cat /tmp/hx-yazi}"
        ":redraw"
      ];
      normal."space".E = [
        ":sh rm -f /tmp/hx-yazi"
        ":insert-output yazi \"%{buffer_name}\" --chooser-file=/tmp/hx-yazi"
        '':sh printf "\x1b[?1049h\x1b[?2004h" >/dev/tty''
        ":open %sh{cat /tmp/hx-yazi}"
        ":redraw"
      ];

      # ── Normal · tldr lookup ───────────────────────────────────
      # Select a word first (e.g. miw), then `space m`.
      normal."space".m = [
        ":pipe-to tee /tmp/hx-tldr"
        ":new"
        ":insert-output tldr $(cat /tmp/hx-tldr)"
        ":set-language markdown"
      ];

      # ── Insert · Escape hatch ──────────────────────────────────
      insert.j.k = "normal_mode";
    };
  };
}
