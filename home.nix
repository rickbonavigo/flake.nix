{
  config,
  lib,
  pkgs,
  nixpkgs-sage,
  ...
}: let
  androidSdk = "/opt/homebrew/share/android-commandlinetools";
  my-python = pkgs.python3.withPackages (ps:
    with ps; [
      pandas
      matplotlib
      pycryptodome
      requests
      beautifulsoup4
      ipython
      python-lsp-server
      dasbus
      bitstring
      numpy
      lxml
      pwntools
      virtualenv
      pyjwt
      gmpy2
      sympy
      pillow
      z3-solver
      scipy
    ]);
  my-sage = nixpkgs-sage.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sage.override {
    requireSageTests = false;
    withDoc = false;
    extraPythonPackages = ps:
      with ps; [
        pycryptodome
        pwntools
        lxml
      ];
  };
  apps = import ./apps.nix {inherit pkgs my-python my-sage;};
in {
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      cat = "bat";
    };
  };

  xdg.configFile."fish/config.fish".force = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings.directory = {
      truncation_length = 0;
      truncate_to_repo = false;
      fish_style_pwd_dir_length = 0;
      home_symbol = "~";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      update_check = false;
      style = "compact";
      inline_height = 20;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = apps.homePackages;

  home.stateVersion = "25.11";
  home.username = "rick";

  home.homeDirectory = "/Users/rick";

  home.sessionVariables = {
    ANDROID_HOME = androidSdk;

    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"

    "/opt/homebrew/opt/rustup/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${androidSdk}/cmdline-tools/latest/bin"
    "${androidSdk}/platform-tools"
    "${androidSdk}/emulator"
  ];

  programs.home-manager.enable = true;

  home.activation.installMasApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mas=/opt/homebrew/bin/mas

    if [ -x "$mas" ]; then
      installed_ids="$("$mas" list | ${pkgs.gawk}/bin/awk '{ print $1 }' || true)"

      for id in ${toString (map (app: app.id) apps.masApps)}; do
        if printf '%s\n' "$installed_ids" | ${pkgs.gnugrep}/bin/grep -qx "$id"; then
          continue
        fi

        "$mas" install "$id" || "$mas" get "$id" || echo "warning: failed to install MAS app $id" >&2
      done

      for id in ${toString (map (app: app.id) apps.masApps)}; do
        "$mas" upgrade "$id" || true
      done
    else
      echo "warning: mas is not installed; skipping Mac App Store apps" >&2
    fi
  '';
}
