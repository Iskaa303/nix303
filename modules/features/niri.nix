{ pkgs, ... }: {
  programs.niri.enable = true;
  environment.systemPackages = [ pkgs.xwayland ];

  environment.etc."niri/config.kdl".text = ''
    spawn-at-startup "ghostty"
    binds {
      Mod+Return { spawn "ghostty"; }
      Mod+Q { close-window; }
    }
  '';
}
