{ ... }: {
  flake.modules.nixos.app_qbittorrent = { pkgs, ... }: {
    hm.home.packages = [ pkgs.qbittorrent ];
  };
}
