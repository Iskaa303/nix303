{ inputs, ... }: {
  flake.modules.nixos.app_freesm = { pkgs, ... }: {
    hm = {
      home.packages = [
        inputs.freesm-launcher.packages.${pkgs.system}.default
      ];
    };
  };
}
