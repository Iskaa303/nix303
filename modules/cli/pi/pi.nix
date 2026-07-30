{ ... }: {
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
          ]}:$HOME/.local/bin:$PATH";
        };
        models = {
          providers = {};
        };
        extensions = [
          "git:github.com/DietrichGebert/ponytail"
          "npm:@narumitw/pi-wait-what"
          "npm:@narumitw/pi-statusline"
          "npm:pi-shazam"
          "npm:pi-notify"
        ];
      };

      # Symlink LSP binaries into ~/.local/bin/ — pi-shazam's trustedUserCandidates
      # checks this path as its first user-candidate location.
      # pi-statusline config: add cost to the status line
      home.file.".pi/agent/pi-statusline.json".text = builtins.toJSON {
        segments = ["model" "thinking" "cwd" "branch" "tools" "context" "cost" "time"];
      };

      home.file.".local/bin/vscode-json-language-server".source = "${pkgs.vscode-json-languageserver}/bin/vscode-json-language-server";
      home.file.".local/bin/typescript-language-server".source = "${pkgs.typescript-language-server}/bin/typescript-language-server";
      home.file.".local/bin/rust-analyzer".source = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      home.file.".local/bin/gopls".source = "${pkgs.gopls}/bin/gopls";
      home.file.".local/bin/yaml-language-server".source = "${pkgs.yaml-language-server}/bin/yaml-language-server";
      home.file.".local/bin/pyright-langserver".source = "${pkgs.pyright}/bin/pyright-langserver";

      # Disable pi-flake's broken node.js symlink (flat nix-store file;
      # relative require fails). We create a real file via activation instead.
      home.file.".pi/agent/npm/node_modules/vscode-jsonrpc/node.js".enable = false;

      # vscode-jsonrpc compat shim + pi-shazam NixOS patches.
      # Runs at every HM activation, idempotent.
      home.file.".pi/agent/lib/shazam-compat.sh".source = ./pi-shazam-compat.sh;

      home.activation.shazamCompat = ''
        bash "$HOME/.pi/agent/lib/shazam-compat.sh"
      '';

      # Load skills from the .md files in this directory
      home.file.".pi/agent/skills/nixos-env/SKILL.md".source = ./nixos-env.md;

      # Web search extension (ketch-backed)
      home.file.".pi/agent/extensions/web-search/index.ts".source = ./web-search.ts;

      # Nushell syntax extension
      home.file.".pi/agent/extensions/nushell/index.ts".source = ./nushell.ts;

      home.file.".pi/agent/trust.json".text = builtins.toJSON {
        "/home/${username}" = true;
      };
    };
  };
}
