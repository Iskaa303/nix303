{
  flake.modules.nixos.desktop_niri = {
    hm.programs.niri.settings.binds = {
      # Apps Manipulation
      "Mod+Return".action.spawn = "ghostty";
      "Mod+T".action.spawn = "foot";
      "Mod+B".action.spawn = "firefox";
      "Mod+D".action.spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ];
      "Mod+E".action.spawn = [ "noctalia" "msg" "panel-toggle" "session" ];
      "Mod+Q".action.close-window = {};

      # Navigation
      "Mod+Left".action.focus-column-left = {};
      "Mod+Right".action.focus-column-right = {};
      "Mod+Down".action.focus-window-down = {};
      "Mod+Up".action.focus-window-up = {};

      # Window Global Position
      "Mod+Shift+Left".action.move-column-left = {};
      "Mod+Shift+Right".action.move-column-right = {};
      "Mod+Shift+Down".action.move-window-down = {};
      "Mod+Shift+Up".action.move-window-up = {};

      # Window Size
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+F".action.maximize-column = {};
      "Mod+Shift+F".action.fullscreen-window = {};
      "Mod+R".action.switch-preset-column-width = {};
      "Mod+Shift+R".action.switch-preset-window-height = {};
      "Mod+Ctrl+R".action.reset-window-height = {};

      # Workspace Navigation
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      # Window Workspace Position
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;

      # Screenshot bindings
      "Print".action.spawn = [ "flameshot" "full" "--clipboard" ];
      "Ctrl+Print".action.spawn = [ "flameshot" "gui" ];
    };
  };
}
