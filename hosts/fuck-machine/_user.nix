{ ... }:
let
  username = import ./username.nix;
in {
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "usb" "video" "networkmanager" ];
    hashedPasswordFile = "/persist/passwords/${username}";
  };
}
