{ ... }: {
  flake.modules.nixos.login-manager_ly = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = 1;
      };
    };
  };
}
