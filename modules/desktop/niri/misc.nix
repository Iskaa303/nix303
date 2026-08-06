{
  flake.modules.nixos.desktop_niri = {
    hm.programs.niri.settings = {
      outputs = {
        "HDMI-A-1" = {
          position = { x = 0; y = 0; };
          mode = {
            width = 2560;
            height = 1440;
          };
        };
        "eDP-1" = {
          position = { x = 2560; y = 0; };
        };
      };

      input = {
        keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:alt_shift_toggle";
          };
        };
      };

      environment = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      spawn-at-startup = [
        { command = ["xwayland-satellite"]; }
        { command = ["noctalia"]; }
        { 
          command = [ 
            "dbus-update-activation-environment" 
            "--systemd" 
            "WAYLAND_DISPLAY" 
            "XDG_CURRENT_DESKTOP=niri:GNOME" 
          ]; 
        }
      ];

      window-rules = [
        {
          matches = [
            { app-id = "^mpv$"; }
          ];
          default-column-width = { proportion = 0.5; };
        }
      ];
    };
  };
}
