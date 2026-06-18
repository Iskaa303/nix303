{ inputs, ... }: {
  flake.modules.nixos.app_nixcord = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
          postFixup = (oldAttrs.postFixup or "") + ''
            wrapProgram $out/bin/vesktop \
              --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer" \
              --add-flags "--ozone-platform=wayland"
          '';
        });
      })
    ];

    hm = {
      imports = [ inputs.nixcord.homeModules.nixcord ];
      programs.nixcord = {
        enable = true;
        vesktop = {
          enable = true;
        };
      };
    };
  };
}
