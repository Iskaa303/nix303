{ ... }: {
  flake.modules.nixos.app_sioyek = {
    hm = {
      stylix.targets.sioyek.enable = true;
      programs.sioyek.enable = true;
    };
  };
}
