{ ... }: {
  flake.modules.nixos.core_base = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      curl
      bash
      nano
      gh
      fastfetch
    ];

    programs.nix-ld = {
      enable = true;
      libraries = [];
    };
  };
}
