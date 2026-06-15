{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.preservation.nixosModules.default
    ./disko.nix
    ./hardware-configuration.nix
    ../../features/base.nix
    ../../features/desktop.nix
    ../../features/niri.nix
    ../../features/noctalia.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
}
