{ inputs, ... }: {
  flake.modules.nixos.app_onlyoffice = { pkgs, ... }: {
    hm = { lib, ... }:
      {
        programs.onlyoffice = {
          enable = true;
          settings = {
            UITheme = "theme-dark";
            editorWindowMode = false;
            forcedRtl = false;
            maximized = true;
            titlebar = "custom";
          };
        };

        xdg.configFile."onlyoffice/DesktopEditors.conf".force = true;
      };
  };
}
