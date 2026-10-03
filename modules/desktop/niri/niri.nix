{ inputs, ... }: {
  flake.modules.nixos.desktop_niri = { pkgs, ... }: {
    imports = [ inputs.niri-flake.nixosModules.niri ];
    nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gnome
      ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileDialog" = [ "gtk" ];
          "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
          # niri's own screencasting docs (wiki/Screencasting) require
          # xdg-desktop-portal-gnome: it drives niri through the standard
          # ext-image-copy-capture protocol. xdg-desktop-portal-wlr negotiates a
          # stream, goes streaming, and is torn down ~300ms later with zero
          # frames delivered - Discord then rejects getDisplayMedia with
          # INVALID_DISPLAY_CAPTURE_CONSTRAINTS and OBS records black.
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };
    };

    hm.home.packages = with pkgs; [ xwayland-satellite ];
  };
}
