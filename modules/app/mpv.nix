{ ... }: {
  flake.modules.nixos.app_mpv = { config, pkgs, ... }: {
    hm = {
      # Disable default stylix mpv target to use our custom tailored rules
      stylix.targets.mpv.enable = false;

      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          mpris
        ];
        config = {
          # Required for uosc proximity-based interface
          osc = "no";
          border = "no";
          osd-bar = "no";

          # Subtitle styling (Stylix colors & fonts)
          sub-font = config.stylix.fonts.sansSerif.name;
          sub-font-size = 36;
          sub-color = "#${config.lib.stylix.colors.base05}";
          sub-border-color = "#${config.lib.stylix.colors.base00}";
          sub-border-size = 3;
          sub-shadow-color = "#${config.lib.stylix.colors.base00}";
          sub-shadow-offset = 1;

          # OSD styling (Stylix colors & fonts)
          osd-font = config.stylix.fonts.sansSerif.name;
          osd-font-size = 30;
          osd-color = "#${config.lib.stylix.colors.base05}";
          osd-border-color = "#${config.lib.stylix.colors.base00}";
          osd-border-size = 2;
          osd-shadow-color = "#${config.lib.stylix.colors.base00}";
          osd-shadow-offset = 1;

          # Quality & playback settings
          keep-open = "yes";
          profile = "gpu-hq";
          vo = "gpu";
          hwdec = "auto-safe";

          # Prevent window from opening in full video resolution size
          autofit-large = "90%x90%";

          # Allow window to resize freely and draw black bars instead of stretching/altering window size
          keepaspect-window = "no";
        };
        scriptOpts = {
          uosc = {
            # uosc colors mapped to Stylix base16 colors (Nord scheme)
            color = "foreground=${config.lib.stylix.colors.base0D},foreground_text=${config.lib.stylix.colors.base00},background=${config.lib.stylix.colors.base00},background_text=${config.lib.stylix.colors.base05}";
          };
        };
      };
    };
  };
}
