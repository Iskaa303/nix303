{ config, ... }: {
  flake.modules.nixos.fuck-machine = { pkgs, inputs, ... }: {
    imports = [
      inputs.preservation.nixosModules.default
      ./_hardware-configuration.nix
    ] ++ (with config.flake.modules.nixos; [
      feature_base
      feature_desktop
      feature_niri
      feature_noctalia
    ]);

    # Bootloader
    boot.loader.timeout = 2;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    boot.initrd.systemd.enable = true;

    networking.hostName = "fuck-machine";
    networking.networkmanager.enable = true;

    time.timeZone = "UTC"; 

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/etc/nixos"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/NetworkManager"
        ];
        files = [
          "/etc/machine-id"
        ];
        users.root = {
          home = "/root";
          directories = [
            ".ssh"
            ".local/share/nix"
          ];
        };
      };
    };

    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = "/persist/passwords/root";

    system.stateVersion = "26.05";
  };
}
