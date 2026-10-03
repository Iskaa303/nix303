{ ... }: {
  flake.modules.nixos.app_mpv =
    { config, lib, pkgs, ... }:
    let
      autosub = pkgs.mpvScripts.buildLua {
        pname = "mpv-autosub";
        version = "0-unstable-2021-06-29";
        scriptPath = "autosub.lua";
        src = ./autosub;
        preInstall = ''
          substituteInPlace autosub.lua --replace-fail \
            "local subliminal = '/home/david/.local/bin/subliminal'" \
            "local subliminal = '${lib.getExe' pkgs.python3Packages.subliminal "subliminal"}'"
        '';
        meta = {
          description = "Fully automatic subtitle downloading for the MPV media player";
          homepage = "https://github.com/davidde/mpv-autosub";
          license = lib.licenses.mit;
        };
      };
    in
    {
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
            mpv-subtitle-lines
            autosub
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
          # mpv-subtitle-lines needs a subtitle track selected, but we don't want to
          # always SEE subs. Hide non-forced subs when the audio is a language we
          # understand (mpv-subtitle-lines README "I don't want to always see subtitles").
          profiles.hide-subtitles = {
            profile-cond = "not get('current-tracks/sub/forced') and (function() local hide_for = {'ru','rus','en','eng'} local a = get('current-tracks/audio/lang') a = a and a:match('^%w+') for _, hl in ipairs(hide_for) do if a == hl then return true end end end)()";
            profile-restore = "copy";
            sub-visibility = "no";
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
          bindings = {
            "Ctrl+f" = "script-binding subtitle_lines/list_subtitles";
            "Ctrl+F" = "script-binding subtitle_lines/list_secondary_subtitles";
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
