{ inputs, ... }:
{
  flake.modules.nixos.desktop_niri = { pkgs, lib, ... }:
    let
      # Flameshot can only capture through the portal on Wayland, and the portal
      # always asks which monitor. grim talks to niri directly, so Print is a
      # one-shot grab of the focused output with no dialog.
      screenshot = pkgs.writeShellApplication {
        name = "screenshot";
        runtimeInputs = [ pkgs.grim pkgs.wl-clipboard pkgs.jq pkgs.niri pkgs.libnotify pkgs.coreutils ];
        text = ''
          out="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          mkdir -p "$(dirname "$out")"
          if [ "''${1:-focused}" = all ]; then
            grim "$out"
          else
            grim -o "$(niri msg -j focused-output | jq -r .name)" "$out"
          fi
          wl-copy < "$out"
          notify-send -a screenshot -i "$out" "Screenshot copied" "$(basename "$out")"
        '';
      };

      # flameshot cannot capture a screen itself on Wayland: it asks
      # xdg-desktop-portal, and whatever backend answers decides whether you get a
      # picker. xdg-desktop-portal-wlr answers with slurp (a picker); this answers
      # straight from grim with the whole desktop, no interaction.
      screenshotPortal = pkgs.runCommandLocal "xdg-desktop-portal-focused" { } ''
        mkdir -p $out/share/xdg-desktop-portal/portals $out/share/dbus-1/services
        cat > $out/share/xdg-desktop-portal/portals/focused.portal <<'EOF'
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.focused
        Interfaces=org.freedesktop.impl.portal.Screenshot
        EOF
        cat > $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.focused.service <<'EOF'
        [D-BUS Service]
        Name=org.freedesktop.impl.portal.desktop.focused
        Exec=${screenshotPortalDaemon}/bin/focused-screenshot-portal
        EOF
      '';

      screenshotPortalDaemon = pkgs.writeShellApplication {
        name = "focused-screenshot-portal";
        runtimeInputs = [ (pkgs.python3.withPackages (ps: [ ps.dbus-python ps.pygobject3 ])) pkgs.grim ];
        text = "exec python3 ${screenshotPortalScript}";
      };

      screenshotPortalScript = pkgs.writeText "focused-screenshot-portal.py" ''
        import os, subprocess, time
        import dbus, dbus.mainloop.glib, dbus.service
        from gi.repository import GLib

        BUS_NAME = "org.freedesktop.impl.portal.desktop.focused"


        def log(message):
            path = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "focused-portal.log")
            with open(path, "a") as handle:
                handle.write(message + "\n")


        _requests = {}


        class Request(dbus.service.Object):
            """The portal calls Close on the request handle right after a capture."""

            @dbus.service.method("org.freedesktop.impl.portal.Request", in_signature="", out_signature="")
            def Close(self):
                _requests.pop(self._object_path, None)
                self.remove_from_connection()


        class Screenshot(dbus.service.Object):
            @dbus.service.method(
                "org.freedesktop.impl.portal.Screenshot",
                in_signature="ossa{sv}",
                out_signature="ua{sv}",
            )
            def Screenshot(self, handle, app_id, parent_window, options):
                runtime = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
                # Register the handle first: xdg-desktop-portal calls Close() on it
                # immediately and treats a missing method as a failed capture.
                try:
                    _requests[str(handle)] = Request(dbus.SessionBus(), handle)
                except Exception as error:
                    log("request object failed: %s" % error)
                # Always the whole desktop: flameshot paints the image across
                # every monitor, and Ctrl+Print hands it the focused monitor's
                # rectangle as a pre-made selection, so nothing has to crop here.
                path = os.path.join(runtime, "portal-screenshot-%d.png" % (time.time() * 1000))
                try:
                    subprocess.run(["grim", path], check=True)
                except subprocess.CalledProcessError as error:
                    # Never fail the capture: flameshot shows an error dialog and the
                    # key looks broken.
                    log("grim failed: %s" % error)
                    return (2, {})
                log("captured %s" % path)
                return (0, {"uri": "file://" + path})


        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        bus = dbus.SessionBus()
        bus_name = dbus.service.BusName(BUS_NAME, bus)  # keep the reference: dropping it frees the name
        # xdg-desktop-portal calls the backend at /org/freedesktop/portal/desktop.
        Screenshot(bus, "/org/freedesktop/portal/desktop")
        Screenshot(bus, "/org/freedesktop/impl/portal/Screenshot")
        log("serving as %s" % BUS_NAME)
        GLib.MainLoop().run()
      '';

      # flameshot's editor always opens by asking for a region. Hand it the
      # focused monitor's rectangle and the region is already there: annotate
      # straight away, Enter copies. Without a region it lets you drag.
      # flameshot 15 asks the portal for the whole desktop and then shows its
      # own monitor picker (ScreenGrabber::unixScreenshot) before the editor ever
      # appears. Only a pre-selected monitor skips that picker, which is what
      # `screen -n <index>` sets. Qt's index is not niri's order, so it is learned
      # once per session by capturing each index raw and reading the image size.
      flameshotEdit = pkgs.writeShellApplication {
        name = "flameshot-edit";
        runtimeInputs = [ pkgs.flameshot pkgs.niri pkgs.jq pkgs.file pkgs.coreutils pkgs.gnused ];
        text = ''
          outputs=$(niri msg -j outputs) || exit 1
          focused=$(niri msg -j focused-output | jq -r .name) || exit 1
          size=$(printf '%s' "$outputs" | jq -r --arg n "$focused" '.[$n].logical | "\(.width)x\(.height)"') || exit 1
          runtime="''${XDG_RUNTIME_DIR:-/tmp}"
          cache="$runtime/flameshot-monitor-index"
          [ -f "$cache" ] || : > "$cache"

          index=$(awk -v s="$size" '$1 == s { print $2; exit }' "$cache")
          if [ -z "$index" ]; then
            : > "$cache"
            count=$(printf '%s' "$outputs" | jq 'length')
            i=0
            while [ "$i" -lt "$count" ]; do
              shot="$runtime/flameshot-probe-$i.png"
              flameshot screen -n "$i" -r > "$shot" 2>/dev/null || true
              dims=$(file -b "$shot" 2>/dev/null | sed -n 's/^PNG image data, \([0-9]*\) x \([0-9]*\).*/\1x\2/p')
              [ -n "$dims" ] && printf '%s %s\n' "$dims" "$i" >> "$cache"
              rm -f "$shot"
              i=$((i + 1))
            done
            index=$(awk -v s="$size" '$1 == s { print $2; exit }' "$cache")
          fi

          if [ -n "$index" ]; then
            # No --region: the editor opens empty, and flameshot's own
            # saveLastRegion brings the previous box back on the next capture.
            exec flameshot screen --edit -n "$index"
          fi
          exec flameshot gui
        '';
      };
    in
    {
    xdg.portal.extraPortals = [ screenshotPortal ];
    xdg.portal.config.common."org.freedesktop.impl.portal.Screenshot" = lib.mkForce "focused";

    hm.home.packages = [ screenshot flameshotEdit ];

    # saveLastRegion is off by default, so a fresh editor forgets the box you
    # just dragged. Keep the key set: flameshot can still rewrite the rest.
    hm.home.activation.flameshotLastRegion = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cfg="$HOME/.config/flameshot/flameshot.ini"
      mkdir -p "$(dirname "$cfg")"
      if [ ! -f "$cfg" ]; then
        printf '[General]\nsaveLastRegion=true\n' > "$cfg"
      elif ! grep -q '^saveLastRegion=true$' "$cfg"; then
        if grep -q '^saveLastRegion=' "$cfg"; then
          sed -i 's/^saveLastRegion=.*/saveLastRegion=true/' "$cfg"
        elif grep -q '^\[General\]' "$cfg"; then
          sed -i '/^\[General\]/a saveLastRegion=true' "$cfg"
        else
          printf '[General]\nsaveLastRegion=true\n' >> "$cfg"
        fi
      fi
    '';
    hm.programs.niri.settings.binds = {
      # Apps Manipulation
      "Mod+Return".action.spawn = "ghostty";
      "Mod+T".action.spawn = "foot";
      "Mod+B".action.spawn = "librewolf-dispatch";
      "Mod+Shift+B".action.spawn = [ "librewolf-dispatch" "private" ];
      "Mod+D".action.spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ];
      "Mod+E".action.spawn = [ "noctalia" "msg" "panel-toggle" "session" ];
      "Mod+O".action.spawn = "obs";
      "Mod+Q".action.close-window = {};

      # Navigation
      "Mod+Left".action.focus-column-left = {};
      "Mod+Right".action.focus-column-right = {};
      "Mod+Down".action.focus-window-down = {};
      "Mod+Up".action.focus-window-up = {};

      # Window Global Position
      "Mod+Shift+Left".action.move-column-left = {};
      "Mod+Shift+Right".action.move-column-right = {};
      "Mod+Shift+Down".action.move-window-down = {};
      "Mod+Shift+Up".action.move-window-up = {};

      # Window Size
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+F".action.maximize-column = {};
      "Mod+Shift+F".action.fullscreen-window = {};
      "Mod+R".action.switch-preset-column-width = {};
      "Mod+Shift+R".action.switch-preset-window-height = {};
      "Mod+Ctrl+R".action.reset-window-height = {};

      # Workspace Navigation
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      # Window Workspace Position
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;

      # Screenshots. Print = focused monitor straight to the clipboard, no
      # dialog; Ctrl+Print = flameshot's editor already opened on the focused
      # monitor, region preselected; Ctrl+Shift+Print = same editor, free to
      # drag across both monitors; Shift+Print = every monitor, no editor.
      "Print".action.spawn = [ "screenshot" ];
      "Ctrl+Print".action.spawn = [ "flameshot-edit" ];
      "Ctrl+Shift+Print".action.spawn = [ "flameshot" "gui" ];
      "Shift+Print".action.spawn = [ "screenshot" "all" ];
    };
  };
}
