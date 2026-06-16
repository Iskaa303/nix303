{
  flake.modules.nixos.feature_niri = {
    hm.programs.niri.settings.binds = {
      "Mod+Return".action.spawn = "ghostty";
      "Mod+Q".action.close-window = {};
    };
  };
}
