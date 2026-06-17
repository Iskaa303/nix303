{ ... }: {
  flake.modules.nixos.core_desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ghostty
      foot
    ];
  };
}
