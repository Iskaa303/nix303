{ ... }: {
  flake.modules.nixos.cli_yazi = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.ripdrag
      pkgs.ouch
      pkgs.ripgrep
      pkgs.trash-cli
      pkgs.mediainfo
      pkgs.ffmpeg
      pkgs.ffmpegthumbnailer
    ];
    
    hm.programs.yazi = {
      enable = true;
      enableNushellIntegration = true;

      plugins = {
        drag = pkgs.yaziPlugins.drag;
        starship = pkgs.yaziPlugins.starship;
        ouch = pkgs.yaziPlugins.ouch;
        sudo = pkgs.yaziPlugins.sudo;
        restore = pkgs.yaziPlugins.restore;
        mediainfo = pkgs.yaziPlugins.mediainfo;
      };

      initLua = ''
        require("starship"):setup()
      '';

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = [ "<A-d>" ];
              run = "plugin drag";
              desc = "Drag files";
            }
            {
              on = [ "C" ];
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
            {
              on = [ "u" ];
              run = "plugin restore";
              desc = "Restore last deleted files/folders";
            }
            {
              on = [ "R" "p" ];
              run = "plugin sudo -- paste";
              desc = "Sudo paste";
            }
            {
              on = [ "R" "r" ];
              run = "plugin sudo -- rename";
              desc = "Sudo rename";
            }
            {
              on = [ "R" "l" ];
              run = "plugin sudo -- link";
              desc = "Sudo link";
            }
            {
              on = [ "R" "c" ];
              run = "plugin sudo -- create";
              desc = "Sudo create";
            }
            {
              on = [ "R" "d" ];
              run = "plugin sudo -- remove";
              desc = "Sudo trash";
            }
            {
              on = [ "R" "D" ];
              run = "plugin sudo -- remove --permanently";
              desc = "Sudo delete permanently";
            }
            {
              on = [ "R" "m" ];
              run = "plugin sudo -- chmod";
              desc = "Sudo chmod";
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
            {
              mime = "video/*";
              run = "mediainfo";
            }
            {
              mime = "audio/*";
              run = "mediainfo";
            }
          ];
        };
        opener = {
          edit = [
            { run = ''hx "$@"''; block = true; desc = "Helix"; }
          ];
          play = [
            { run = ''mpv "$@"''; orphan = true; for = "unix"; desc = "MPV"; }
          ];
        };
        open = {
          prepend_rules = [
            { mime = "video/*"; use = "play"; }
            { mime = "audio/*"; use = "play"; }
            { mime = "text/*"; use = "edit"; }
            { url = "*"; use = "edit"; }
          ];
        };
      };
    };
  };
}
