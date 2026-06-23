{ ... }: {
  flake.modules.nixos.app_ayugram = { pkgs, ... }: {
    hm = { ... }: {
      home.packages = [
        pkgs.ayugram-desktop
      ];
    };
  };
}
