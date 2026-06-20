{ ... }: {
  flake.modules.nixos.cli_tmux = { pkgs, username, config, ... }: {
    hm = {
      stylix.targets.tmux.enable = false;

      programs.tmux = {
        enable = true;
        mouse = true;
        shortcut = "a";
        baseIndex = 1;
        keyMode = "vi";
        customPaneNavigationAndResize = true;
        escapeTime = 10;
        historyLimit = 10000;
        terminal = "tmux-256color";

        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim 'session'
              set -g @resurrect-strategy-vim 'session'
              set -g @resurrect-capture-pane-contents 'on'
              set -g @resurrect-dir '/home/${username}/.local/share/tmux/resurrect'
            '';
          }
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '10'
            '';
          }
        ];

        extraConfig = with config.lib.stylix.colors.withHashtag; ''
          # Split panes using | and - (and open in current directory)
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # Switch panes using Vim-like keys
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          # Don't rename windows automatically
          set-option -g allow-rename off

          # Enable alternate screen for full-screen programs
          set-window-option -g alternate-screen on

          # Allow graphics escape sequences to pass through tmux
          set -g allow-passthrough on
          set -g visual-activity off
          set -g focus-events on

          # True color support and terminal overrides
          set -g default-terminal "tmux-256color"
          set -as terminal-features ",xterm-kitty:RGB"
          set -as terminal-features ",xterm-kitty:usstyle"
          set -as terminal-features ",xterm-kitty:clipboard"
          set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'

          # Update environment variables so Yazi can detect the underlying Kitty terminal
          set -g update-environment "DISPLAY WAYLAND_DISPLAY SWAYSOCK HYPRLAND_INSTANCE_SIGNATURE XDG_RUNTIME_DIR TERM TERM_PROGRAM"

          # --- Premium Floating-Pill Status Line ---
          set -g status-position bottom
          set -g status-justify left
          set -g status-style "bg=default,fg=${base05}"

          # Left status: Session name in a floating pill
          set -g status-left-length 50
          set -g status-left "#[fg=${base0D},bg=default]#[fg=${base00},bg=${base0D},bold]󰄀 #S#[fg=${base0D},bg=default,nobold] "

          # Right status: Path, Date/Time, and Host in beautiful floating pills
          set -g status-right-length 150
          set -g status-right "#[fg=${base01},bg=default]#[fg=${base05},bg=${base01}]󰉋 #{=50:pane_current_path}#[fg=${base01},bg=default] #[fg=${base03},bg=default]#[fg=${base05},bg=${base03}]󰃭 %Y-%m-%d #[fg=${base0C},bg=${base03}]#[fg=${base00},bg=${base0C},bold]󰍹 #h#[fg=${base0C},bg=default,nobold]"

          # Window status formatting (tabs styled as floating pills)
          set -g window-status-separator " "
          set -g window-status-format "#[fg=${base03},bg=default]#[fg=${base04},bg=${base03}]#I: #W#[fg=${base03},bg=default]"
          set -g window-status-current-format "#[fg=${base0D},bg=default]#[fg=${base00},bg=${base0D},bold]#I: #W#[fg=${base0D},bg=default,nobold]"

          # Pane borders
          set -g pane-border-style "fg=${base01}"
          set -g pane-active-border-style "fg=${base0D}"

          # Style the command prompt and popups
          set -g message-style "bg=${base01},fg=${base05}"
          set -g message-command-style "bg=${base01},fg=${base05}"
        '';
      };
    };
  };
}
