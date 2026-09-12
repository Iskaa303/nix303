{ ... }: {
  flake.modules.nixos.app_sioyek = {
    hm = {
      stylix.targets.sioyek.enable = true;
      programs.sioyek.enable = true;

      xdg.mimeApps = {
        enable = true;
        defaultApplications."application/pdf" = "sioyek.desktop";
      };
    };
  };
}
