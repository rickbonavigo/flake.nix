{
  description = "Rick's Nix-Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-sage.url = "github:NixOS/nixpkgs/aa48d347080940b8a2b8d2f48228674e280a3514";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs-sage,
    home-manager,
    nix-homebrew,
    ...
  }: let
    apps = import ./apps.nix {};

    configuration = {
      pkgs,
      inputs,
      ...
    }: {
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
      environment.etc."nix/nix.custom.conf".text = ''
        nix-path = nixpkgs=flake:nixpkgs
      '';
      nix.nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs"];

      nixpkgs.config.allowUnfree = true;

      environment.variables = {
        LC_COLLATE = "C";
      };

      launchd.user.envVariables = {
        ANDROID_HOME = "/opt/homebrew/share/android-commandlinetools";
      };

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };

        inherit (apps) brews;
        inherit (apps) casks;
      };

      networking.hostName = "grothendieck";
      networking.localHostName = "grothendieck";
      networking.computerName = "grothendieck";

      users.users.rick.home = "/Users/rick";
      users.users.root.shell = pkgs.fish;
      system.primaryUser = "rick";

      programs.fish.enable = true;
      environment.shells = [pkgs.fish];

      environment.systemPath = ["/opt/homebrew/bin"];

      launchd.daemons.karabiner-virtualhiddevice-manager.serviceConfig = {
        Label = "org.pqrs.karabiner.virtualhiddevice.manager";
        ProgramArguments = [
          "/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"
          "activate"
        ];
        RunAtLoad = true;
        StandardOutPath = "/var/log/karabiner-virtualhiddevice-manager.log";
        StandardErrorPath = "/var/log/karabiner-virtualhiddevice-manager.log";
      };

      launchd.daemons.karabiner-virtualhiddevice-daemon.serviceConfig = {
        Label = "org.pqrs.karabiner.virtualhiddevice.daemon";
        ProgramArguments = [
          "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/karabiner-virtualhiddevice-daemon.log";
        StandardErrorPath = "/var/log/karabiner-virtualhiddevice-daemon.log";
      };

      launchd.daemons.kanata.serviceConfig = {
        Label = "org.rick.kanata";
        ProgramArguments = [
          "/opt/homebrew/bin/kanata"
          "-t"
          "--cfg"
          "/Users/rick/.config/kanata.cfg"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 10;
        StandardOutPath = "/var/log/kanata.log";
        StandardErrorPath = "/var/log/kanata.log";
      };

      nix.enable = false;

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    darwinConfigurations."grothendieck" = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs;};
      modules = [
        configuration

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "rick";
            autoMigrate = true;
            mutableTaps = true;
          };
        }

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit nixpkgs-sage;};
            backupFileExtension = "before-nix-darwin";
            users.rick = ./home.nix;
          };
        }
      ];
    };
  };
}
