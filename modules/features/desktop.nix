{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    firefox
    ghostty
  ];
}
