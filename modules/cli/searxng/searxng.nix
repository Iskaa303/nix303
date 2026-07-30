{ config, ... }: {
  flake.modules.nixos.cli_searxng = { lib, ... }: {
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = "/home/iskaa303/.searxng.env";

      settings = {
        general = {
          debug = false;
          instance_name = "SearXNG";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        server = {
          bind_address = "127.0.0.1";
          port = 8888;
          limiter = false;
          public_instance = false;
          image_proxy = true;
          method = "GET";
        };

        botdetection = {
          ip_limit = {
            link_token = false;
          };
          pass_ip = [
            "127.0.0.1"
            "::1"
          ];
        };

        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = false;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = false;
          hotkeys = "vim";
        };

        search = {
          safe_search = 0;
          autocomplete = "duckduckgo";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
          formats = [
            "html"
            "json"
          ];
        };

        enabled_plugins = [
          "Hash plugin"
          "Self Information"
          "Tracker URL remover"
          "Ahmia blacklist"
        ];

        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "duckduckgo".disabled = false;
          "wikipedia".disabled = false;
          "bing".disabled = false;
          "google".disabled = true;
          "brave".disabled = true;
        };
      };
    };

    networking.firewall.interfaces.lo.allowedTCPPorts = [ 8888 ];
  };
}
