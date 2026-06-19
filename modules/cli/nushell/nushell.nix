{ ... }: {
  flake.modules.nixos.cli_nushell = { pkgs, username, ... }: {
    environment.shells = [ pkgs.nushell ];
    users.users."${username}".shell = pkgs.nushell;

    hm.programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
    };

    hm.programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
