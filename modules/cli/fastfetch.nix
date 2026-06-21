{ ... }: {
  flake.modules.nixos.cli_fastfetch = {
    hm.programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "kitty-direct";
          source = "${../../assets/logo.png}";
          width = 40;
          height = 17;
          padding = {
            right = 4;
          };
        };
        display = {
          separator = " 󰧞 ";
          color = {
            keys = "magenta";
            title = "magenta";
          };
        };
        modules = [
          "title"
          {
            type = "separator";
            string = "━";
          }
          {
            type = "os";
            key = "󱄅 OS";
          }
          {
            type = "host";
            key = "󰌢 Host";
          }
          {
            type = "kernel";
            key = "󰌢 Kernel";
          }
          {
            type = "uptime";
            key = "󰅐 Uptime";
          }
          {
            type = "packages";
            key = "󰏖 Packages";
          }
          {
            type = "shell";
            key = "󰞷 Shell";
          }
          {
            type = "display";
            key = "󰍹 Display";
          }
          {
            type = "wm";
            key = "󱂬 WM";
          }
          {
            type = "terminal";
            key = "󰆍 Terminal";
          }
          {
            type = "cpu";
            key = "󰻠 CPU";
          }
          {
            type = "gpu";
            key = "󰢮 GPU";
          }
          {
            type = "memory";
            key = "󰍛 Memory";
          }
          {
            type = "swap";
            key = "󰓡 Swap";
          }
          {
            type = "disk";
            key = "󰋊 Disk (/)";
            folders = "/";
            hideFolders = [ ];
          }
          {
            type = "disk";
            key = "󰋊 SSD (/nix)";
            folders = "/nix";
            hideFolders = [ ];
          }
          "break"
          "colors"
          "break"
        ];
      };
    };
  };
}

