{
  flake.modules.nixos.desktop_niri = {
    hm.programs.niri.settings = {
      environment = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
      };

      spawn-at-startup = [
        { command = ["xwayland-satellite"]; }
        { command = ["noctalia"]; }
      ];
    };
  };
}
