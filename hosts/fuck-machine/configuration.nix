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
      core_bootloader_grub
      desktop_login-manager_ly
      core_base
      core_desktop
      core_audio
      desktop_niri
      desktop_noctalia
      core_home-manager
      cli_btop
      cli_yazi
      cli_helix
      cli_nushell
      cli_tools
      cli_git
      theme_stylix
      app_firefox
      app_nixcord
      app_antigravity
      app_freesm
    ]);

    boot.initrd.systemd.enable = true;

    networking.hostName = "fuck-machine";
    networking.networkmanager.enable = true;

    time.timeZone = "America/New_York"; 

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true; 

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
          { directory = "/var/lib/bluetooth"; mode = "0700"; }
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
            ".mozilla"
            ".config/mozilla"
            ".config/gh"
            ".config/nushell"
            ".local/share/zoxide"
            ".local/share/yazi"
            ".local/state/yazi"
            ".local/share/keyrings"
            ".config/noctalia"
            ".local/state/noctalia"
            ".cache/noctalia"
            { directory = ".ssh"; mode = "0700"; }
            ".config/git"
            ".config/vesktop"
            ".config/Vencord"
            ".config/FreesmLauncher"
            ".config/freesmlauncher"
            ".local/share/FreesmLauncher"
            ".local/share/freesmlauncher"
          ];
          files = [
          ];
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;

    swapDevices = [
      { device = "/swap/swapfile"; }
    ];

    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = "/persist/passwords/root";

    system.stateVersion = "26.05";
  };
}
