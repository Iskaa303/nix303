{ inputs, ... }: {
  flake.modules.nixos.app_karere = { config, lib, pkgs, ... }: let
    base = config.lib.stylix.colors;
    rgb = color: "${base."${color}-rgb-r"}, ${base."${color}-rgb-g"}, ${base."${color}-rgb-b"}";

    rgb00 = rgb "base00";
    rgb01 = rgb "base01";
    rgb02 = rgb "base02";
    rgb03 = rgb "base03";
    rgb04 = rgb "base04";
    rgb05 = rgb "base05";
    rgb0D = rgb "base0D";

    cef-binary-karere = pkgs.stdenv.mkDerivation {
      pname = "cef-binary-karere";
      version = "148.0.10";

      src = pkgs.fetchurl {
        url = "https://github.com/tobagin/karere/releases/download/cef-148.0.10-proprietary-codecs-151fix/cef_binary_148.0.10%2Bg7ee53f5%2Bchromium-148.0.7778.218_linux64_minimal.zip";
        hash = "sha256-jDiKUDoXBuPrCfhD3vQZlggvgGknrny9C+e8NpgaFk0=";
      };

      nativeBuildInputs = [ pkgs.unzip ];

      dontStrip = true;
      dontPatchELF = true;

      installPhase = let
        gl_rpath = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];
        rpath = pkgs.lib.makeLibraryPath [
          pkgs.glib
          pkgs.nss
          pkgs.nspr
          pkgs.atk
          pkgs.at-spi2-atk
          pkgs.libdrm
          pkgs.expat
          pkgs.libxkbcommon
          pkgs.libgbm
          pkgs.gtk3
          pkgs.pango
          pkgs.cairo
          pkgs.alsa-lib
          pkgs.dbus
          pkgs.at-spi2-core
          pkgs.cups
          pkgs.libGL
          pkgs.udev
          pkgs.systemdLibs
          pkgs.libxcb
          pkgs.libx11
          pkgs.libxcomposite
          pkgs.libxdamage
          pkgs.libxext
          pkgs.libxfixes
          pkgs.libxrandr
          pkgs.libxshmfence
        ];
      in ''
        runHook preInstall

        sed 's/-O0/-O2/' -i cmake/cef_variables.cmake

        mkdir -p $out
        cp -a include libcef_dll cmake CMakeLists.txt $out/
        cp -a Release/* $out/
        cp -a Resources/* $out/
        chmod +x $out/chrome-sandbox || true

        echo '{"type":"minimal","name":"cef_binary_148.0.8+g18e00ea+chromium-148.0.7778.96_linux64_minimal.tar.bz2","sha1":"0000000000000000000000000000000000000000"}' > $out/archive.json

        patchelf --set-rpath "${rpath}" --set-interpreter "${pkgs.stdenv.cc.bintools.dynamicLinker}" $out/chrome-sandbox
        patchelf --add-needed libudev.so --set-rpath "${rpath}" $out/libcef.so
        patchelf --set-rpath "${gl_rpath}" $out/libEGL.so
        patchelf --add-needed libGL.so.1 --set-rpath "${gl_rpath}" $out/libGLESv2.so
        patchelf --set-rpath "${gl_rpath}" $out/libvk_swiftshader.so
        patchelf --set-rpath "${gl_rpath}" $out/libvulkan.so.1 || true

        runHook postInstall
      '';
    };

    karerePackage = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "karere";
      version = "4.0.6";

      src = pkgs.fetchFromGitHub {
        owner = "tobagin";
        repo = "karere";
        rev = "ada3bea987dab134da8ac3395f25a7368cf035d1";
        sha256 = "1six2pwjzyjxx1gapdbnqwwzyb3piqps38r6864rfvr5qdhzs1nn";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        src = finalAttrs.src;
        hash = "sha256-BWmDUO8D0wrQNOUGsIOwdHAwltBobqFQrDsWobRBfcQ=";
      };

      nativeBuildInputs = [
        pkgs.cargo
        pkgs.meson
        pkgs.ninja
        pkgs.pkg-config
        pkgs.rustPlatform.cargoSetupHook
        pkgs.rustc
        pkgs.wrapGAppsHook4
        pkgs.blueprint-compiler
        pkgs.desktop-file-utils
      ];

      buildInputs = [
        pkgs.libadwaita
        pkgs.glib-networking
        pkgs.libepoxy
      ]
      ++ (with pkgs.gst_all_1; [
        gstreamer
        gst-plugins-base
        gst-plugins-good
        gst-plugins-bad
        gst-libav
      ]);

      CEF_PATH = "${cef-binary-karere}";

      postPatch = ''
        substituteInPlace src/handlers/load.rs \
          --replace 'crate::web_view::apply_notif_sound_from_settings(browser);' 'crate::web_view::apply_notif_sound_from_settings(browser);

                  let custom_css_path = gtk::glib::user_config_dir().join("karere").join("custom.css");
                  if custom_css_path.exists() {
                      if let Ok(css_content) = std::fs::read_to_string(&custom_css_path) {
                          let js = format!(
                              "(function() {{
                                  let style = document.getElementById(\"karere-custom-css\");
                                  if (!style) {{
                                      style = document.createElement(\"style\");
                                      style.id = \"karere-custom-css\";
                                      document.head.appendChild(style);
                                  }}
                                  style.textContent = {};
                              }})();",
                              serde_json::to_string(&css_content).unwrap_or_default()
                          );
                          let code = cef::CefString::from(js.as_str());
                          if let Some(frame) = browser.main_frame() {
                              frame.execute_java_script(
                                  Some(&code),
                                  Some(&cef::CefString::from("karere://custom-css")),
                                  0,
                              );
                          }
                      }
                  }'
      '';

      preFixup = ''
        gappsWrapperArgs+=(
          --set FLATPAK_ID io.github.tobagin.karere
        )
      '';

      postInstall = ''
        ln -s ${cef-binary-karere}/*.pak $out/bin/
        ln -s ${cef-binary-karere}/*.dat $out/bin/
        ln -s ${cef-binary-karere}/locales $out/bin/
      '';
    });
  in {
    hm = {
      home.packages = [
        karerePackage
      ];

      home.file.".config/karere/custom.css".text = with config.lib.stylix.colors.withHashtag; ''
        :root, .dark, .color-refresh, .app-wrapper-web {
          --WDS-accent: ${base0D} !important;
          --WDS-accent-rgb: ${rgb0D} !important;
          --WDS-accent-RGB: ${rgb0D} !important;
          --WDS-accent-emphasized: ${base0D} !important;

          --WDS-content-default: ${base05} !important;
          --WDS-content-default-rgb: ${rgb05} !important;
          --WDS-content-deemphasized: ${base04} !important;
          --WDS-content-disabled: ${base03} !important;
          --WDS-content-on-accent: ${base00} !important;
          --WDS-content-action-default: ${base0D} !important;
          --WDS-content-action-emphasized: ${base0D} !important;
          --WDS-content-external-link: ${base0C} !important;
          --WDS-content-inverse: ${base07} !important;
          --WDS-content-read: ${base0D} !important;

          --WDS-background-wash-inset: ${base00} !important;
          --WDS-background-wash-plain: ${base00} !important;
          --WDS-background-elevated-wash-plain: ${base00} !important;
          --WDS-background-elevated-wash-inset: ${base00} !important;
          --WDS-modal-backdrop-solid: ${base00} !important;

          --WDS-surface-default: ${base00} !important;
          --WDS-surface-emphasized: ${base01} !important;
          --WDS-surface-elevated-default: ${base01} !important;
          --WDS-surface-elevated-emphasized: ${base01} !important;
          --WDS-surface-highlight: ${base02} !important;
          --WDS-surface-inverse: ${base05} !important;
          --WDS-surface-pressed: ${base02} !important;

          --WDS-lines-divider: ${base02} !important;
          --WDS-lines-outline-default: ${base02} !important;
          --WDS-lines-outline-deemphasized: ${base02} !important;

          --WDS-systems-bubble-surface-incoming: ${base01} !important;
          --WDS-systems-bubble-surface-outgoing: ${base02} !important;
          --WDS-systems-bubble-content-deemphasized: ${base03} !important;
          --WDS-systems-bubble-surface-overlay: ${base00} !important;
          --WDS-systems-bubble-surface-system: ${base00} !important;

          --WDS-systems-chat-surface-composer: ${base01} !important;
          --WDS-systems-chat-background-wallpaper: ${base00} !important;
          --WDS-systems-chat-foreground-wallpaper: ${base00} !important;
          --WDS-systems-chat-surface-tray: ${base00} !important;
          --WDS-systems-status-seen: ${base03} !important;

          --WDS-components-surface-nav-bar: ${base00} !important;
          --WDS-app-wash: ${base00} !important;

          --WDS-secondary-negative: ${base08} !important;
          --WDS-secondary-positive: ${base0B} !important;
          --WDS-secondary-warning: ${base0A} !important;

          --app-background: ${base00} !important;
          --app-background-rgb: ${rgb00} !important;
          --background-default: ${base00} !important;
          --background-default-rgb: ${rgb00} !important;
          --panel-background: ${base00} !important;
          --panel-background-rgb: ${rgb00} !important;
          --panel-background-colored: ${base01} !important;
          --panel-header-background: ${base01} !important;
          --dropdown-background: ${base01} !important;
          --dropdown-background-rgb: ${rgb01} !important;
          --message-primary: ${base05} !important;
          --primary: ${base05} !important;
          --secondary: ${base04} !important;
          --incoming-chat-bubble: ${base01} !important;
          --outgoing-chat-bubble: ${base02} !important;
          --system-message-background: ${base01} !important;
          --compose-input-background: ${base01} !important;
          --search-input-background: ${base01} !important;
          --active-tab-marker: ${base0D} !important;
          --accent: ${base0D} !important;
          --button-primary: ${base0D} !important;
        }

        body {
          background-color: ${base00} !important;
          color: ${base05} !important;
        }
      '';
    };
  };
}
