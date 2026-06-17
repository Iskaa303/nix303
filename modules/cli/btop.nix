{ ... }: {
  flake.modules.nixos.cli_btop = {
    hm.programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        truecolor = true;
      };
    };
  };
}
