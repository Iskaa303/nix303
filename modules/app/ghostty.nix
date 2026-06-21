{ ... }: {
  flake.modules.nixos.app_ghostty = {
    hm.programs.ghostty = {
      enable = true;
    };
  };
}
