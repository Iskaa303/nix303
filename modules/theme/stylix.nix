{ inputs, ... }: {
  flake.modules.nixos.theme_stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    hm.home.pointerCursor.enable = true;

    # shortcut: rofi is unused, and upstream stylix still sets the removed programs.rofi.font
    # option, which home-manager warns about. Re-enable once stylix renames it.
    hm.stylix.targets.rofi.enable = false;

    stylix = {
      enable = true;
      image = ../../assets/wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      polarity = "dark";

      targets.qt = {
        enable = true;
        platform = "qtct";
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.lexend;
          name = "Lexend";
        };
        serif = {
          package = pkgs.lexend;
          name = "Lexend";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 11;
          terminal = 13;
          desktop = 11;
          popups = 11;
        };
      };
    };
  };
}
