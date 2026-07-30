{ config, ... }: {
  flake.modules.nixos.cli_zrok = { pkgs, config, username, ... }: {
    sops.secrets.zrok-token = {
      sopsFile = ./secrets.yaml;
      owner = username;
    };

    hm.home.packages = [ pkgs.zrok ];

    # ponytail: oneshot enable service; if zrok later needs a persistent agent daemon, add a separate service
    systemd.user.services.zrok-enable = {
      description = "Enable zrok environment";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "zrok-enable" ''
          set -e
          if [ ! -f "$HOME/.zrok2/environment.json" ]; then
            ${pkgs.zrok}/bin/zrok enable --headless "$(cat ${config.sops.secrets.zrok-token.path})"
          fi
        '';
      };
    };
  };
}
