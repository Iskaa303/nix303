{ inputs, ... }: {
  flake.modules.nixos.desktop_noctalia = {
    services.upower.enable = true;

    hm = {
      imports = [inputs.noctalia.homeModules.default];
      programs.noctalia.enable = true;
    };
  };
}
