{
  flake.modules.nixos.feature_niri = {
    hm.programs.niri.settings.binds = {
      "Mod+Return".action.spawn = "ghostty";
      "Mod+T".action.spawn = "foot";
      "Mod+Q".action.close-window = {};
    };
  };
}
