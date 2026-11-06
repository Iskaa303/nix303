{ ... }: {
  flake.modules.nixos.app_steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

      # PRIME render offload: the RTX 4060 renders every game Steam launches,
      # the AMD iGPU stays the display sink. Env vars per NVIDIA's PRIME render
      # offload docs (Vulkan/EGL needs the first, GLX/XWayland the last two).
      package = pkgs.steam.override {
        extraEnv = {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          # Also set here, not just in environment.sessionVariables: those only
          # reach processes started after a new login, so a Steam client that
          # survived a rebuild would otherwise launch games without the overlay.
          MANGOHUD = "1";
        };
      };
    };
  };
}
