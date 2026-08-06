{
  flake.modules.nixos.desktop_niri = {
    hm.programs.niri.settings = {
      # AOC AG276QZD2 on the NVIDIA GPU's HDMI port: EDID caps 1440p at 144 Hz
      # over HDMI 2.0 (240/280 Hz needs the DP port instead).
      output = {
        "HDMI-A-1" = {
          mode = "2560x1440@144";
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
