{ ... }: {
  flake.modules.nixos.cli_nushell = { pkgs, username, ... }: {
    environment.shells = [ pkgs.nushell ];
    users.users."${username}".shell = pkgs.nushell;

    hm.programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      # home.stateVersion < 26.11, so pick explicitly instead of relying on the shifting default
      loadSessionVariables = false;
    };

    hm.programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    hm.programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
