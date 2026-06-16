{ lib, username, ... }: {
  flake.modules.nixos.feature_home-manager = {
    imports = [(lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])];

    hm = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
      programs.home-manager.enable = true;
    };
  };
}
