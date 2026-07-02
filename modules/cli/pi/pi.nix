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
          PATH = "${pkgs.lib.makeBinPath [
            pkgs.bash pkgs.coreutils pkgs.nodejs pkgs.git pkgs.bun
            pkgs.fd pkgs.ripgrep pkgs.gnutar
            pkgs.gnugrep pkgs.gnused pkgs.findutils pkgs.gawk
            pkgs.vscode-json-languageserver pkgs.typescript-language-server pkgs.rust-analyzer
            pkgs.gopls pkgs.yaml-language-server pkgs.pyright
          ]}:$PATH";
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

      # Symlink LSP binaries into ~/.local/bin/ — pi-shazam's trustedUserCandidates
      # checks this path as its first user-candidate location.
      home.file.".local/bin/vscode-json-language-server".source = "${pkgs.vscode-json-languageserver}/bin/vscode-json-language-server";
      home.file.".local/bin/typescript-language-server".source = "${pkgs.typescript-language-server}/bin/typescript-language-server";
      home.file.".local/bin/rust-analyzer".source = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      home.file.".local/bin/gopls".source = "${pkgs.gopls}/bin/gopls";
      home.file.".local/bin/yaml-language-server".source = "${pkgs.yaml-language-server}/bin/yaml-language-server";
      home.file.".local/bin/pyright-langserver".source = "${pkgs.pyright}/bin/pyright-langserver";

      # Load skills from the .md files in this directory
      home.file.".pi/agent/skills/nixos-env/SKILL.md".source = ./nixos-env.md;
      home.file.".pi/agent/skills/hashline-edit/SKILL.md".source = ./hashline-edit.md;

      home.file.".pi/agent/trust.json".text = builtins.toJSON {
        "/home/${username}" = true;
      };
    };
  };
}
