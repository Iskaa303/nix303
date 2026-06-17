{ ... }: {
  flake.modules.nixos.core_base = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      curl
      bash
      git
      nano
      neovim
      gh
      fastfetch
    ];
  };
}
