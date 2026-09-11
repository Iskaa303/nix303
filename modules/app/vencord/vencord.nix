{ inputs, ... }: {
  flake.modules.nixos.app_vencord = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
          postFixup = (oldAttrs.postFixup or "") + ''
            wrapProgram $out/bin/vesktop \
              --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer" \
              --add-flags "--ozone-platform=wayland"
          '';
        });
      })
    ];

    hm = {
      imports = [ inputs.nixcord.homeModules.nixcord ];
      programs.nixcord = {
        enable = true;

        vesktop.enable = true;
        discord.enable = false;

        userPlugins = {
        };

        quickCss = ''
          ::selection {
            background-color: var(--base0D) !important;
            color: var(--base00) !important;
          }
        '';

        config = {
          useQuickCss = true;
          plugins = {
            alwaysAnimate.enable = true;
            betterFolders.enable = true;
            betterGifAltText.enable = true;
            betterGifPicker.enable = true;
            betterSettings.enable = true;
            betterUploadButton.enable = true;
            biggerStreamPreview.enable = true;
            characterCounter.enable = true;
            copyEmojiMarkdown.enable = true;
            copyFileContents.enable = true;
            copyStickerLinks.enable = true;
            copyUserUrls.enable = true;
            crashHandler.enable = true;
            expressionCloner.enable = true;
            fixCodeblockGap.enable = true;
            fixImagesQuality.enable = true;
            forceOwnerCrown.enable = true;
            fullSearchContext.enable = true;
            fullUserInChatbox.enable = true;
            gifPaste.enable = true;
            greetStickerPicker.enable = true;
            imageFilename.enable = true;
            imageLink.enable = true;
            imageZoom.enable = true;
            memberCount.enable = true;
            mentionAvatars.enable = true;
            messageClickActions.enable = true;
            messageLatency.enable = true;
            messageLogger.enable = true;
            platformIndicators.enable = true;
            previewMessage.enable = true;
            quickReply.enable = true;
            readAllNotificationsButton.enable = true;
            secretRingToneEnabler.enable = true;
            sendTimestamps.enable = true;
            silentTyping.enable = true;
            tenorGifSearch.enable = true;
            typingTweaks.enable = true;
            unlockedAvatarZoom.enable = true;
            voiceDownload.enable = true;
            voiceMessages.enable = true;
            volumeBooster.enable = true;
            webScreenShareFixes.enable = true;
            whoReacted.enable = true;
          };
        };

        extraConfig.plugins = {
        };
      };
    };
  };
}
