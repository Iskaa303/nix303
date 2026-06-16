{ ... }: {
  flake.modules.nixos.feature_desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      firefox
      ghostty
    ];
  };
}
