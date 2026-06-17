{ ... }: {
  flake.modules.nixos.core_base = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

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
