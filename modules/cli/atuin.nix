{ ... }: {
  flake.modules.nixos.cli_atuin = {
    hm.programs.atuin = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
      };
    };
  };
}
