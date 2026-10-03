{ ... }: {
  flake.modules.nixos.cli_zellij = { pkgs, ... }:
    let
      hxOpen = pkgs.writeShellApplication {
        name = "hx-open";
        runtimeInputs = [ pkgs.zellij pkgs.jq ];
        text = builtins.readFile ./hx-open.sh;
      };
      ideToggle = pkgs.writeShellApplication {
        name = "ide-toggle";
        runtimeInputs = [ pkgs.zellij pkgs.jq ];
        text = builtins.readFile ./ide-toggle.sh;
      };
    in
    {
      hm.home.packages = [ hxOpen ideToggle ];

      hm.programs.zellij = {
        enable = true;

        # autolock: lock Zellij whenever the focused pane is a TUI, so Helix
        # (and yazi / lazygit / serpl / tv / pi) receive their own keys instead
        # of Zellij's. No forked Zellij, no per-key rebinding of the defaults.
        plugins = [ pkgs.zellijPlugins.autolock ];

        settings = {
          # Default session is a bare nushell pane; Alt w spawns the IDE.
          default_shell = "nu";
          default_layout = "shell";

          # Matches Stylix's nord base16 palette (built-in theme).
          theme = "nord";
          pane_frame_style = "full";
          ui.pane_frames.rounded_corners = true;

          # Kitty graphics => yazi image previews inside panes (0.45+).
          support_kitty_graphics_protocol = true;
          support_kitty_keyboard_protocol = true;

          show_startup_tips = false;
          show_release_notes = false;
          session_serialization = true;

          # Keep Zellij's mouse: wheel scroll and click-to-focus stay native to
          # Zellij. Hold SHIFT to bypass it into Ghostty for terminal-native
          # selection / word-select / opening links.
          mouse_mode = true;
          copy_on_select = false;

          plugins.autolock = {
            is_enabled = true;
            triggers = "hx|yazi|serpl|lazygit|pi|tv";
            reaction_seconds = "0.2";
            print_to_log = false;
          };
        };

        layouts = {
          shell = ./shell.kdl;
          dev = ./dev.kdl;
        };

        # Kept in a separate .kdl file for syntax highlighting.
        extraConfig = builtins.readFile ./keybinds.kdl;
      };
    };
}
