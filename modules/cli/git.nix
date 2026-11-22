{ ... }: {
  flake.modules.nixos.cli_git = { userVars, ... }: {
    hm = {
      stylix.targets.lazygit.enable = true;
      
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = userVars.gitName or "";
            email = userVars.gitEmail or "";
          };
          safe = {
            directory = [ "/persist/etc/nixos" ];
          };
          # Tool state must never end up staged: pi's Playwright MCP and virtual
          # display write session files, screenshots and logs into the project.
          core.excludesFile = "~/.config/git/ignore";
        };
      };

      home.file.".config/git/ignore".text = ''
        .playwright_mcp/
        .pi/
        .devenv/
        *.log
      '';

      programs.gh = {
        enable = true;
        gitCredentialHelper = {
          enable = true;
        };
      };

      programs.lazygit = {
        enable = true;
        settings.os = {
          edit = "hx-open {{filename}}";
          editAtLine = "hx-open {{filename}}:{{line}}";
        };
      };
    };
  };
}
