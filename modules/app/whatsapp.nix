{ inputs, ... }: {
  flake.modules.nixos.app_whatsapp = { pkgs, ... }: {
    hm = {
      home.packages = [
        pkgs.whatsapp-electron
      ];
    };
  };
}

