{ inputs, ... }: {
  flake.modules.nixos.app_onlyoffice = { pkgs, config, ... }: {
    hm = { lib, ... }:
      {
        programs.onlyoffice = {
          enable = true;
          settings = {
            UITheme="/home/iskaa303/.local/share/onlyoffice/desktopeditors/uithemes/theme-stylix.json";
            editorWindowMode = false;
            forcedRtl = false;
            maximized = true;
            titlebar = "custom";
          };
        };

        home.file.".local/share/onlyoffice/desktopeditors/uithemes/theme-stylix.json".text = builtins.toJSON {
          name = "Stylix";
          l10n = {
            en = "Stylix";
          };
          id = "stylix";
          type = config.stylix.polarity;
          colors = {
            "background-normal" = "#${config.lib.stylix.colors.base00}";
            "background-toolbar" = "#${config.lib.stylix.colors.base01}";
            "background-toolbar-additional" = "#${config.lib.stylix.colors.base02}";
            "background-accent-button" = "#${config.lib.stylix.colors.base0D}";
            "background-primary-dialog-button" = "#${config.lib.stylix.colors.base0D}";
            "background-tab-underline" = "#${config.lib.stylix.colors.base0D}";
            
            "highlight-button-hover" = "#${config.lib.stylix.colors.base02}";
            "highlight-button-pressed" = "#${config.lib.stylix.colors.base03}";
            "highlight-accent-button-hover" = "#${config.lib.stylix.colors.base0C}";
            "highlight-primary-dialog-button-hover" = "#${config.lib.stylix.colors.base0C}";
            "highlight-toolbar-tab-underline" = "#${config.lib.stylix.colors.base0D}";
            "highlight-text-select" = "#${config.lib.stylix.colors.base02}";
            
            "border-toolbar" = "#${config.lib.stylix.colors.base02}";
            "border-divider" = "#${config.lib.stylix.colors.base02}";
            "border-regular-control" = "#${config.lib.stylix.colors.base03}";
            "border-control-focus" = "#${config.lib.stylix.colors.base0D}";
            "border-error" = "#${config.lib.stylix.colors.base08}";
            
            "text-normal" = "#${config.lib.stylix.colors.base05}";
            "text-secondary" = "#${config.lib.stylix.colors.base04}";
            "text-tertiary" = "#${config.lib.stylix.colors.base03}";
            "text-link" = "#${config.lib.stylix.colors.base0C}";
            "text-link-hover" = "#${config.lib.stylix.colors.base0D}";
            "text-inverse" = "#${config.lib.stylix.colors.base00}";
            "text-toolbar-header" = "#${config.lib.stylix.colors.base05}";
            
            "icon-normal" = "#${config.lib.stylix.colors.base05}";
            "icon-inverse" = "#${config.lib.stylix.colors.base00}";
            "icon-toolbar-header" = "#${config.lib.stylix.colors.base05}";
            "icon-success" = "#${config.lib.stylix.colors.base0B}";
            
            "toolbar-header-document" = "#${config.lib.stylix.colors.base0D}";
            "toolbar-header-spreadsheet" = "#${config.lib.stylix.colors.base0B}";
            "toolbar-header-presentation" = "#${config.lib.stylix.colors.base09}";
            "toolbar-header-pdf" = "#${config.lib.stylix.colors.base08}";
            
            "text-toolbar-header-on-background-document" = "#${config.lib.stylix.colors.base05}";
            "text-toolbar-header-on-background-spreadsheet" = "#${config.lib.stylix.colors.base05}";
            "text-toolbar-header-on-background-presentation" = "#${config.lib.stylix.colors.base05}";
            "text-toolbar-header-on-background-pdf" = "#${config.lib.stylix.colors.base05}";
            
            "canvas-background" = "#${config.lib.stylix.colors.base01}";
            "canvas-content-background" = "#${config.lib.stylix.colors.base00}";
            "canvas-page-border" = "#${config.lib.stylix.colors.base02}";
          };
          values = {
            "brand-word" = "#${config.lib.stylix.colors.base0D}";
            "brand-slide" = "#${config.lib.stylix.colors.base09}";
            "brand-cell" = "#${config.lib.stylix.colors.base0B}";
            "brand-pdf" = "#${config.lib.stylix.colors.base08}";
            "brand-draw" = "#${config.lib.stylix.colors.base0E}";

            "window-background" = "#${config.lib.stylix.colors.base00}";
            "window-border" = "#${config.lib.stylix.colors.base02}";

            "border-control-focus" = "#${config.lib.stylix.colors.base0D}";

            "text-normal" = "#${config.lib.stylix.colors.base05}";
            "text-pretty" = "#${config.lib.stylix.colors.base05}";
            "text-inverse" = "#${config.lib.stylix.colors.base00}";

            "tool-button-background" = "#${config.lib.stylix.colors.base01}";
            "tool-button-hover-background" = "#${config.lib.stylix.colors.base02}";
            "tool-button-pressed-background" = "#${config.lib.stylix.colors.base03}";
            "tool-button-active-background" = "#${config.lib.stylix.colors.base02}";

            "download-widget-background" = "#${config.lib.stylix.colors.base01}";
            "download-widget-border" = "#${config.lib.stylix.colors.base02}";
            "download-item-hover-background" = "#${config.lib.stylix.colors.base02}";

            "download-ghost-button-text" = "#${config.lib.stylix.colors.base0D}";
            "download-ghost-button-text-hover" = "#${config.lib.stylix.colors.base05}";
            "download-ghost-button-text-pressed" = "#${config.lib.stylix.colors.base03}";
            "download-ghost-button-text-pressed-item-hover" = "#${config.lib.stylix.colors.base04}";

            "download-label-text" = "#${config.lib.stylix.colors.base05}";
            "download-label-text-info" = "#${config.lib.stylix.colors.base04}";
            "download-label-text-info-item-hover" = "#${config.lib.stylix.colors.base05}";

            "download-progressbar-chunk" = "#${config.lib.stylix.colors.base0D}";
            "download-progressbar-background" = "#${config.lib.stylix.colors.base02}";
            "download-progressbar-background-item-hover" = "#${config.lib.stylix.colors.base03}";

            "download-scrollbar-handle" = "#${config.lib.stylix.colors.base03}";

            "menu-background" = "#${config.lib.stylix.colors.base01}";
            "menu-border" = "#${config.lib.stylix.colors.base02}";
            "menu-item-hover-background" = "#${config.lib.stylix.colors.base02}";

            "menu-text" = "#${config.lib.stylix.colors.base05}";
            "menu-text-item-hover" = "#${config.lib.stylix.colors.base05}";
            "menu-text-item-disabled" = "#${config.lib.stylix.colors.base03}";

            "menu-separator" = "#${config.lib.stylix.colors.base02}";

            "tooltip-text" = "#${config.lib.stylix.colors.base05}";
            "tooltip-border" = "#${config.lib.stylix.colors.base02}";
            "tooltip-background" = "#${config.lib.stylix.colors.base01}";

            "tab-active-background" = "#${config.lib.stylix.colors.base01}";
            "tab-simple-active-background" = "#${config.lib.stylix.colors.base01}";
            "tab-simple-active-text" = "#${config.lib.stylix.colors.base05}";
            "tab-default-active-background" = "#${config.lib.stylix.colors.base01}";
            "tab-default-active-text" = "#${config.lib.stylix.colors.base05}";
            "tab-divider" = "#${config.lib.stylix.colors.base02}";

            "button-normal-opacity" = "rgba(255,255,255,200)";
            "logo-type" = "light";
          };
        };

        xdg.configFile."onlyoffice/DesktopEditors.conf".force = true;
      };
  };
}
