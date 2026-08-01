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
      core_nvidia
      desktop_niri
      desktop_noctalia
      core_home-manager
      cli_btop
      cli_yazi
      cli_helix
      cli_nushell
      cli_tools
      cli_git
      cli_atuin
      cli_fastfetch
      cli_television
      cli_pi
      cli_ketch
      cli_searxng
      cli_sops
      cli_anime
      cli_kari
      cli_lenovo
      cli_zrok
      theme_stylix
      app_firefox
      app_ghostty
      app_nixcord
      app_freesm
      app_onlyoffice
      app_mpv
      app_flameshot
      app_sober
      app_siyuan
      app_ayugram
      app_obs_studio
      app_odysseus
      app_thunderbird
      app_qbittorrent
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
          "/var/lib/flatpak"
          "/var/lib/docker"
          "/persist/odysseus/data"
          "/persist/odysseus/searxng"
          "/persist/odysseus/chromadb"
          "/persist/odysseus/ntfy"
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
            "TorrentDownloads"
            "Documents"
            "Projects"
            "Games"
            "Videos"
            ".mozilla"
            ".cache/ketch"
            ".config/ketch"
            ".config/mozilla"
            ".config/gh"
            ".config/nushell"
            ".local/share/zoxide"
            ".local/share/keyrings"
            ".config/noctalia"
            ".local/state/noctalia"
            ".cache/noctalia"
            { directory = ".ssh"; mode = "0700"; }
            ".config/git"
            ".config/vesktop"
            ".config/Vencord"
            ".local/share/FreesmLauncher"
            ".config/onlyoffice"
            "SiYuan"
            ".local/share/onlyoffice"
            ".local/share/atuin"
            ".local/share/karere"
            ".config/karere"
            ".pki"
            ".local/share/Trash"
            ".var/app/org.vinegarhq.Sober"
            ".local/share/AyuGramDesktop"
            ".config/television"
            ".local/share/television"
            ".cache/television"
            ".config/obs-studio"
            ".config/sops"
            ".pi"
            ".thunderbird"
            ".config/qBittorrent"
            ".local/share/qBittorrent"
          ];
          files = [
          ];
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;

    swapDevices = [
      {
        device = "/swap/swapfile";
        priority = 1;
      }
    ];

    zramSwap = {
      enable = true;
      memoryPercent = 50;
      priority = 100;
    };

    users.mutableUsers = false;
    users.users.root.hashedPasswordFile = "/persist/passwords/root";

    system.stateVersion = "26.05";
  };
}
