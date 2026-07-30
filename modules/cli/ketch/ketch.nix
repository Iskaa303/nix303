{ ... }: {
  flake.modules.nixos.cli_ketch = { pkgs, ... }: {
    hm = {
      home.packages = [
        (pkgs.buildGoModule {
          pname = "ketch";
          version = "0-unstable";
          src = pkgs.fetchFromGitHub {
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
          meta = with pkgs.lib; {
            description = "Stateless CLI for web search, code search, library docs, and scraping";
            license = licenses.mit;
            mainProgram = "ketch";
          };
        })
      ];

      # ketch config: default to local SearXNG
      home.file.".config/ketch/config.json".text = builtins.toJSON {
        backend = "searxng";
        searxng_url = "http://localhost:8888";
        limit = 10;
      };
    };
  };
}
