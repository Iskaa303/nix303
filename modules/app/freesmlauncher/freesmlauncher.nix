{ inputs, ... }: {
  flake.modules.nixos.app_freesm = { pkgs, config, ... }: {
    hm = { lib, ... }: {
      home.packages = [
        (let
          freesm-raw = inputs.freesm-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
          
          liquidbounceDeps = with pkgs; [
            stdenv.cc.cc.lib
            libgbm
            glib
            nss
            nspr
            atk
            at-spi2-atk
            at-spi2-core
            libdrm
            expat
            libxcb
            libxkbcommon
            gtk3
            pango
            cairo
            alsa-lib
            dbus
            cups
            libxshmfence
            flite
            libpulseaudio
            libGL
            glfw
            openal
            pciutils
            wayland
            libx11
            libxcomposite
            libxdamage
            libxext
            libxfixes
            libxrandr
            libxcursor
          ];

          libPath = pkgs.lib.makeLibraryPath liquidbounceDeps;
        in pkgs.symlinkJoin {
          name = "freesm-launcher-wrapped";
          paths = [ freesm-raw ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            rm -f $out/bin/freesmlauncher
            makeWrapper ${freesm-raw}/bin/freesmlauncher $out/bin/freesmlauncher \
              --prefix LD_LIBRARY_PATH : "${libPath}" \
              --prefix NIX_LD_LIBRARY_PATH : "${libPath}"
          '';
        })
      ];

      home.file = {
        ".local/share/FreesmLauncher/themes/stylix/theme.json".text = builtins.toJSON {
          name = "stylix";
          widgets = "Fusion";
          qssFilePath = "themeStyle.css";
          colors = {
            AlternateBase = "#${config.lib.stylix.colors.base01}";
            Base = "#${config.lib.stylix.colors.base00}";
            BrightText = "#${config.lib.stylix.colors.base09}";
            Button = "#${config.lib.stylix.colors.base01}";
            ButtonText = "#${config.lib.stylix.colors.base05}";
            Highlight = "#${config.lib.stylix.colors.base0D}";
            HighlightedText = "#${config.lib.stylix.colors.base00}";
            Link = "#${config.lib.stylix.colors.base0D}";
            Text = "#${config.lib.stylix.colors.base05}";
            ToolTipBase = "#${config.lib.stylix.colors.base01}";
            ToolTipText = "#${config.lib.stylix.colors.base05}";
            Window = "#${config.lib.stylix.colors.base00}";
            WindowText = "#${config.lib.stylix.colors.base05}";
            fadeAmount = 0.5;
            fadeColor = "#${config.lib.stylix.colors.base00}";
          };
        };
        ".local/share/FreesmLauncher/themes/stylix/themeStyle.css".text = "";
      };

      home.activation.setupFreesmTheme =
        let
          script = ./theme.sh;
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          CFG_PATH="$HOME/.local/share/FreesmLauncher/freesmlauncher.cfg"
          $DRY_RUN_CMD ${script} "$CFG_PATH" "stylix"
        '';
    };
  };
}
