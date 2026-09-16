{
  description = "Noh's CornFlakes";

  inputs = {
    # https://nixos.wiki/wiki/Nix_channels
    # https://discourse.nixos.org/t/differences-between-nix-channels/13998
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      # this line makes darwin uses same version of `nixpkgs` with nixpkgs flake.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Firefox user.js baseline, read by users/common/firefox.nix.
    # Bump with `nix flake update betterfox`.
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, disko, ... }@inputs:
    let
      inherit (self) outputs;
      overlays = import ./overlays { inherit inputs; };

      mkNixos = extraModules: nixpkgs.lib.nixosSystem {
        modules = extraModules;
        specialArgs = { inherit inputs outputs; };
      };

      mkDarwin = extraModules: darwin.lib.darwinSystem {
        inherit inputs;
        system = "aarch64-darwin"; # FIXME: option for intel macs
        modules = extraModules;
        specialArgs = { inherit inputs outputs; };
      };

      mkHome = system: modules: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = with overlays; [
            modifications
            neovim-nightly
            claude-code
            codex-cli
          ];
        };
        extraSpecialArgs = { inherit inputs outputs; };
        inherit modules;
      };
    in
    {
      overlays = overlays;

      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust development shell with Fenix toolchain";
        };
        rust-overlay = {
          path = ./templates/rust-overlay;
          description = "Rust development shell with oxalica/rust-overlay (rust-toolchain.toml)";
        };
        c = {
          path = ./templates/c;
          description = "C/C++ development shell with clang and CMake";
        };
        go = {
          path = ./templates/go;
          description = "Go development shell";
        };
      };

      nixosConfigurations = {
        s76 = mkNixos [ disko.nixosModules.disko ./machines/s76.nix ];
        ion = mkNixos [ ./machines/ion.nix ];

        # vm-x86 = mkNixos [ ./machines/vm-x86.nix ];
        # vm-aarch64 = mkNixos [ ./machines/vm-aarch64.nix ];
      };

      darwinConfigurations = {
        noahMBA = mkDarwin [ ./machines/noahMBA.nix ];
        taehyunM5A = mkDarwin [ ./machines/taehyunM5A.nix ];
      };

      homeConfigurations = {
        "noah@noahMBA" = mkHome "aarch64-darwin" [ ./users/noah.nix ];
        "taehyun@taehyunM5A" = mkHome "aarch64-darwin" [ ./users/taehyun-macos.nix ];
        "noah@s76"     = mkHome "x86_64-linux"   [ ./users/noah-nixos.nix ];
        "noah@ion"     = mkHome "x86_64-linux"   [ ./users/noah-nixos.nix ];
        blurry         = mkHome "x86_64-linux"   [ ./users/blurry.nix ];
        taehyun        = mkHome "x86_64-linux"   [ ./users/taehyun.nix ];
      };
    };
}
