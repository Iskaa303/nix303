{ inputs, ... }: {
  flake.modules.nixos.cli_lenovo = { pkgs, lib, ... }:
  let
    lenovo-legion = pkgs.python3Packages.buildPythonApplication rec {
      pname = "lenovo-legion";
      version = "unstable-2025-03-18";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "johnfanv2";
        repo = "LenovoLegionLinux";
        rev = "7c19579d13ce686cf1e237699b9a78e80d03c977";
        hash = "sha256-gTlUrbNKCUQ+g70StlqspDn90wKW2scssKPZqaegzTY=";
      };

      # Python project lives in a subdirectory
      sourceRoot = "source/python/legion_linux";

      build-system = with pkgs.python3Packages; [ setuptools ];

      dependencies = with pkgs.python3Packages; [
        pygobject3
        pycairo
        pyyaml
        argcomplete
        darkdetect
        pyqt6
        pillow
      ];

      # Runtime dep check fails on pyqt6 (it's available but hook is finicky)
      # but all deps are present
      dontUsePythonRuntimeDepsCheck = true;

      meta = with lib; {
        description = "Lenovo Legion Linux - Control Lenovo gaming laptops";
        homepage = "https://github.com/johnfanv2/LenovoLegionLinux";
        license = licenses.gpl3;
        platforms = platforms.linux;
        mainProgram = "legion_cli";
      };
    };
  in {
    environment.systemPackages = with pkgs; [
      lenovo-legion
      (pkgs.writeShellScriptBin "lenovo-profile" (builtins.readFile ./lenovo-profile.sh))
    ];
  };
}
