{ ... }: {
  flake.modules.nixos.cli_sops = { pkgs, ... }: {
    hm.home.packages = [ pkgs.sops ];
  };
}
