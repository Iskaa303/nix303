{ ... }: {
  flake.modules.nixos.cli_nushell = { pkgs, username, ... }: {
    environment.shells = [ pkgs.nushell ];
    users.users."${username}".shell = pkgs.nushell;

    hm.programs.nushell = {
      enable = true;
      extraConfig = ''
        $env.config = {
          show_banner: false
          completions: {
            case_sensitive: false
            quick: true
            partial: true
            algorithm: "prefix"
            external: {
              enable: true
              max_results: 100
            }
          }
        }

        alias ff = fastfetch --logo-type kitty --logo /persist/etc/nixos/assets/logo.png
        alias lg = lazygit
      '';
    };

    hm.programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
