{
  boot.loader = {
    timeout = 2;

    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
  };
}
