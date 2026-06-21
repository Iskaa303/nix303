{ inputs, ... }: {
  flake.modules.nixos.app_firefox = { config, userVars, lib, pkgs, ... }: {
    nixpkgs.overlays = [ inputs.nur.overlays.default ];

    hm = {
      imports = [
        inputs.arkenfox.hmModules.arkenfox
      ];

      stylix.targets.firefox = {
        profileNames = [ userVars.username ];
        colorTheme.enable = true;
        colors.enable = true;
      };
      
      programs.firefox = {
        enable = true;
        arkenfox = {
          enable = true;
          version = "master";
        };

        policies = {
          Cookies = {
            Allow = [
              "https://google.com"
              "[. ]google.com"
              "https://youtube.com"
              "[. ]youtube.com"
              "https://github.com"
              "[. ]github.com"
              "https://canva.com"
              "[. ]canva.com"
              "https://band.us"
              "[. ]band.us"
              "https://collegeboard.org"
              "[. ]collegeboard.org"
              "https://reddit.com"
              "[. ]reddit.com"
              "https://whatsapp.com"
              "[. ]whatsapp.com"
            ];
            Behavior = "reject-tracker";
          };
        };

        profiles."${userVars.username}" = {
          id = 0;
          name = userVars.username;
          isDefault = true;

          bookmarks = [
            {
              name = "Bookmarks Toolbar";
              toolbar = true;
              bookmarks = [
                {
                  name = "YouTube";
                  url = "https://www.youtube.com";
                }
                {
                  name = "Google Messages";
                  url = "https://messages.google.com";
                }
                {
                  name = "WhatsApp";
                  url = "https://web.whatsapp.com";
                }
              ];
            }
          ];

          extensions.force = true;
          
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            sponsorblock
            return-youtube-dislikes
          ];

          userContent = let
            colors = config.lib.stylix.colors.withHashtag;
            replaceColors = str: lib.replaceStrings
              [
                "@base00@" "@base01@" "@base02@" "@base03@"
                "@base04@" "@base05@" "@base06@" "@base07@"
                "@base08@" "@base09@" "@base0A@" "@base0B@"
                "@base0C@" "@base0D@" "@base0E@" "@base0F@"
              ]
              [
                colors.base00 colors.base01 colors.base02 colors.base03
                colors.base04 colors.base05 colors.base06 colors.base07
                colors.base08 colors.base09 colors.base0A colors.base0B
                colors.base0C colors.base0D colors.base0E colors.base0F
              ]
              str;
          in ''
            ${replaceColors (builtins.readFile ./youtube.css)}
            ${replaceColors (builtins.readFile ./messages.css)}
            ${replaceColors (builtins.readFile ./whatsapp.css)}
          '';

          arkenfox = {
            enable = true;
            enableAllSections = true;
          };

          settings = {
            # Re-enable search suggestions in address bar and search bar
            "browser.search.suggest.enabled" = lib.mkForce true;
            "browser.urlbar.suggest.searches" = lib.mkForce true;
            "browser.search.suggest.enabled.private" = lib.mkForce true;

            # Keep search updates
            "browser.search.update" = lib.mkForce true;

            # Enable extensions
            "extensions.enabledScopes" = lib.mkForce 15;
            "extensions.autoDisableScopes" = lib.mkForce 0;

            # Prevent clearing cookies & storage on shutdown globally so exception list works
            "privacy.clearOnShutdown.cookies" = lib.mkForce false;
            "privacy.clearOnShutdown.offlineApps" = lib.mkForce false;

            # Force Bookmarks Toolbar to show
            "browser.toolbars.bookmarks.visibility" = lib.mkForce "always";

            # Theme matching and styling overrides
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lib.mkForce true;
            "layout.css.moz-document.content.enabled" = lib.mkForce true;
            "browser.display.use_document_colors" = lib.mkForce true;
            "browser.display.document_color_use" = lib.mkForce 1;

            # Disable RFP blocks that mess with custom CSS & elements
            "privacy.resistFingerprinting" = lib.mkForce false;
            "privacy.resistFingerprinting.letterboxing" = lib.mkForce false;
          };
        };
      };
    };
  };
}
