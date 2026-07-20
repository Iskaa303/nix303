{ ... }: {
  flake.modules.nixos.cli_anime = { pkgs, ... }: {
    hm.home.packages = [
      pkgs.botan3
      (pkgs.ani-cli.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "pystardust";
          repo = "ani-cli";
          rev = "4c5a72e319964ef343e517b44822683db4487e1a";
          hash = "sha256-sB2hUNFZP3cyg1jQpKiCwxjSz7n4Ii9qG3lhB65LAS8=";
        };
      }))
      (pkgs.ani-skip.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "synacktraa";
          repo = "ani-skip";
          rev = "6890bbfcc3f1dc785cfca9fede10cc9152f03161";
          hash = "sha256-D7pWbjmhCLAbtoUBV4KtqbjusvjFd0mLCgFh+Pjp5SY=";
        };
        installPhase = ''
          runHook preInstall
          install -D integrations/mpv.lua $out/share/mpv/scripts/skip.lua
          install -Dm 755 ani-skip $out/bin/ani-skip
          runHook postInstall
        '';
      }))
    ];
  };
}
