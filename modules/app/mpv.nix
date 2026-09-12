{ ... }: {
  flake.modules.nixos.app_mpv = { config, lib, pkgs, ... }: {
    hm = {
      stylix.targets.mpv.enable = true;

      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          mpris
          mpv-image-viewer.image-positioning
          mpv-image-viewer.minimap
          mpv-image-viewer.ruler
          mpv-image-viewer.equalizer
          mpv-image-viewer.detect-image
        ];
        config = {
          osc = "no";
          border = "no";
          osd-bar = "no";

          sub-font-size = 36;
          sub-border-size = 3;
          sub-shadow-offset = 1;

          osd-font-size = 30;
          osd-border-size = 2;
          osd-shadow-offset = 1;

          keep-open = "yes";
          image-display-duration = "inf";
          profile = "gpu-hq";
          vo = "gpu";
          hwdec = "auto-copy-safe";

          autofit-larger = "90%x90%";

          keepaspect-window = "no";
        };
        scriptOpts = {
          uosc = {
            color = lib.mkForce (with config.lib.stylix.colors; "foreground=${base0D},foreground_text=${base00},background=${base00},background_text=${base05}");
          };
          detect_image = {
            command_on_first_image_loaded = "enable-section image-viewer";
            command_on_non_image_loaded = "disable-section image-viewer";
          };
        };

        extraInput = ''
          [image-viewer]
          WHEEL_UP   script-binding cursor-centric-zoom 0.1
          WHEEL_DOWN script-binding cursor-centric-zoom -0.1
          MBTN_RIGHT  script-binding drag-to-pan
        '';
      };
    };
  };
}
