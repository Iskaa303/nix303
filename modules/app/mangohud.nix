{ ... }: {
  flake.modules.nixos.app_mangohud = { pkgs, ... }: {
    hm.programs.mangohud = {
      enable = true;

      # HUD readout: fps/frametime + what the game uses (CPU/GPU load, temps,
      # RAM/VRAM total and per-process).
      settings = {
        fps = true;
        frametime = true;
        frame_timing = true; # frametime graph
        gpu_stats = true;
        gpu_temp = true;
        vram = true;
        cpu_stats = true;
        cpu_temp = true;
        ram = true;
        procmem = true; # RAM used by the game process
        gpu_name = true; # which GPU is actually rendering
        wine = true; # Proton version in use
        position = "top-left";
        round_corners = 8;
        # Steam's screenshot key is F12, so the default Shift_R+F12 gets eaten.
        toggle_hud = "Shift_R+Insert";

        # mpv segfaults inside MangoHud: ffmpeg creates a Vulkan hwdec device and
        # the layer dies in overlay_CreateDevice (vkSetDeviceDispatch <-
        # libMangoHud.so <- av_hwdevice_ctx_create). Blacklisting keeps the layer
        # out of mpv; `DISABLE_MANGOHUD=1 mpv <file>` is the manual escape hatch.
        blacklist = [ "mpv" ];

        # Font size, opacity and colors come from the stylix mangohud target.
      };
    };

    # MANGOHUD=1 attaches the overlay to every Vulkan app, so Proton/DXVK games
    # need no per-game launch options. Set at the system level on purpose: the
    # home-manager "session wide" option only writes shell profiles, which niri
    # (started by ly, not a login shell) never sources. The Vulkan layer is
    # found through the user profile's share/vulkan, which is already in
    # XDG_DATA_DIRS and is inherited by Steam's FHS container.
    environment.sessionVariables = {
      MANGOHUD = "1";
      MANGOHUD_DLSYM = "1";
    };
  };
}
