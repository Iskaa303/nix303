{ ... }: {
  flake.modules.nixos.core_home-manager = { lib, username, ... }: {
    imports = [(lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])];

    # home-manager activation runs before systemd-user-sessions.service, and
    # therefore before the display manager. Its stock TimeoutStartSec is 5m, so
    # a hanging step means a 5-minute dead console before the boot moves on.
    # Bound it much tighter (the activation itself is a couple of seconds).
    systemd.services."home-manager-${username}".serviceConfig.TimeoutStartSec = lib.mkForce "90s";

    home-manager.backupFileExtension = "backup";

    hm = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
      programs.home-manager.enable = true;
    };
  };
}
