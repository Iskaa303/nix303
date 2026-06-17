{ ... }: {
  flake.modules.nixos.cli_yazi = {
    hm.programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
        opener = {
          edit = [
            { run = ''hx "$@"''; block = true; desc = "Helix"; }
          ];
        };
        open = {
          prepend_rules = [
            { mime = "text/*"; use = "edit"; }
            { name = "*"; use = "edit"; }
          ];
        };
      };
    };
  };
}
