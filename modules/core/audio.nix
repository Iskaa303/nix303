{ ... }: {
  flake.modules.nixos.core_audio = { pkgs, ... }: {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    services.pulseaudio.enable = false;

    boot.extraModprobeConfig = "options snd_usb_audio power_save=0";
  };
}
