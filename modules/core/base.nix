{ ... }: {
  flake.modules.nixos.core_base = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "iskaa303" ];
    };

    # Old generations piled up (286!) filling the boot menu and the store.
    # Keep the week-and-a-half of history and prune the rest automatically.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # A single hung unit should never stall shutdown for 90s+. The user
    # session (user@1000.service) carries systemd's 120s default, which is
    # what made shutdown wait before SIGKILL.
    systemd.settings.Manager.DefaultTimeoutStopSec = "30s";
    systemd.services."user@".serviceConfig.TimeoutStopSec = "15s";

    # Keep a text console reachable if the display manager / niri ever dies,
    # so a blank screen is never a dead end (Ctrl+Alt+F2).
    systemd.targets.getty.wants = [
      "getty@tty2.service"
      "getty@tty3.service"
    ];

    environment.systemPackages = with pkgs; [
      curl
      bash
      nano
      gh
    ];

    programs.nix-ld = {
      enable = true;
      libraries = [];
    };
  };
}
