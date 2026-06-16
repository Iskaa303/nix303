{ ... }: {
  flake.modules.nixos.bootloader_grub = {
    imports = [ ./_shared.nix ];

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };
}
