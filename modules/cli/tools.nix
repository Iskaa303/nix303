{ ... }: {
  flake.modules.nixos.cli_tools = { pkgs, ... }: {
    hm.programs.bat = {
      enable = true;
    };

    hm.programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    hm.home.packages = [
      pkgs.ouch
    ];
  };
}
