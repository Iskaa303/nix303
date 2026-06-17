{ ... }: {
  flake.modules.nixos.cli_helix = { pkgs, ... }: {
    hm.programs.helix = {
      enable = true;
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
