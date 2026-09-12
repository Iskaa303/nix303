{ ... }: {
  flake.modules.nixos.cli_atuin = { pkgs, lib, ... }:
    let
      # atuin names both of its keybindings "atuin", and nushell warns on duplicate names.
      # Re-emit `atuin init nu` with a unique name for the up-arrow binding (same bindings).
      nushellConfig = pkgs.runCommand "atuin-nushell-config.nu" {
        nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ];
      } ''
        ${lib.getExe pkgs.atuin} init nu | ${pkgs.gawk}/bin/awk '
          /name: atuin/ { i++ }
          i == 2 && !done { sub(/name: atuin/, "name: atuin-up"); done = 1 }
          { print }
        ' > $out
      '';
    in {
      hm.programs.atuin = {
        enable = true;
        # replaced by nushellConfig below (same script, unique keybinding names)
        enableNushellIntegration = false;
        enableBashIntegration = true;
        settings = {
          auto_sync = false;
          update_check = false;
        };
      };

      hm.programs.nushell.extraConfig = lib.mkOrder 2000 ''
        source ${nushellConfig}
      '';
    };
}
