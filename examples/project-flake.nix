{
  description = "Example project using composable devshells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Reference the devshells flake (adjust path as needed)
    # For local development:
    devshells.url = "path:../devshells";
    # Or from a git repo:
    # devshells.url = "github:yourusername/devshells";
  };

  outputs = { self, nixpkgs, flake-utils, devshells }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Access the library from devshells
        inherit (devshells.lib.${system}) mkDevShell mkNeovim languageConfigs;

        # You can extend language configs for project-specific needs
        extendedLanguageConfigs = languageConfigs // {
          # Override or extend existing configs
          typescript = languageConfigs.typescript // {
            extraPackages = languageConfigs.typescript.extraPackages ++ [
              pkgs.nodePackages.pnpm
              pkgs.nodePackages.eslint
            ];
          };

          # Add completely new language support
          terraform = {
            extraPlugins = [ ];
            extraPackages = with pkgs; [
              terraform
              terraform-ls
              tflint
            ];
            extraConfig = ''
              require("lspconfig").terraformls.setup({
                capabilities = _G.lsp_capabilities,
              })
            '';
          };
        };

      in
      {
        devShells = {
          # Use the pre-built shell directly
          default = devshells.devShells.${system}.typescript;

          # Or create a custom shell using the builder
          custom = mkDevShell {
            name = "my-project";
            languages = [ "typescript" "python" ];
            extraPackages = with pkgs; [
              awscli2
              docker-compose
            ];
          };
        };
      }
    );
}
