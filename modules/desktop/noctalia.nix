{ inputs, ... }: {
  flake.modules.nixos.desktop_noctalia = { config, lib, pkgs, ... }: {
    services.upower.enable = true;

    hm = {
      # niri-flake ships its own programs.noctalia Home Manager module and
      # already imports it via nixosModules.niri, so it declares
      # programs.noctalia.checkConfig too. Importing the noctalia-shell flake's
      # homeModules.default on top of that is a duplicate option definition and
      # fails the eval with "already declared". Both modules write the same
      # files (noctalia/config.toml, noctalia/palettes/*.json), so take the
      # module from niri-flake and the pinned package from the flake.
      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
            custom_palette = lib.mkForce "stylix-theme";
          };
          templates = {
            enable_builtin_templates = false;
            enable_community_templates = false;
          };
          wallpaper = {
            enabled = true;
            directory = "/persist/etc/nixos/assets";
            default.path = lib.mkForce "/persist/etc/nixos/assets/wallpaper.png";
          };
        };
        customPalettes = {
          "stylix-theme" = with config.lib.stylix.colors.withHashtag; {
            dark = {
              mPrimary = base0D;
              mOnPrimary = base00;
              mSecondary = base0C;
              mOnSecondary = base00;
              mTertiary = base0E;
              mOnTertiary = base00;
              mError = base08;
              mOnError = base00;
              mSurface = base00;
              mOnSurface = base05;
              mSurfaceVariant = base01;
              mOnSurfaceVariant = base04;
              mOutline = base03;
              mShadow = base00;
              mHover = base0D;
              mOnHover = base00;
              terminal = {
                normal = {
                  black = base00;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base05;
                };
                bright = {
                  black = base03;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base07;
                };
                foreground = base05;
                background = base00;
                selectionFg = base00;
                selectionBg = base0D;
                cursorText = base00;
                cursor = base05;
              };
            };
            light = {
              mPrimary = base0D;
              mOnPrimary = base00;
              mSecondary = base0C;
              mOnSecondary = base00;
              mTertiary = base0E;
              mOnTertiary = base00;
              mError = base08;
              mOnError = base00;
              mSurface = base00;
              mOnSurface = base05;
              mSurfaceVariant = base01;
              mOnSurfaceVariant = base04;
              mOutline = base03;
              mShadow = base00;
              mHover = base0D;
              mOnHover = base00;
              terminal = {
                normal = {
                  black = base00;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base05;
                };
                bright = {
                  black = base03;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base07;
                };
                foreground = base05;
                background = base00;
                selectionFg = base00;
                selectionBg = base0D;
                cursorText = base00;
                cursor = base05;
              };
            };
          };
        };
      };
    };
  };
}
