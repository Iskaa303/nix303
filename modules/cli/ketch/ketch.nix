{ ... }: {
  flake.modules.nixos.cli_ketch = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        ketch = prev.buildGoModule {
          pname = "ketch";
          version = "0-unstable";
          src = prev.fetchFromGitHub {
            owner = "1broseidon";
            repo = "ketch";
            rev = "main";
            hash = "sha256-GdQ5fhYkBuiRmMOxFTg3c2ixMLkRRyhQDyHBwhF3ifc=";
          };
          vendorHash = "sha256-Kk7fY27y1ziJEMpwRUoGfslGYYQdayLDuuRvNyfiAy8=";
          subPackages = [ "." ];
          ldflags = [
            "-s" "-w"
            "-X github.com/1broseidon/ketch/internal/version.Version=flake"
          ];
          meta = with prev.lib; {
            description = "Stateless CLI for web search, code search, library docs, and scraping";
            license = licenses.mit;
            mainProgram = "ketch";
          };
        };
      })
    ];

    hm = {
      home.packages = [ pkgs.ketch ];

      # ketch config: write a real file (not a Nix-store symlink) so
      # `ketch config set` works. The .config/ketch directory is
      # persisted via preservation, so changes survive reboots.
      home.activation.ketchConfig = let
        defaultConfig = builtins.toJSON {
          backend = "searxng";
          searxng_url = "http://localhost:8888";
          limit = 10;
          browser = "/home/iskaa303/.cache/ketch/browser/chromium-1321438/chrome";
        };
      in ''
        CFG="$HOME/.config/ketch/config.json"
        # remove old Nix-store symlink from previous home.file deployment
        if [ -L "$CFG" ]; then rm -f "$CFG"; fi
        if [ ! -f "$CFG" ]; then
          mkdir -p "$(dirname "$CFG")"
          echo '${defaultConfig}' > "$CFG"
        fi
      '';
    };
  };
}
