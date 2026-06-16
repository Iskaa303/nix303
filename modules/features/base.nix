{ ... }: {
  flake.modules.nixos.feature_base = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      curl
      bash
      git
      nano
      neovim
    ];
  };
}
