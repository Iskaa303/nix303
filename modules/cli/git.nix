{ ... }: {
  flake.modules.nixos.cli_git = { userVars, ... }: {
    hm = {
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
    };
  };
}
