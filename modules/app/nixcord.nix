{ inputs, ... }: {
  flake.modules.nixos.app_nixcord = {
    hm = {
      imports = [ inputs.nixcord.homeManagerModules.nixcord ];
      programs.nixcord = {
        enable = true;
        legcord = {
          enable = true;
        };
      };
    };
  };
}
