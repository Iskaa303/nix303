{ inputs, ... }: {
  flake.modules.nixos.cli_pi = { pkgs, inputs, username, ... }: {
    nixpkgs.overlays = [ inputs.pi-flake.overlays.default ];

    hm = {
      disabledModules = [ "programs/pi-coding-agent.nix" ];
      imports = [ inputs.pi-flake.homeManagerModules.default ];

      programs.pi-coding-agent = {
        enable = true;
        mutableDir = true;
        extraEnv = {
          PATH = "${pkgs.lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.nodejs pkgs.git pkgs.bun pkgs.fd pkgs.ripgrep pkgs.gnutar ]}:$PATH";
        };
        models = {
          providers = {};
        };
        extensions = [
          "npm:pi-hashline-edit-pro"
          "git:github.com/DietrichGebert/ponytail"
          "npm:@narumitw/pi-wait-what"
          "npm:@narumitw/pi-statusline"
          "npm:pi-shazam"
        ];
      };

      home.file.".pi/agent/trust.json".text = builtins.toJSON {
        "/home/${username}" = true;
      };
    };
  };
}
