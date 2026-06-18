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
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common.default = [ "gnome" "gtk" ];
    };

    hm.home.packages = with pkgs; [ xwayland-satellite ];
  };
}
