{ inputs, ... }: {
  flake.modules.nixos.app_nixcord = {
    hm = {
      imports = [ inputs.nixcord.homeModules.nixcord ];
      programs.nixcord = {
        enable = true;
        legcord = {
          enable = true;
        };
      };
    };
  };
}
