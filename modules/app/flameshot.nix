{ ... }: {
  flake.modules.nixos.app_flameshot = { config, pkgs, ... }: {
    hm = {
      services.flameshot = {
        enable = true;
        settings = {
          General = with config.lib.stylix.colors.withHashtag; {
            uiColor = base0D;
            contrastUiColor = base00;
            drawColor = base08;
            userColors = "picker, ${base08}, ${base09}, ${base0A}, ${base0B}, ${base0C}, ${base0D}, ${base0E}, ${base0F}";
            
            showStartupLaunchMessage = false;
            saveLastRegion = true;

            useGrimAdapter = true;
            disabledGrimWarning = true;
          };
        };
      };

      home.packages = [
        pkgs.grim
      ];
    };
  };
}
