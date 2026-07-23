{ inputs, ... }: {
  flake.modules.nixos.app_freesm = { pkgs, config, ... }: {
    hm = { lib, ... }: {
      home.packages = [
        (let
          freesm-raw = inputs.freesm-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
          
          liquidbounceDeps = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            flac
            libogg
            libvorbis
            mesa
            libxxf86vm
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
              --prefix NIX_LD_LIBRARY_PATH : "${libPath}" \
              --set __NV_PRIME_RENDER_OFFLOAD 1 \
              --set __GLX_VENDOR_LIBRARY_NAME nvidia \
              --set __VK_LAYER_NV_OPTIMUS NVIDIA_only
          '';
        })
      ];

      home.file = {
        ".local/share/FreesmLauncher/themes/stylix/theme.json".text = builtins.toJSON {
          name = "stylix";
          widgets = "Fusion";
          qssFilePath = "themeStyle.css";
          colors = with config.lib.stylix.colors.withHashtag; {
            AlternateBase = base01;
            Base = base00;
            BrightText = base09;
            Button = base01;
            ButtonText = base05;
            Highlight = base0D;
            HighlightedText = base00;
            Link = base0D;
            Text = base05;
            ToolTipBase = base01;
            ToolTipText = base05;
            Window = base00;
            WindowText = base05;
            fadeAmount = 0.5;
            fadeColor = base00;
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
