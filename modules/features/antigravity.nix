{ inputs, ... }: {
  flake.modules.nixos.feature_antigravity = {
   # nixpkgs.config.allowUnfreePredicate = pkg: 
   #   builtins.elem (inputs.nixpkgs.lib.getName pkg) [
   #     "google-antigravity"
   #     "google-antigravity-ide"
   #   ];

    hm = {
      home.packages = [
        inputs.antigravity-nix.packages.x86_64-linux.default
      ];
    };
  };
}
