{ ... }: {
  flake.modules.nixos.cli_television = { ... }: {
    hm.programs.television = {
      enable = true;
    };
  };
}
