{ inputs, ... }: {
  flake.modules.nixos.app_firefox = { config, userVars, lib, pkgs, ... }:
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

    # Home-manager's `bookmarks` writes browser.bookmarks.file, which Firefox no
    # longer reads, so bookmarks come from the enterprise policy instead.
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
      # Home-manager drops the extensions straight into the profile, and
      # Firefox auto-disables anything found outside its default scopes.
      "extensions.enabledScopes" = lib.mkForce 15;
      "extensions.autoDisableScopes" = lib.mkForce 0;
      # librewolf:<profile>/<url> links are handed to the OS dispatcher, so a
      # Sidebery bookmark can bring up the other profile.
      "network.protocol-handler.external.librewolf" = true;
      # Dark chrome everywhere, following the nord palette in userChrome.
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 1;
      "browser.theme.toolbar-theme" = 1;
      "browser.in-content.dark-mode" = true;
      "layout.css.prefers-color-scheme.content-override" = 0;
      "devtools.theme" = "dark";
      # Cookies are isolated per container, so one profile can hold several
      # accounts (personal Google, uni Microsoft, ...) without mixing them.
      "privacy.userContext.enabled" = true;
      "privacy.userContext.ui.enabled" = true;
    };

    # Only for the profiles that carry Sidebery: it becomes the whole tab UI.
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

    # Firefox 128+ clears cookies via privacy.clearOnShutdown_v2.* and ignores
    # the old privacy.clearOnShutdown.cookies, so both are set here.
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

    userChrome = { accent, sidebar }: ''
      /* nord chrome: stylix base00 background, base05 text, square corners */
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
        /* Sidebery is the tab UI, so chrome's tab strip and tool rail go away */
        #TabsToolbar { display: none !important; }
        #sidebar-container,
        #sidebar-launcher-splitter,
        #sidebar-panel-header { display: none !important; }
        #sidebar-box { padding-left: 0 !important; }
      ''}
    '';

    userContent = ''
      @-moz-document url-prefix("about:") {
        :root {
          --in-content-page-background: ${colors.base00} !important;
          --in-content-page-color: ${colors.base05} !important;
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
    # One cookie jar per account. A container cannot change javascript, webgl,
    # webgpu or the extension set; those stay per profile, so there are two:
    # `private` (no JS, no GPU, no cookies) and `main` (JS + GPU, keeps cookies).
    # The uncontainerised tabs of either profile are the "private" jar.
    profileContainers = {
      # hardened runs no javascript and keeps no cookies, so a container would
      # only add a label: no jar to separate.
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
      # the pinned stylix does ship a librewolf target, but it only injects fonts
      stylix.targets.librewolf.profileNames = [ "private" "main" ];

      # Firefox rewrites containers.json on first run (it even adds its own
      # "Shopping" identity), so the declared set is reinstalled every switch
      # from a home-manager file, which keeps the store paths GC-safe.
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

      # Firefox writes its add-on database on first start with every
      # profile-scope extension marked disabled, and the scope prefs never flip
      # one back on. Dropping the database makes it re-detect them enabled.
      # Sidebery also caches Firefox's container list and pushes it back, which
      # is what kept resurrecting a "Shopping" container; its cache is dropped
      # too, so the declared set is the only one.
      home.activation.libreWolfExtensionDb =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for dir in "$HOME"/.librewolf/*/; do
            rm -f "$dir/extensions.json" "$dir/addonStartup.json.lz4"
            # grep exits 1 when a profile has no Sidebery yet, and the activation
            # script runs with -e -o pipefail; swallow it.
            uuid=$(grep -o '3c078156-979c-498b-8990-85f7987dd929}.\{0,8\}[0-9a-f-]\{36\}' "$dir/prefs.js" 2>/dev/null | grep -o '[0-9a-f-]\{36\}$' | head -1 || true)
            if [ -n "$uuid" ]; then
              rm -rf "$dir/storage/default/moz-extension+++""$uuid"*
            fi
          done
        '';

      programs.librewolf = {
        enable = true;

        # home-manager has one policy set per browser, so main and study share a
        # union of their cookie allow-lists; each profile still only visits its own.
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
            settings = webglOff // noCookies // {
              "javascript.enabled" = false;
              "privacy.resistFingerprinting" = true;
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
            settings = webglOn // keptCookies // {
              # LibreWolf ships resistFingerprinting on by default and it spoofs
              # prefers-color-scheme to light, which is what made every site
              # light despite the dark theme prefs.
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
            # librewolf:<profile>/<url> - how Sidebery bookmarks jump between profiles
            librewolf:*) rest="''${arg#librewolf:}"; profile="''${rest%%/*}"; case "$rest" in */*) url="''${rest#*/}" ;; *) url="" ;; esac ;;
            study:*|hardened:*) profile=main; url="''${arg#*:}" ;;
            private|main) profile="$arg"; url="''${2:-}" ;;
            *://*) url="$arg" ;;
          esac
          case "$profile" in private|main) ;; *) profile=main ;; esac
          # Firefox rewrites containers.json on its own (and had inherited an
          # unrelated "Shopping" identity), so the declared set is reinstalled
          # before every launch, not only on rebuild.
          if [ -f "$HOME/.config/librewolf-containers/$profile.json" ]; then
            install -m 0644 "$HOME/.config/librewolf-containers/$profile.json" "$HOME/.librewolf/$profile/containers.json"
          fi
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

        # A container cannot start another browser, but a URL can: these
        # schemes hand the link to the profile that has the right settings.
        librewolf-private = {
          name = "LibreWolf Hardened";
          exec = "librewolf-dispatch private";
          terminal = false;
          mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
        };
      };

      # External links pick a profile by host; clicks inside a browser stay in
      # the profile that opened them, which is deliberate.
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
