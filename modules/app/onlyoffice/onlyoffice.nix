{ inputs, ... }: {
  flake.modules.nixos.app_onlyoffice = { pkgs, config, ... }: {
    hm = { lib, ... }: {
      home.packages = [
        pkgs.onlyoffice-desktopeditors
      ];

      home.activation.setupOnlyoffice =
        let
          uitheme = if config.stylix.polarity == "light" then "theme-light" else "theme-dark";
          script = ./theme.py;
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          CONF_PATH="$HOME/.config/onlyoffice/DesktopEditors.conf"
          $DRY_RUN_CMD ${pkgs.python3}/bin/python3 ${script} "$CONF_PATH" "${uitheme}"
        '';
    };
  };
}
