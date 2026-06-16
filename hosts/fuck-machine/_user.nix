{ ... }:
let
  vars = import ./_user-vars.nix;
in {
  users.users."${vars.username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "usb" "video" "networkmanager" ];
    hashedPasswordFile = "/persist/passwords/${vars.username}";
  };
}
