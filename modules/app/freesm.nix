{ inputs, ... }: {
  flake.modules.nixos.app_freesm = { pkgs, ... }: {
    hm = {
      home.packages = [
        (let
          freesm-raw = inputs.freesm-launcher.packages.${pkgs.system}.default;
          
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
    };
  };
}
