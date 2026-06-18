{ config, inputs, ... }:
let
  vars = import ./fuck-machine/_user-vars.nix;
in {
  flake.nixosConfigurations = {
    fuck-machine = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; username = vars.username; userVars = vars; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
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
