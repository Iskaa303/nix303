{ ... }: {
  flake.modules.nixos.cli_pi = { inputs, ... }: {
    # pkgs.pi / pkgs.pi-coding-agent come from here: pi_setup_303 pins the pi
    # version itself, so pi-flake is not needed in this config.
    nixpkgs.overlays = [ inputs.pi-setup.overlays.default ];

    hm = {
      disabledModules = [ "programs/pi-coding-agent.nix" ];

      # One module: pi, its nix-owned settings.json, every extension, the
      # always-on AGENTS.md, the loop agents and the virtual display tools.
      imports = [ inputs.pi-setup.homeManagerModules.default ];

      programs.pi-setup = {
        enable = true;
        # real-Firefox fetch engine (the module cannot know you want it)
        camoufox = true;

        # `packages`, `subagents.defaultSubagentOnlyExtensions` and the
        # researcher/evidence-auditor overrides are written by the module, and
        # subagents inherit the models below. Only what differs goes here.
        settings = {
          # OpenCode Go: unprefixed model ids, one account.
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4.1-flash";
          defaultThinkingLevel = "high";
          # $SHELL is already nu, but pi's own default is /bin/sh on Linux and a
          # shell swap must not be silent.
          shellPath = "/run/current-system/sw/bin/nu";
          theme = "dark";
        };

        # `settings.subagents` would be overwritten by the module (it fills in
        # the extension wiring), so subagent settings belong here.
        subagents = {
          # Children start cheaper than the parent and escalate by agent
          # frontmatter (planner pins deepseek-v4-pro).
          defaultThinking = "medium";
        };
      };

      # pi-statusline. No `time` segment: it is a wall clock; the session-cost
      # extension shows session duration plus the combined parent + subagent
      # cost. No extensionStatusIcons mapping: extensions already put their own
      # indicator first and pi-statusline splits the leading glyph off as the
      # icon.
      home.file.".pi/agent/pi-statusline.json".text = builtins.toJSON {
        palettePreset = "tokyo-night";
        density = "compact";
        separator = "round";
        segments = [ "model" "thinking" "cwd" "branch" "tools" "context" "cost" ];
      };
    };
  };
}
