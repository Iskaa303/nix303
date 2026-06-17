{ ... }: {
  flake.modules.nixos.cli_tools = { pkgs, ... }: {
    hm.programs.bat = {
      enable = true;
    };

    hm.programs.eza = {
      enable = true;
      enableNushellIntegration = false; # We configure custom aliases in Nushell manually to avoid breaking native table format
      icons = "auto";
    };

    hm.programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
