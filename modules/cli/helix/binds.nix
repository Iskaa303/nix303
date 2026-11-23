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

      # lazygit, serpl, tv and yazi are Zellij popups (Alt g/r/t/y): run them
      # from there and they get real terminal space instead of Helix's tty.

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
