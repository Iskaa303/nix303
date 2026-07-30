{
  flake.modules.nixos.app_obs_studio = { pkgs, ... }: {
    hm = { config, ... }: {
      home.packages = [ pkgs.obs-studio ];

      xdg.configFile = {
        "obs-studio/global.ini".text = ''
          [General]
          CurrentProfile=Default
        '';
        "obs-studio/basic/profiles/Default/basic.ini".text = ''
          [SimpleOutput]
          FilePath=${config.home.homeDirectory}/Videos/Recordings

          [AdvOut]
          RecFilePath=${config.home.homeDirectory}/Videos/Recordings
        '';
      };
    };
  };
}
