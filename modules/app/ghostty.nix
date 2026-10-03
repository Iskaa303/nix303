{ ... }: {
  flake.modules.nixos.app_ghostty = { pkgs, ... }: {
    hm.programs.ghostty = {
      enable = true;

      settings = {
        command = "${pkgs.zellij}/bin/zellij";

        # Selection and copying belong to Ghostty, not Zellij.
        "copy-on-select" = false;
        "mouse-shift-capture" = "never";
      };
    };
  };
}
