{
  pkgs ? null,
  my-python ? null,
  my-sage ? null,
}: {
  brews = [
    "mistral-vibe"
    "mise"
    {
      name = "1jehuang/jcode/jcode";
      trusted = true;
    }
    {
      name = "us/crw/crw";
      trusted = true;
    }
    {
      name = "us/tap/mocker";
      trusted = true;
    }
    {
      name = "can1357/tap/omp";
      trusted = true;
    }
    "rustup"

    "mas"
    "gh"
    "gemini-cli"
    "ghidra"
    "ffmpeg-full"
    "jadx"
    "binutils"
    "kanata"

    "lazygit"
    "diff-pdf"
    "container"
    "ipatool"
    "openjdk"
    "opencode"
    "apktool"
    "ncdu"
    "helm"
    "awscli"
  ];

  casks = [
    {
      name = "d12frosted/emacs-plus/emacs-plus-app";
      trusted = true;
    }
    "nordvpn"
    "iloader"
    "chatgpt"
    "claude"
    "google-chrome"
    "claude-code"
    "codex"
    "mitmproxy"

    "calibre"
    "meld"
    "transmission"
    "reader"
    "obsidian"

    "brave-browser"
    "ghostty"
    "google-drive"
    "karabiner-elements"

    "linearmouse"
    "netnewswire"
    "orbstack"
    "pearcleaner"
    "rectangle"
    "signal"

    "utm"

    "xquartz"
    "zed"
    "zotero"

    "iina"
    "telegram"
    "android-platform-tools"
    "android-commandlinetools"
    "android-studio"
  ];

  masApps = [
    {
      name = "WireGuard";
      id = 1451685025;
    }

    {
      name = "Tailscale";
      id = 1475387142;
    }
    {
      name = "TestFlight";
      id = 899247664;
    }
    {
      name = "WhatsApp";
      id = 310633997;
    }
    {
      name = "uBlock Origin Lite";
      id = 6745342698;
    }
  ];

  homePackages = with pkgs; [
    elixir
    livebook
    gleam

    atool
    ouch

    qrtool
    nh
    nix-output-monitor
    comma
    devenv
    nil
    alejandra
    statix
    deadnix
    shellcheck
    shfmt
    just
    watchexec
    jq
    croc
    delta
    gdu
    duf
    dust
    bottom
    procs
    eza
    bat
    fzf
    socat
    fd
    ripgrep
    ripgrep-all
    neovim
    tree
    typst
    pandoc
    uv

    age
    sops
    ssh-to-age
    hyperfine
    rclone
    yt-dlp
    imagemagick
    exiftool
    poppler-utils

    sqlite
    duckdb

    frida-tools

    my-python

    my-sage
  ];
}
