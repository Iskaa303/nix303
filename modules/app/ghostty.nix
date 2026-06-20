{ ... }: {
  flake.modules.nixos.app_ghostty = {
    hm.programs.ghostty = {
      enable = true;
      settings = {
        command = "tmux new-session -A -s main";
      };
    };
  };
}
