{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    fuck-machine = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        config.flake.modules.nixos.fuck-machine
      ];
    };
  };
}
