{ ... }: {
  flake.modules.nixos.core_home-manager = { lib, username, ... }: {
    imports = [(lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])];

    home-manager.backupFileExtension = "backup";

    hm = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
      programs.home-manager.enable = true;
    };
  };
}
