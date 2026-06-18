{
  flake.modules.nixos.desktop_niri = {
    hm.programs.niri.settings = {
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
            "XDG_CURRENT_DESKTOP=niri" 
          ]; 
        }
        { 
          command = [ 
            "sh" 
            "-c" 
            "while ! busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; do sleep 0.2; done; pkill -f xdg-desktop-portal-gnome" 
          ]; 
        }
      ];
    };
  };
}
