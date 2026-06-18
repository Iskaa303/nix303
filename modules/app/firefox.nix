{ inputs, ... }: {
  flake.modules.nixos.app_firefox = { userVars, lib, pkgs, ... }: {
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
            ];
            Behavior = "reject-tracker";
          };
        };

        profiles."${userVars.username}" = {
          id = 0;
          name = userVars.username;
          isDefault = true;

          extensions.force = true;
          
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            sponsorblock
            return-youtube-dislikes
          ];

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

            # Theme matching and styling overrides
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lib.mkForce true;
            "browser.display.use_document_colors" = lib.mkForce true;
            "privacy.resistFingerprinting" = lib.mkForce false;
            "privacy.resistFingerprinting.letterboxing" = lib.mkForce false;
          };
        };
      };
    };
  };
}
