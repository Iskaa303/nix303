{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    curl
    bash
    git
    nano
    neovim
  ];
}
