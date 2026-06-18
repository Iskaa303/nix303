{ inputs, ... }: {
  flake.modules.nixos.app_antigravity = {
    hm = {
      home.packages = [
        inputs.antigravity-nix.packages.x86_64-linux.default
      ];
    };
  };
}
