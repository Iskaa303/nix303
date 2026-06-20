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
          profile = "gpu-hq";
          vo = "gpu";
          hwdec = "auto-safe";

          autofit-large = "90%x90%";

          keepaspect-window = "no";
        };
        scriptOpts = {
          uosc = {
            color = lib.mkForce (with config.lib.stylix.colors; "foreground=${base0D},foreground_text=${base00},background=${base00},background_text=${base05}");
          };
        };
      };
    };
  };
}
