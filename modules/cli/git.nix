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
        };
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper = {
          enable = true;
        };
      };

      programs.lazygit = {
        enable = true;
      };
    };
  };
}
