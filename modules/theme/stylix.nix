{ inputs, ... }: {
  flake.modules.nixos.theme_stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      image = ./nord-wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      polarity = "dark";
    };
  };
}
