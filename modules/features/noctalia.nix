{ inputs, ... }: {
  flake.modules.nixos.feature_noctalia = {
    services.upower.enable = true;

    hm = {
      imports = [inputs.noctalia.homeModules.default];
      programs.noctalia.enable = true;
    };
  };
}
