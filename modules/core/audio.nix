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

      wireplumber.extraConfig."50-audio-fixes" = {
        "wireplumber.settings" = {
          # PipeWire ramps this Realtek source through ALSA "Capture" (+30 dB)
          # and then "Internal Mic Boost" (+30 dB), so the stock volume of 1.0
          # is +60 dB and the capture clips into mush. 0.2 lands at
          # Capture ~47 / boost 0 (~+18 dB), which is audibly clean.
          "device.routes.default-source-volume" = 0.2;

          # Do not auto-flip the Bluetooth headset to HSP/HFP (telephony
          # quality) whenever any app opens a microphone. Its HFP transport is
          # flaky on this stack and leaves the mic dead after rejoining calls.
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
    services.pulseaudio.enable = false;

    # NixOS kernels default to CONFIG_SND_HDA_POWER_SAVE_DEFAULT=10, so the
    # Realtek codec sleeps/wakes during calls; that is a known source of
    # crackle and DC-offset distortion that creeps in after a few minutes.
    # The old `snd_usb_audio power_save=0` line was ignored -- that module has
    # no such parameter; the HDA driver is the one that needs it.
    boot.extraModprobeConfig = "options snd_hda_intel power_save=0 power_save_controller=N";

    # `mic-check [seconds]` records the default mic and reports peak/RMS/DC/
    # clipping, so a bad mic is obvious without launching Discord or OBS.
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mic-check" ''
        set -eu
        secs="''${1:-5}"
        raw="$(${pkgs.coreutils}/bin/mktemp --suffix=.raw)"
        trap 'rm -f "$raw"' EXIT
        echo "Recording ''${secs}s from the default microphone - speak normally..."
        ${pkgs.coreutils}/bin/timeout "$secs" ${pkgs.pipewire}/bin/pw-record --container raw --format s16 \
          --rate 48000 --channels 1 "$raw" >/dev/null 2>&1 || true
        ${pkgs.coreutils}/bin/od -An -v -td2 "$raw" | ${pkgs.gawk}/bin/awk '
          { for (i = 1; i <= NF; i++) { v = $i; n++; s += v; ss += v * v; a = (v < 0 ? -v : v); if (a > p) p = a; if (a >= 32760) c++ } }
          END {
            if (n == 0) { print "no samples recorded"; exit 1 }
            printf "samples=%d  peak=%d  rms=%.0f  dc=%.0f  clipped=%d (%.2f%%)\n", n, p, sqrt(ss / n), s / n, c, 100 * c / n;
            if (c > n * 0.001) print "  => CLIPPING - lower the microphone volume"
            else if (p < 500) print "  => very quiet - raise the volume or check the input"
            else print "  => OK, no clipping"
          }'
      '')
    ];
  };
}
