{ ... }: {
  flake.modules.nixos.app_ghostty = { pkgs, ... }: {
    hm.programs.ghostty = {
      enable = true;

      settings = {
        # Always the same session: a new terminal joins `main` instead of
        # spawning another orphan session. Alt s lists/kills/switches sessions.
        command = "${pkgs.zellij}/bin/zellij attach --create main";

        # Mod+Q closes the window outright; Zellij resurrects the session.
        "confirm-close-surface" = false;

        # Selection stays explicit: a drag copies nothing, Ctrl+Shift+C copies
        # (Ghostty's own selection when it has one, otherwise the key falls
        # through to Zellij, which copies its selection).
        "copy-on-select" = false;
        # SHIFT+drag is always a Ghostty selection, even inside pane apps.
        "mouse-shift-capture" = "never";
      };
    };
  };
}
