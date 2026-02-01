{
  description = "Composable development shells with modular Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems to build for
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Import the devshell module
      imports = [ ./modules/devshell.nix ];

      # Per-system outputs
      perSystem = { config, pkgs, lib, system, ... }: {
        # Pre-configured shells for convenience
        devshells.shells = {
          default = {
            name = "nix";
            languages.nix.enable = true;
          };

          python = {
            name = "python";
            languages.python.enable = true;
            languages.nix.enable = true;
          };

          typescript = {
            name = "typescript";
            languages.typescript.enable = true;
            languages.nix.enable = true;
          };

          csharp = {
            name = "csharp";
            languages.csharp.enable = true;
            languages.nix.enable = true;
          };

          rust = {
            name = "rust";
            languages.rust.enable = true;
            languages.nix.enable = true;
          };

          fullstack = {
            name = "fullstack";
            languages.typescript.enable = true;
            languages.python.enable = true;
            languages.nix.enable = true;
            extraPackages = with pkgs; [
              docker-compose
              postgresql
              redis
            ];
          };

          dotnet-fullstack = {
            name = "dotnet-fullstack";
            languages.csharp.enable = true;
            languages.typescript.enable = true;
            languages.nix.enable = true;
            extraPackages = with pkgs; [
              docker-compose
              azure-cli
            ];
          };
        };
      };

      # Flake-level outputs (non-system-specific)
      flake = {
        # Export the flake module for other flakes to import
        flakeModules.default = ./modules/devshell.nix;
        flakeModules.devshell = ./modules/devshell.nix;
      };
    };
}
