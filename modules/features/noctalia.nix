{ ... }: {
  flake.modules.nixos.feature_noctalia = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      noctalia
    ];
  };
}
