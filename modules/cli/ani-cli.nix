{ ... }: {
  flake.modules.nixos.cli_anime = { pkgs, ... }: {
    hm.home.packages = [
      (pkgs.ani-cli.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "pystardust";
          repo = "ani-cli";
          rev = "89ec9314eba7b66c894bf8bbf3b2b25a3b80743a";
          hash = "sha256-wU25uSikLbuzQ/nAZzWz3ilpM1Ewac4ZuICRCwUn/fQ=";
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
