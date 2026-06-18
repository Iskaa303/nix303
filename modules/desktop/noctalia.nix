{ inputs, ... }: {
  flake.modules.nixos.desktop_noctalia = { config, ... }: {
    services.upower.enable = true;

    hm = {
      imports = [inputs.noctalia.homeModules.default];
      programs.noctalia = {
        enable = true;
        settings = {
          widget.clock = {
            format = "{:%Y-%m-%d %H:%M:%S}";
          };
          bar = {
            end = [
              "media"
              "tray"
              "notifications"
              "clipboard"
              "network"
              "bluetooth"
              "keyboard_layout"
              "volume"
              "brightness"
              "battery"
              "control-center"
              "session"
            ];
          };
          theme = {
            mode = "dark";
            source = "custom";
            custom_palette = "stylix-theme";
          };
          templates = {
            enable_builtin_templates = false;
            enable_community_templates = false;
          };
          wallpaper = {
            enabled = true;
            directory = "/persist/etc/nixos/assets";
            default.path = "/persist/etc/nixos/assets/wallpaper.png";
          };
        };
        customPalettes = {
          "stylix-theme" = {
            dark = {
              mPrimary = "#${config.lib.stylix.colors.base0D}";
              mOnPrimary = "#${config.lib.stylix.colors.base00}";
              mSecondary = "#${config.lib.stylix.colors.base0C}";
              mOnSecondary = "#${config.lib.stylix.colors.base00}";
              mTertiary = "#${config.lib.stylix.colors.base0E}";
              mOnTertiary = "#${config.lib.stylix.colors.base00}";
              mError = "#${config.lib.stylix.colors.base08}";
              mOnError = "#${config.lib.stylix.colors.base00}";
              mSurface = "#${config.lib.stylix.colors.base00}";
              mOnSurface = "#${config.lib.stylix.colors.base05}";
              mSurfaceVariant = "#${config.lib.stylix.colors.base01}";
              mOnSurfaceVariant = "#${config.lib.stylix.colors.base04}";
              mOutline = "#${config.lib.stylix.colors.base03}";
              mShadow = "#${config.lib.stylix.colors.base00}";
              mHover = "#${config.lib.stylix.colors.base0D}";
              mOnHover = "#${config.lib.stylix.colors.base00}";
              terminal = {
                normal = {
                  black = "#${config.lib.stylix.colors.base00}";
                  red = "#${config.lib.stylix.colors.base08}";
                  green = "#${config.lib.stylix.colors.base0B}";
                  yellow = "#${config.lib.stylix.colors.base0A}";
                  blue = "#${config.lib.stylix.colors.base0D}";
                  magenta = "#${config.lib.stylix.colors.base0E}";
                  cyan = "#${config.lib.stylix.colors.base0C}";
                  white = "#${config.lib.stylix.colors.base05}";
                };
                bright = {
                  black = "#${config.lib.stylix.colors.base03}";
                  red = "#${config.lib.stylix.colors.base08}";
                  green = "#${config.lib.stylix.colors.base0B}";
                  yellow = "#${config.lib.stylix.colors.base0A}";
                  blue = "#${config.lib.stylix.colors.base0D}";
                  magenta = "#${config.lib.stylix.colors.base0E}";
                  cyan = "#${config.lib.stylix.colors.base0C}";
                  white = "#${config.lib.stylix.colors.base07}";
                };
                foreground = "#${config.lib.stylix.colors.base05}";
                background = "#${config.lib.stylix.colors.base00}";
                selectionFg = "#${config.lib.stylix.colors.base00}";
                selectionBg = "#${config.lib.stylix.colors.base0D}";
                cursorText = "#${config.lib.stylix.colors.base00}";
                cursor = "#${config.lib.stylix.colors.base05}";
              };
            };
            light = {
              mPrimary = "#${config.lib.stylix.colors.base0D}";
              mOnPrimary = "#${config.lib.stylix.colors.base00}";
              mSecondary = "#${config.lib.stylix.colors.base0C}";
              mOnSecondary = "#${config.lib.stylix.colors.base00}";
              mTertiary = "#${config.lib.stylix.colors.base0E}";
              mOnTertiary = "#${config.lib.stylix.colors.base00}";
              mError = "#${config.lib.stylix.colors.base08}";
              mOnError = "#${config.lib.stylix.colors.base00}";
              mSurface = "#${config.lib.stylix.colors.base00}";
              mOnSurface = "#${config.lib.stylix.colors.base05}";
              mSurfaceVariant = "#${config.lib.stylix.colors.base01}";
              mOnSurfaceVariant = "#${config.lib.stylix.colors.base04}";
              mOutline = "#${config.lib.stylix.colors.base03}";
              mShadow = "#${config.lib.stylix.colors.base00}";
              mHover = "#${config.lib.stylix.colors.base0D}";
              mOnHover = "#${config.lib.stylix.colors.base00}";
              terminal = {
                normal = {
                  black = "#${config.lib.stylix.colors.base00}";
                  red = "#${config.lib.stylix.colors.base08}";
                  green = "#${config.lib.stylix.colors.base0B}";
                  yellow = "#${config.lib.stylix.colors.base0A}";
                  blue = "#${config.lib.stylix.colors.base0D}";
                  magenta = "#${config.lib.stylix.colors.base0E}";
                  cyan = "#${config.lib.stylix.colors.base0C}";
                  white = "#${config.lib.stylix.colors.base05}";
                };
                bright = {
                  black = "#${config.lib.stylix.colors.base03}";
                  red = "#${config.lib.stylix.colors.base08}";
                  green = "#${config.lib.stylix.colors.base0B}";
                  yellow = "#${config.lib.stylix.colors.base0A}";
                  blue = "#${config.lib.stylix.colors.base0D}";
                  magenta = "#${config.lib.stylix.colors.base0E}";
                  cyan = "#${config.lib.stylix.colors.base0C}";
                  white = "#${config.lib.stylix.colors.base07}";
                };
                foreground = "#${config.lib.stylix.colors.base05}";
                background = "#${config.lib.stylix.colors.base00}";
                selectionFg = "#${config.lib.stylix.colors.base00}";
                selectionBg = "#${config.lib.stylix.colors.base0D}";
                cursorText = "#${config.lib.stylix.colors.base00}";
                cursor = "#${config.lib.stylix.colors.base05}";
              };
            };
          };
        };
      };
    };
  };
}
