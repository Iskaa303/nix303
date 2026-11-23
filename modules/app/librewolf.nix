{ inputs, ... }: {
  flake.modules.nixos.app_librewolf = { config, userVars, lib, pkgs, ... }:
  let
    colors = config.lib.stylix.colors.withHashtag;
    addons = pkgs.nur.repos.rycee.firefox-addons;
    sidebery = "{3c078156-979c-498b-8990-85f7987dd929}";

    search = {
      force = true;
      default = "SearXNG";
      privateDefault = "SearXNG";
      engines = {
        "SearXNG" = {
          urls = [{ template = "http://localhost:8888/search?q={searchTerms}"; }];
          icon = "http://localhost:8888/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = [ "@sx" ];
        };
        "google".metaData.hidden = true;
        "bing".metaData.hidden = true;
        "ddg".metaData.hidden = true;
        "wikipedia".metaData.hidden = true;
      };
    };

    # hm's `bookmarks` writes a file LibreWolf no longer reads.
    bookmarks = [
      { Title = "YouTube"; URL = "https://www.youtube.com"; Placement = "toolbar"; }
      { Title = "Google Messages"; URL = "https://messages.google.com"; Placement = "toolbar"; }
      { Title = "WhatsApp"; URL = "https://web.whatsapp.com"; Placement = "toolbar"; }
      { Title = "CMS Launchpad"; URL = "https://launchpad.classlink.com/cmsk12"; Placement = "toolbar"; }
      { Title = "Brightspace CPCC"; URL = "https://brightspace.cpcc.edu"; Placement = "toolbar"; }
      { Title = "Open Hardened profile"; URL = "librewolf:private"; Placement = "menu"; }
      { Title = "Open Main profile"; URL = "librewolf:main"; Placement = "menu"; }
    ];

    commonPrefs = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "sidebar.position_start" = true;
      # hm drops the extensions into the profile; LibreWolf disables those scopes.
      "extensions.enabledScopes" = lib.mkForce 15;
      "extensions.autoDisableScopes" = lib.mkForce 0;
      "network.protocol-handler.external.librewolf" = true;
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 1;
      "browser.theme.toolbar-theme" = 1;
      "browser.in-content.dark-mode" = true;
      "layout.css.prefers-color-scheme.content-override" = 0;
      "devtools.theme" = "dark";
      "privacy.userContext.enabled" = true;
      "privacy.userContext.ui.enabled" = true;
    };

    sideberyPrefs = {
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "always-show";
      "sidebar.main.tools" = sidebery;
      "sidebar.backupState" = builtins.toJSON {
        command = "_${sidebery}_-sidebar-action";
        panelOpen = true;
        panelWidth = 320;
        userLauncherVisible = true;
      };
    };

    webglOff = {
      "webgl.disabled" = true;
      "webgl.force-enabled" = false;
      "dom.webgpu.enabled" = false;
    };

    webglOn = {
      "webgl.disabled" = false;
      "webgl.force-enabled" = true;
      "dom.webgpu.enabled" = true;
    };

    # LibreWolf 128+ only honours privacy.clearOnShutdown_v2.*.
    noCookies = {
      "network.cookie.lifetimePolicy" = 2;
      "privacy.sanitize.sanitizeOnShutdown" = true;
      "privacy.clearOnShutdown.cookies" = true;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
    };

    keptCookies = {
      "network.cookie.lifetimePolicy" = 0;
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    };

    # RFP's per-target twin: same uniformisation, without the light colour scheme.
    fingerprintProtection = {
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" =
        "+AllTargets,-CSSPrefersColorScheme";
    };
    # FPP's UA targets veto general.useragent.override.
    fingerprintProtectionSpoofedUa = fingerprintProtection // {
      "privacy.fingerprintingProtection.overrides" =
        "+AllTargets,-CSSPrefersColorScheme,-NavigatorUserAgent,-HttpUserAgent";
    };

    userChrome = { accent, sidebar }: ''
      * { border-radius: 0 !important; }
      #navigator-toolbox,
      #nav-bar,
      #TabsToolbar,
      #PersonalToolbar,
      #sidebar-box,
      #sidebar-main { background-color: ${colors.base00} !important; }
      #nav-bar,
      #TabsToolbar,
      #PersonalToolbar { color: ${colors.base05} !important; }
      #urlbar-background {
        background-color: ${colors.base01} !important;
        color: ${colors.base05} !important;
        border: 2px solid ${accent} !important;
      }
      #navigator-toolbox { border-bottom: 2px solid ${colors.base02} !important; }
      #sidebar-header { display: none !important; }
      ${lib.optionalString sidebar ''
        #TabsToolbar { display: none !important; }
        #sidebar-container,
        #sidebar-launcher-splitter,
        #sidebar-panel-header { display: none !important; }
        #sidebar-box { padding-left: 0 !important; }
      ''}
    '';

    # Sidebery writes its theme as inline --s-* vars, so only user !important wins.
    userContent = ''
      @-moz-document url-prefix("about:") {
        :root {
          --in-content-page-background: ${colors.base00} !important;
          --in-content-page-color: ${colors.base05} !important;
        }
      }
      @-moz-document url-prefix("moz-extension://") {
        body {
          --s-frame-bg: ${colors.base00} !important;
          --s-frame-fg: ${colors.base05} !important;
          --s-toolbar-bg: ${colors.base01} !important;
          --s-toolbar-fg: ${colors.base05} !important;
          --s-toolbar-border: ${colors.base03} !important;
          --s-act-el-bg: ${colors.base02} !important;
          --s-act-el-fg: ${colors.base06} !important;
          --s-act-el-border: ${colors.base0D} !important;
          --s-popup-bg: ${colors.base01} !important;
          --s-popup-fg: ${colors.base05} !important;
          --s-popup-border: ${colors.base03} !important;
          --s-accent: ${colors.base0D} !important;
        }
      }
    '';

    mkProfile = { id, accent, settings, extensions, sidebar ? true, isDefault ? false }: {
      inherit id isDefault;
      settings = commonPrefs // (if sidebar then sideberyPrefs else { }) // settings;
      userChrome = userChrome { inherit accent sidebar; };
      inherit userContent search;
      extensions = {
        force = true;
        packages = extensions;
      };
    };

    containerColors = [ "blue" "turquoise" "green" "orange" "pink" "purple" ];
    containersFor = names: builtins.toJSON {
      version = 5;
      lastUserContextId = builtins.length names;
      identities = lib.imap0 (i: name: {
        userContextId = i + 1;
        public = true;
        icon = "circle";
        color = lib.elemAt containerColors (lib.mod i (builtins.length containerColors));
        name = name;
        accessKey = "";
        l10nID = "";
      }) names;
    };
    # Containers isolate cookies only, so JS and the GPU split by profile.
    profileContainers = {
      private = [ ];
      main = [ "General" "Study" "Hardened" ];
    };

    studySites = [
      "brightspace.com" "cpcc.edu" "classlink.com" "launchpad.classlink.com"
      "microsoftonline.com" "office.com" "live.com" "collegeboard.org"
    ];
    mainSites = [
      "google.com" "youtube.com" "whatsapp.com" "amazon.com" "reddit.com"
      "github.com" "canva.com" "codeberg.org"
    ];
    cookieAllow = lib.concatMap (s: [ "https://${s}" "[. ]${s}" ]) (mainSites ++ studySites);
  in {
    nixpkgs.overlays = [ inputs.nur.overlays.default ];

    hm = {
      stylix.targets.librewolf.profileNames = [ "private" "main" ];

      # LibreWolf rewrites containers.json on first run and adds "Shopping".
      home.file = lib.mapAttrs' (profile: names: lib.nameValuePair ".config/librewolf-containers/${profile}.json" { text = containersFor names; }) (
        lib.filterAttrs (_: names: names != [ ]) profileContainers
      );

      home.activation.libreWolfContainers =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.concatStrings (
            lib.mapAttrsToList (profile: names: if names == [ ] then ''
              rm -f "$HOME/.librewolf/${profile}/containers.json"
            '' else ''
              install -m 0644 "$HOME/.config/librewolf-containers/${profile}.json" "$HOME/.librewolf/${profile}/containers.json"
            '') profileContainers
          )
        );

      # LibreWolf disables profile-scope add-ons and Sidebery caches containers.
      home.activation.libreWolfExtensionDb =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for dir in "$HOME"/.librewolf/*/; do
            rm -f "$dir/extensions.json" "$dir/addonStartup.json.lz4"
            # grep exits 1 on a profile without Sidebery, and activation runs -e -o pipefail.
            uuid=$(grep -o '3c078156-979c-498b-8990-85f7987dd929}.\{0,8\}[0-9a-f-]\{36\}' "$dir/prefs.js" 2>/dev/null | grep -o '[0-9a-f-]\{36\}$' | head -1 || true)
            if [ -n "$uuid" ]; then
              rm -rf "$dir/storage/default/moz-extension+++""$uuid"*
            fi
          done
        '';

      # nothing an earlier config wrote into the hardened profile survives.
      home.activation.libreWolfHardenedWipe =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          rm -f "$HOME"/.librewolf/private/places.sqlite* \
                "$HOME"/.librewolf/private/cookies.sqlite* \
                "$HOME"/.librewolf/private/sessionstore.jsonlz4
        '';

      programs.librewolf = {
        enable = true;

        # one policy set per browser, so both profiles share the cookie allow-list
        policies = {
          Cookies = {
            Behavior = "reject-tracker";
            Allow = cookieAllow;
          };
          Bookmarks = bookmarks;
        };

        profiles = {
          private = mkProfile {
            id = 1;
            isDefault = false;
            sidebar = true;
            accent = colors.base08;
            extensions = [ addons.ublock-origin addons.sidebery ];
            settings = webglOff // noCookies // fingerprintProtectionSpoofedUa // {
              "javascript.enabled" = false;
              # RFP would only veto the UA override; its JS targets never run.
              "privacy.resistFingerprinting" = false;
              "general.useragent.override" =
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0";
              "places.history.enabled" = false;
              # policy bookmarks are installation-wide, so they are hidden here
              "browser.toolbars.bookmarks.visibility" = "never";
            };
          };

          main = mkProfile {
            id = 0;
            isDefault = true;
            accent = colors.base0D;
            extensions = [
              addons.ublock-origin
              addons.sponsorblock
              addons.return-youtube-dislikes
              addons.sidebery
            ];
            settings = webglOn // keptCookies // fingerprintProtection // {
              # resistFingerprinting spoofs prefers-color-scheme to light.
              "privacy.resistFingerprinting" = false;
            };
          };
        };
      };

      home.packages = [
        (pkgs.writeShellScriptBin "librewolf-dispatch" ''
          arg="''${1:-}"
          profile=main
          url=""
          case "$arg" in
            # librewolf:<profile>/<url> is how Sidebery bookmarks switch profiles
            librewolf:*) rest="''${arg#librewolf:}"; profile="''${rest%%/*}"; case "$rest" in */*) url="''${rest#*/}" ;; *) url="" ;; esac ;;
            study:*|hardened:*) profile=main; url="''${arg#*:}" ;;
            private|main) profile="$arg"; url="''${2:-}" ;;
            *://*) url="$arg" ;;
          esac
          case "$profile" in private|main) ;; *) profile=main ;; esac
          if [ -f "$HOME/.config/librewolf-containers/$profile.json" ]; then
            install -m 0644 "$HOME/.config/librewolf-containers/$profile.json" "$HOME/.librewolf/$profile/containers.json"
          fi
          # Sidebery's storage records the tabs it saw, i.e. history.
          if [ "$profile" = private ]; then
            rm -rf "$HOME/.librewolf/private/storage/default/moz-extension+++"*
          fi
          # a separate wayland app-id is what niri keys the violet border on.
          [ "$profile" = private ] && export MOZ_APP_REMOTINGNAME=librewolf-hardened
          if [ -n "$url" ]; then
            exec ${config.home-manager.users.${userVars.username}.programs.librewolf.finalPackage}/bin/librewolf -P "$profile" "$url"
          fi
          exec ${config.home-manager.users.${userVars.username}.programs.librewolf.finalPackage}/bin/librewolf -P "$profile"
        '')
      ];

      xdg.desktopEntries = {
        librewolf-dispatch = {
          name = "LibreWolf";
          exec = "librewolf-dispatch %u";
          terminal = false;
          mimeType = [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/librewolf"
          ];
        };

        librewolf-private = {
          name = "LibreWolf Hardened";
          exec = "librewolf-dispatch private";
          terminal = false;
          mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "librewolf-dispatch.desktop";
          "x-scheme-handler/http" = "librewolf-dispatch.desktop";
          "x-scheme-handler/https" = "librewolf-dispatch.desktop";
          "x-scheme-handler/librewolf-study" = "librewolf-dispatch.desktop";
          "x-scheme-handler/librewolf-hardened" = "librewolf-dispatch.desktop";
          "x-scheme-handler/librewolf" = "librewolf-dispatch.desktop";
        };
      };
    };
  };
}
