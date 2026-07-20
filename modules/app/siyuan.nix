{ inputs, ... }: {
  flake.modules.nixos.app_siyuan = { pkgs, config, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        siyuan = prev.siyuan.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
          postFixup = (oldAttrs.postFixup or "") + ''
            wrapProgram $out/bin/siyuan \
              --add-flags "--ozone-platform-hint=auto" \
              --add-flags "--enable-features=UseOzonePlatform"
          '';
        });
      })
    ];

    hm = { lib, ... }: {
      home.packages = [ pkgs.siyuan ];

      home.file = {
        ".local/share/siyuan/themes/stylix/theme.json".text = builtins.toJSON {
          name = "stylix";
          author = "stylix";
          type = "dark";
          themes = "theme.css";
        };

        ".local/share/siyuan/themes/stylix/theme.css".text =
          let
            c = config.lib.stylix.colors.withHashtag;
          in
          ''
            :root {
              --b3-theme-primary: ${c.base0D};
              --b3-theme-primary-light: ${c.base0C}33;
              --b3-theme-primary-lighter: ${c.base0D}1A;
              --b3-theme-primary-lightest: ${c.base0D}0D;
              --b3-theme-secondary: ${c.base0E};
              --b3-theme-background: ${c.base00};
              --b3-theme-surface: ${c.base01};
              --b3-theme-surface-light: ${c.base01}DB;
              --b3-theme-error: ${c.base08};
              --b3-theme-on-background: ${c.base05};
              --b3-theme-on-surface: ${c.base05};
              --b3-theme-on-primary: ${c.base00};
              --b3-theme-on-secondary: ${c.base00};
              --b3-theme-on-error: ${c.base00};
              --b3-border-color: ${c.base02};
              --b3-border-light: ${c.base03}66;
              --b3-list-hover: ${c.base03}33;
              --b3-menu-background: ${c.base01};
              --b3-menu-hover: ${c.base03}33;
              --b3-tooltips-color: ${c.base05};
              --b3-tooltips-background: ${c.base01};
              --b3-scroll-color: ${c.base03}66;
              --b3-scroll-hover: ${c.base03}99;
              --b3-gallery-background: ${c.base00}E6;
              --b3-card-info-background: ${c.base03}1A;
              --b3-card-info-color: ${c.base05};
              --b3-card-warning-background: ${c.base09}33;
              --b3-card-warning-color: ${c.base09};
              --b3-card-error-background: ${c.base08}33;
              --b3-card-error-color: ${c.base08};
              --b3-card-success-background: ${c.base0B}33;
              --b3-card-success-color: ${c.base0B};
              --b3-dialog-background: ${c.base00};
              --b3-dialog-shadow: 0 0 0 1px ${c.base02} inset;
              --b3-button-color: ${c.base05};
              --b3-button-background: ${c.base01};
              --b3-button-hover: ${c.base02};
              --b3-button-focused: ${c.base0D};
              --b3-button-outline-color: ${c.base0D};
              --b3-snackbar-background: ${c.base01};
              --b3-snackbar-color: ${c.base05};
              --b3-snackbar-button-color: ${c.base0D};
              --b3-status-bar-background: ${c.base00};
              --b3-status-bar-color: ${c.base04};
              --b3-tab-background: ${c.base00};
              --b3-tab-background-hover: ${c.base02};
              --b3-tab-background-active: ${c.base0D};
              --b3-tab-color: ${c.base05};
              --b3-tab-color-hover: ${c.base05};
              --b3-tab-color-active: ${c.base00};
              --b3-tab-background-synced: ${c.base0B};
              --b3-tab-background-synced-active: ${c.base0D};
              --b3-search-background: ${c.base01};
              --b3-search-color: ${c.base05};
              --b3-search-result-background: ${c.base01};
              --b3-search-result-hover: ${c.base03}4D;
              --b3-progress-background: ${c.base01};
              --b3-progress-color: ${c.base0D};
              --b3-separator-color: ${c.base02};
              --b3-border-radius: 4px;
              --b3-font-family: "${config.stylix.fonts.sansSerif.name}";
              --b3-font-family-code: "${config.stylix.fonts.monospace.name}";
            }
          '';
      };

      # Sync theme to Siyuan workspace on each activation
      home.activation.setupSiyuanTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        THEME_SRC="$HOME/.local/share/siyuan/themes/stylix"
        THEME_DST="$HOME/SiYuan/data/themes/stylix"
        if [ -d "$HOME/SiYuan/data/themes" ]; then
          mkdir -p "$THEME_DST"
          $DRY_RUN_CMD cp -r "$THEME_SRC/"* "$THEME_DST/"
        fi
      '';
    };
  };
}
