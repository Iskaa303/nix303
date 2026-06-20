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
      languages = {
        language-server.eslint = {
          command = "vscode-eslint-language-server";
          args = [ "--stdio" ];
          config = {
            codeActionsOnSave = {
              mode = "all";
              "source.fixAll.eslint" = true;
            };
            format = { enable = true; };
            validate = "on";
          };
        };

        language = [
          {
            name = "typescript";
            language-servers = [ "typescript-language-server" "eslint" ];
            auto-format = true;
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
          }
          {
            name = "tsx";
            language-servers = [ "typescript-language-server" "eslint" ];
            auto-format = true;
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
          }
          {
            name = "javascript";
            language-servers = [ "typescript-language-server" "eslint" ];
            auto-format = true;
            formatter = { command = "prettier"; args = [ "--parser" "babel" ]; };
          }
          {
            name = "jsx";
            language-servers = [ "typescript-language-server" "eslint" ];
            auto-format = true;
            formatter = { command = "prettier"; args = [ "--parser" "babel" ]; };
          }
          {
            name = "json";
            auto-format = true;
            formatter = { command = "prettier"; args = [ "--parser" "json" ]; };
          }
        ];
      };
      extraPackages = with pkgs; [
        nil
        nixpkgs-fmt
        typescript-language-server
        vscode-langservers-extracted
        prettier
        typescript
        nodejs
      ];
    };
  };
}
