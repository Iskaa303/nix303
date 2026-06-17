{ inputs, ... }: {
  flake.modules.nixos.desktop_niri = { pkgs, ... }: {
    imports = [ inputs.niri-flake.nixosModules.niri ];
    nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common.default = "*";
    };

    hm.home.packages = with pkgs; [ xwayland-satellite ];
  };
}
