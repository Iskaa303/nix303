{ inputs, ... }: {
  flake.modules.nixos.app_thunderbird = { config, userVars, pkgs, ... }: {
    imports = [ inputs.dove.nixosModules.default ];

    hm.programs.thunderbird = {
      enable = true;
      profiles."${userVars.username}" = {
        isDefault = true;
        # ponytail: old-style search prefs; modern TB may need policy-based
        # search engine config. If search doesn't work, set up in GUI.
        settings = {
          "browser.search.defaultenginename" = "SearXNG";
          "browser.search.defaulturl" = "http://localhost:8888/search?q={searchTerms}";
        };
      };
    };
  };
}
