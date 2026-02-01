# Example: Using devshells in another repository
# This shows how to import the devshell module and create custom shells
{
  description = "AI Coding Environment (example of consuming devshells)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    # Import the devshells flake
    devshells.url = "github:yourusername/devshells";
    # Or for local development:
    # devshells.url = "path:../modular";
  };

  outputs = inputs@{ flake-parts, devshells, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Import the devshell module from devshells flake
      imports = [ devshells.flakeModules.default ];

      perSystem = { config, pkgs, lib, ... }: {
        # Define your custom shells
        devshells.shells = {
          # Simple shell using built-in languages
          default = {
            name = "ai-coding";
            languages = {
              python.enable = true;
              nix.enable = true;
            };
            extraPackages = with pkgs; [
              # Add claude-code or other AI tools
              # claude-code
            ];
          };

          # Shell with custom language module
          with-claude = {
            name = "ai-claude";
            languages = {
              python.enable = true;
              typescript.enable = true;
              nix.enable = true;
              # Enable your custom language
              claude.enable = true;
            };
            
            # Add custom language modules
            extraLanguageModules = {
              claude = {
                name = "claude";
                plugins = with pkgs.vimPlugins; [
                  # avante-nvim
                  # codecompanion-nvim
                ];
                packages = with pkgs; [
                  # claude-code
                ];
                config = ''
                  -- Claude AI configuration
                  -- require("avante").setup({
                  --   provider = "claude",
                  --   claude = {
                  --     model = "claude-sonnet-4-20250514",
                  --   },
                  -- })
                  
                  -- Keymap to open Claude in terminal
                  vim.keymap.set("n", "<leader>cc", 
                    "<cmd>TermExec cmd='claude'<cr>", 
                    { desc = "Open Claude Code" })
                '';
              };
            };
            
            extraConfig = ''
              -- Project-specific config
              vim.g.ai_enabled = true
            '';
            
            shellHook = ''
              echo "AI coding environment ready!"
              echo "Press <leader>cc to open Claude Code"
            '';
          };
        };

        # You can also use the library directly for more control
        # devShells.custom = config.devshells.lib.mkDevShell {
        #   name = "custom";
        #   languages = [ "python" "nix" ];
        # };
      };
    };
}
