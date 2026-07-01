{ ... }: {
  flake.modules.nixos.cli_anime = { pkgs, lib, ... }: {
    hm.home.packages = [
      (pkgs.ani-cli.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "pystardust";
          repo = "ani-cli";
          rev = "master";
          hash = "sha256-+fR46bWXJ58LkXFvWAO/LyCd5THi7oMcqmhRoCKBZfM=";
        };
      }))
    ];
  };
}
