{ inputs, ... }: {
  flake.modules.nixos.app_whatsapp = { config, lib, pkgs, ... }: let
    # Helper to convert hex colors to decimal r, g, b values
    hexToDec = hexVal: {
      "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
      "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
      "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
    }.${hexVal};

    hexPairToDec = s: (hexToDec (builtins.substring 0 1 s)) * 16 + (hexToDec (builtins.substring 1 1 s));

    hexToRgb = hex: let
      r = toString (hexPairToDec (builtins.substring 0 2 hex));
      g = toString (hexPairToDec (builtins.substring 2 2 hex));
      b = toString (hexPairToDec (builtins.substring 4 2 hex));
    in "${r}, ${g}, ${b}";

    # Extract base16 colors from stylix
    base00 = config.lib.stylix.colors.base00; # Base background
    base01 = config.lib.stylix.colors.base01; # Lighter background
    base02 = config.lib.stylix.colors.base02; # Selection/bubble background
    base03 = config.lib.stylix.colors.base03; # Deemphasized text
    base04 = config.lib.stylix.colors.base04; # Lighter text
    base05 = config.lib.stylix.colors.base05; # Main text
    base07 = config.lib.stylix.colors.base07; # Lighter/white text
    base08 = config.lib.stylix.colors.base08; # Red
    base09 = config.lib.stylix.colors.base09; # Orange
    base0A = config.lib.stylix.colors.base0A; # Yellow
    base0B = config.lib.stylix.colors.base0B; # Green
    base0C = config.lib.stylix.colors.base0C; # Cyan
    base0D = config.lib.stylix.colors.base0D; # Blue / Accent
    base0E = config.lib.stylix.colors.base0E; # Magenta

    rgb00 = hexToRgb base00;
    rgb01 = hexToRgb base01;
    rgb02 = hexToRgb base02;
    rgb03 = hexToRgb base03;
    rgb04 = hexToRgb base04;
    rgb05 = hexToRgb base05;
    rgb0D = hexToRgb base0D;

    patchedKarere = pkgs.karere.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace src/window.rs \
          --replace 'ucm.add_script(&chrome_spoof_script);' 'ucm.add_script(&chrome_spoof_script);

                let custom_css_path = glib::user_config_dir().join("karere").join("custom.css");
                if custom_css_path.exists() {
                    if let Ok(css_content) = std::fs::read_to_string(&custom_css_path) {
                        let stylesheet = webkit6::UserStyleSheet::new(
                            &css_content,
                            webkit6::UserContentInjectedFrames::TopFrame,
                            webkit6::UserStyleLevel::User,
                            &[],
                            &[]
                      );
                      ucm.add_style_sheet(&stylesheet);
                      log::info!("Injected custom CSS from {}", custom_css_path.display());
                  }
              }'
      '';
    });
  in {
    hm = {
      home.packages = [
        patchedKarere
      ];

      home.file.".config/karere/custom.css".text = ''
        /* Override variables for both dark/light contexts on WhatsApp Web */
        :root, .dark, .color-refresh, .app-wrapper-web {
          --WDS-accent: #${base0D} !important;
          --WDS-accent-rgb: ${rgb0D} !important;
          --WDS-accent-RGB: ${rgb0D} !important;
          --WDS-accent-emphasized: #${base0D} !important;

          --WDS-content-default: #${base05} !important;
          --WDS-content-default-rgb: ${rgb05} !important;
          --WDS-content-deemphasized: #${base04} !important;
          --WDS-content-disabled: #${base03} !important;
          --WDS-content-on-accent: #${base00} !important;
          --WDS-content-action-default: #${base0D} !important;
          --WDS-content-action-emphasized: #${base0D} !important;
          --WDS-content-external-link: #${base0C} !important;
          --WDS-content-inverse: #${base07} !important;
          --WDS-content-read: #${base0D} !important;

          --WDS-background-wash-inset: #${base00} !important;
          --WDS-background-wash-plain: #${base00} !important;
          --WDS-background-elevated-wash-plain: #${base00} !important;
          --WDS-background-elevated-wash-inset: #${base00} !important;
          --WDS-modal-backdrop-solid: #${base00} !important;

          --WDS-surface-default: #${base00} !important;
          --WDS-surface-emphasized: #${base01} !important;
          --WDS-surface-elevated-default: #${base01} !important;
          --WDS-surface-elevated-emphasized: #${base01} !important;
          --WDS-surface-highlight: #${base02} !important;
          --WDS-surface-inverse: #${base05} !important;
          --WDS-surface-pressed: #${base02} !important;

          --WDS-lines-divider: #${base02} !important;
          --WDS-lines-outline-default: #${base02} !important;
          --WDS-lines-outline-deemphasized: #${base02} !important;

          --WDS-systems-bubble-surface-incoming: #${base01} !important;
          --WDS-systems-bubble-surface-outgoing: #${base02} !important;
          --WDS-systems-bubble-content-deemphasized: #${base03} !important;
          --WDS-systems-bubble-surface-overlay: #${base00} !important;
          --WDS-systems-bubble-surface-system: #${base00} !important;

          --WDS-systems-chat-surface-composer: #${base01} !important;
          --WDS-systems-chat-background-wallpaper: #${base00} !important;
          --WDS-systems-chat-foreground-wallpaper: #${base00} !important;
          --WDS-systems-chat-surface-tray: #${base00} !important;
          --WDS-systems-status-seen: #${base03} !important;

          --WDS-components-surface-nav-bar: #${base00} !important;
          --WDS-app-wash: #${base00} !important;

          --WDS-secondary-negative: #${base08} !important;
          --WDS-secondary-positive: #${base0B} !important;
          --WDS-secondary-warning: #${base0A} !important;

          /* Native/Legacy properties fallback */
          --app-background: #${base00} !important;
          --app-background-rgb: ${rgb00} !important;
          --background-default: #${base00} !important;
          --background-default-rgb: ${rgb00} !important;
          --panel-background: #${base00} !important;
          --panel-background-rgb: ${rgb00} !important;
          --panel-background-colored: #${base01} !important;
          --panel-header-background: #${base01} !important;
          --dropdown-background: #${base01} !important;
          --dropdown-background-rgb: ${rgb01} !important;
          --message-primary: #${base05} !important;
          --primary: #${base05} !important;
          --secondary: #${base04} !important;
          --incoming-chat-bubble: #${base01} !important;
          --outgoing-chat-bubble: #${base02} !important;
          --system-message-background: #${base01} !important;
          --compose-input-background: #${base01} !important;
          --search-input-background: #${base01} !important;
          --active-tab-marker: #${base0D} !important;
          --accent: #${base0D} !important;
          --button-primary: #${base0D} !important;
        }

        body {
          background-color: #${base00} !important;
          color: #${base05} !important;
        }
      '';
    };
  };
}
