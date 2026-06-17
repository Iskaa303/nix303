{ ... }: {
  flake.modules.nixos.cli_git = { userVars, ... }: {
    hm = {
      programs.git = {
        enable = true;
        userName = userVars.gitName or "";
        userEmail = userVars.gitEmail or "";
        extraConfig = {
          safe = {
            directory = [ "/persist/etc/nixos" "/etc/nixos" ];
          };
        };
      };
    };
  };
}
