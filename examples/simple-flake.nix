# Example: Simple project using devshells
# Copy this to your project's flake.nix
{
  description = "My project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshells.url = "github:yourusername/devshells";
  };

  outputs = inputs@{ flake-parts, devshells, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      imports = [ devshells.flakeModules.default ];

      perSystem = { config, pkgs, ... }: {
        devshells.shells.default = {
          name = "my-project";
          languages = {
            python.enable = true;
            typescript.enable = true;
            nix.enable = true;
          };
          extraPackages = with pkgs; [
            docker-compose
          ];
        };
      };
    };
}
