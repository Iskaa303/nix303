{ username ? "iskaa303", ... }: {
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "usb" "video" "networkmanager" ];
    hashedPasswordFile = "/persist/passwords/${username}";
  };
}
