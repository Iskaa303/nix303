{ ... }: {
  flake.modules.nixos.core_base = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "iskaa303" ];
    };

    environment.systemPackages = with pkgs; [
      curl
      bash
      nano
      gh
    ];

    programs.nix-ld = {
      enable = true;
      libraries = [];
    };
  };
}
