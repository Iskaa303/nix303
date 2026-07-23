{ ... }: {
  flake.modules.nixos.cli_kari = { pkgs, ... }: {
    hm.home.packages = [
      (pkgs.buildGoModule {
        pname = "kari";
        version = "unstable-2025-07-20";
        src = pkgs.fetchFromGitHub {
          owner = "Dhairya3391";
          repo = "kari";
          rev = "d4fff5e53542ef5d20a7fe284a5bc2a215fa115d";
          hash = "sha256-sHextf0ENVWBfHuWNP5cAkBDGE7CvHA5HmKdOSzLxZs=";
        };
        prePatch = ''
          sed -i 's/go 1.26.4/go 1.26.3/' go.mod
        ''; # ponytail: drop when nixpkgs ships go >= 1.26.4
        vendorHash = "sha256-a//13YOUpG3+IMT8X6Lt4z0ceMOJe9D/Mad4QnnN6Ts=";
        subPackages = [ "./cmd/kari" ];
      })
    ];
  };
}
