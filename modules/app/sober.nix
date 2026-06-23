{ inputs, ... }: {
  flake.modules.nixos.app_sober = { pkgs, userVars, ... }: {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.vinegarhq.Sober"
    ];
  };
}
