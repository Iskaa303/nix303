{ ... }: {
  flake.modules.nixos.cli_helix = { pkgs, ... }: {
    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    hm.programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        editor = {
          line-number = "relative";
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp.display-messages = true;
        };
      };
      extraPackages = with pkgs; [
        nil
        nixpkgs-fmt
      ];
    };
  };
}
