{ ... }: {
  flake.modules.nixos.cli_pi = { inputs, ... }: {
    # pkgs.pi / pkgs.pi-coding-agent come from here: pi_setup_303 pins the pi
    # version itself, so pi-flake is not needed in this config.
    nixpkgs.overlays = [ inputs.pi-setup.overlays.default ];

    hm = {
      disabledModules = [ "programs/pi-coding-agent.nix" ];

      # One module: pi, its nix-owned settings.json, and every extension.
      imports = [ inputs.pi-setup.homeManagerModules.default ];

      programs.pi-setup = {
        enable = true;
        camoufox = true;

        settings = {
          defaultModel = "stealth/space-bunny-alpha";
          defaultProvider = "openrouter";
          defaultThinkingLevel = "high";
          theme = "dark";
          shellPath = "/run/current-system/sw/bin/nu";
          # `packages` is filled in by the module with the nix extension paths;
          # add npm:/git: sources here if you ever want one.
          packages = [ ];
        };
      };

      # pi-statusline config. Remove this file (and the extension) to fall back
      # to pi's own footer, which is clean but has no extension status row.
      # No extensionStatusIcons mapping on purpose: extensions already put their
      # own indicator first (ponytail renders "○ 🐴 ponytail: ⚡ FULL"), and
      # pi-statusline splits that leading glyph off as the icon.
      home.file.".pi/agent/pi-statusline.json".text = builtins.toJSON {
        palettePreset = "tokyo-night";
        density = "compact";
        separator = "round";
        segments = [ "model" "thinking" "cwd" "branch" "context" "cost" "time" ];
      };
    };
  };
}
