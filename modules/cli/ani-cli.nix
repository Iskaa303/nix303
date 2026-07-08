{ ... }: {
  flake.modules.nixos.cli_anime = { pkgs, lib, ... }: {
    hm.home.packages = [
      (pkgs.ani-cli.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "pystardust";
          repo = "ani-cli";
          rev = "master";
          hash = "sha256-D7pWbjmhCLAbtoUBV4KtqbjusvjFd0mLCgFh+Pjp5SY=";
        };
      }))
      (pkgs.ani-skip.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "synacktraa";
          repo = "ani-skip";
          rev = "master";
          hash = lib.fakeHash;
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
