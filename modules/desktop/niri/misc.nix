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

      # niri auto-picked the NVIDIA dGPU as its render node (renderD129, holds
      # /dev/nvidia*) while eDP-1/HDMI-A-1 scan out on the AMD iGPU (renderD128).
      # Every app - Chromium, OBS - GL-renders on the iGPU, and an NVIDIA dma-buf
      # cannot be imported into an AMD/Mesa context, so PipeWire screencast
      # delivers zero frames: Discord rejects getDisplayMedia with
      # INVALID_DISPLAY_CAPTURE_CONSTRAINTS and OBS records black. Pin the
      # compositor to the iGPU so compositor and clients share one GPU.
      debug = {
        "render-drm-device" = "/dev/dri/renderD128";
        # HDMI-A-1 is wired to the dGPU, so niri keeps a second NVIDIA renderer
        # for it. The screencast buffer is still allocated on the NVIDIA device
        # (modifier 0x20000001046bb04) even for eDP-1, and niri's iGPU renderer
        # can't fill it. The invalid/linear modifier takes niri's CPU-copy path
        # instead, so the frames cross the GPU boundary.
        "force-pipewire-invalid-modifier" = true;
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
          # Rounded corners for window + focus ring, no sharp blue corners.
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-right = 12.0;
            bottom-left = 12.0;
          };
          clip-to-geometry = true;
        }
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
