{ config, ... }: 
let
  vars = import ./_user-vars.nix;
in {
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
      feature_antigravity
    ]);

    boot.initrd.systemd.enable = true;

    networking.hostName = "fuck-machine";
    networking.networkmanager.enable = true;

    time.timeZone = "EST"; 

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/etc/nixos"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/NetworkManager"
          { directory = "/etc/NetworkManager/system-connections"; mode = "0700"; }
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
        users."${vars.username}" = {
          home = "/home/${vars.username}";
          directories = [
            ".config/mozilla"
            ".config/gh"
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
