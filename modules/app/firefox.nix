{ inputs, ... }: {
  flake.modules.nixos.app_firefox = { username, lib, ... }: {
    hm = {
      imports = [ inputs.arkenfox.hmModules.arkenfox ];

      stylix.targets.firefox.profileNames = [ username ];

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
              "https://accounts.google.com"
              "https://www.google.com"
              "https://youtube.com"
              "https://mail.google.com"
            ];
            Behavior = "reject-tracker";
          };
        };

        profiles."${username}" = {
          id = 0;
          name = username;
          isDefault = true;

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
          };
        };
      };
    };
  };
}
