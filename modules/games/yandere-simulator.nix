{ ... }: {
  flake.modules.nixos.game_yandere_simulator = { pkgs, ... }: {
    hm.home.packages = [
      (pkgs.writeShellApplication {
        name = "yandere-simulator";
        runtimeInputs = with pkgs; [
          curl
          unzip
          coreutils
        ];
        text = ''
          GAME_DIR="$HOME/Games/YandereSimulator"
          EXE="$GAME_DIR/YandereSimulator.exe"
          ASSETS="$GAME_DIR/YandereSimulator_Data/StreamingAssets"
          BACKUP="$GAME_DIR/.save-backup"

          # The zip ships its own SaveData/JSON files, so an in-place update would
          # overwrite the player's saves unless they are put back afterwards.
          if [ "''${1:-}" = "--update" ] && [ -d "$ASSETS" ]; then
            rm -rf "$BACKUP"
            mkdir -p "$BACKUP"
            for p in SaveData SaveFiles CustomMode PortraitsCustom \
              JSON/Custom.json JSON/CustomTopics.json JSON/Misc.json; do
              if [ -e "$ASSETS/$p" ]; then
                mkdir -p "$BACKUP/$(dirname "$p")"
                cp -a "$ASSETS/$p" "$BACKUP/$p"
              fi
            done
          fi

          # The game ships as a plain Windows zip and updates often, so keep it
          # out of the store; --update re-downloads the current build.
          if [ ! -f "$EXE" ] || [ -d "$BACKUP" ]; then
            mkdir -p "$GAME_DIR"
            echo "Downloading Yandere Simulator (~3.5 GiB) ..."
            curl -L --fail --progress-bar \
              -o "$GAME_DIR/latest.zip" \
              https://yanderesimulator.com/dl/latest.zip
            unzip -oq "$GAME_DIR/latest.zip" -d "$GAME_DIR"
            rm -f "$GAME_DIR/latest.zip"
          fi

          if [ -d "$BACKUP" ]; then
            cp -a "$BACKUP/." "$ASSETS/"
            rm -rf "$BACKUP"
          fi

          # Same PRIME offload as the Steam module: the RTX 4060 renders,
          # the AMD iGPU stays the display sink.
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __VK_LAYER_NV_optimus=NVIDIA_only
          export __GLX_VENDOR_LIBRARY_NAME=nvidia

          # GE-Proton outside Steam only works through umu, which supplies the
          # Steam Runtime container Proton expects.
          export WINEPREFIX="$GAME_DIR/prefix"
          export PROTONPATH="${pkgs.proton-ge-bin.steamcompattool}"
          exec ${pkgs.umu-launcher}/bin/umu-run "$EXE"
        '';
      })

      (pkgs.makeDesktopItem {
        name = "yandere-simulator";
        desktopName = "Yandere Simulator";
        comment = "Yandere Simulator via Proton (umu)";
        exec = "yandere-simulator";
        icon = "applications-games";
        categories = [ "Game" ];
      })
    ];
  };
}
