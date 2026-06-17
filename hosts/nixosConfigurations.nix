{ config, inputs, ... }:
let
  vars = import ./fuck-machine/_user-vars.nix;
in {
  flake.nixosConfigurations = {
    fuck-machine = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; username = vars.username; userVars = vars; };
      modules = [
        config.flake.modules.nixos.fuck-machine
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = { inherit inputs; username = vars.username; userVars = vars; };
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
  };
}
