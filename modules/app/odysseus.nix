{ inputs, ... }: {
  flake.modules.nixos.app_odysseus = { pkgs, lib, ... }:
  let
    odysseus-src = pkgs.fetchFromGitHub {
      owner = "odysseus-dev";
      repo = "odysseus";
      rev = "main";
      hash = "sha256-Xq38dq91Au6rfqa2vmI6PZy3XJPKUoQokl/UG0FrOzg=";
    };
  in {
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "L+ /persist/odysseus/src - - - - ${odysseus-src}"
    ];

    systemd.services.odysseus-env = {
      description = "Odysseus env + compose setup";
      before = [ "odysseus.service" ];
      requiredBy = [ "odysseus.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        cd /persist/odysseus

        # Create .env from example if missing
        if [ ! -f .env ]; then
          cp ${odysseus-src}/.env.example .env
          echo "Created /persist/odysseus/.env - edit it to add your LLM config"
        fi

        # Create compose override so build context points to the src symlink
        if [ ! -f docker-compose.override.yml ]; then
          cat > docker-compose.override.yml << 'EOF'
services:
  odysseus:
    build:
      context: ./src
    depends_on:
      searxng:
        condition: service_started
      chromadb:
        condition: service_started
EOF
          echo "Created docker-compose.override.yml"
        fi

        # Replace stale config dir with symlink to source (searxng settings.yml needed by compose)
        rm -rf config
        ln -sf ${odysseus-src}/config config
      '';
    };

    systemd.services.odysseus = {
      description = "Odysseus AI workspace";
      wants = [ "docker.service" "odysseus-env.service" ];
      after = [ "docker.service" "network.target" "odysseus-env.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.docker-compose pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/persist/odysseus";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans 2>&1 | tee /persist/odysseus/docker-compose.log'";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      };
    };
  };
}
