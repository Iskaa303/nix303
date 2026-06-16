{ config, ... }: {
  flake.modules.nixos.fuck-machine = { pkgs, inputs, ... }: {
    imports = [
      inputs.preservation.nixosModules.default
      ./_hardware-configuration.nix
      ./_user.nix
    ] ++ (with config.flake.modules.nixos; [
      bootloader_grub
      login-manager_ly
      feature_base
      feature_desktop
      feature_niri
      feature_noctalia
      feature_home-manager
    ]);

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

    fileSystems."/persist".neededForBoot = true;

    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = "/persist/passwords/root";

    system.stateVersion = "26.05";
  };
}
