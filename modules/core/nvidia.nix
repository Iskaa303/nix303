{ ... }: {
  flake.modules.nixos.core_nvidia = { pkgs, config, lib, ... }: {
    # Proprietary NVIDIA driver (latest stable)
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.open = false;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

    # PRIME render offload — display on AMD iGPU, render on NVIDIA dGPU
    # Bus IDs from sysfs: NVIDIA = 0000:01:00.0, AMD = 0000:06:00.0
    hardware.nvidia.prime = {
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    # OpenGL/Vulkan with 32-bit support (needed for games)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # List both drivers so XWayland can use both
    services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

    # Prevent nouveau from conflicting with the proprietary driver
    boot.blacklistedKernelModules = [ "nouveau" ];

    # Power management: leave disabled by default (can cause suspend issues)
    # hardware.nvidia.powerManagement.enable = false;
  };
}
