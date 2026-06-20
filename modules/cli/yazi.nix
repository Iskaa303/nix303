{ ... }: {
  flake.modules.nixos.cli_yazi = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.ripdrag
      pkgs.ouch
      pkgs.ripgrep
    ];
    
    hm.programs.yazi = {
      enable = true;
      enableNushellIntegration = true;

      plugins = {
        drag = pkgs.yaziPlugins.drag;
        starship = pkgs.yaziPlugins.starship;
        ouch = pkgs.yaziPlugins.ouch;
      };

      initLua = ''
        require("starship"):setup()
      '';

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = [ "<C-q>" ];
              run = "plugin drag";
              desc = "Drag files";
            }
            {
              on = [ "C" ];
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
          ];
        };
      };

      settings = {
        manager = {
          ratio = [ 1 4 3 ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "none";
          show_hidden = true;
          show_symlink = true;
        };
        plugin = {
          prepend_previewers = [
            {
              mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
              run = "ouch";
            }
          ];
        };
        opener = {
          edit = [
            { run = ''hx "$@"''; block = true; desc = "Helix"; }
          ];
        };
        open = {
          prepend_rules = [
            { mime = "text/*"; use = "edit"; }
            { url = "*"; use = "edit"; }
          ];
        };
      };
    };
  };
}
