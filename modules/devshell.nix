# Flake-parts module for composable devshells
# This module can be imported by other flakes to use the devshell system
{ self, inputs, ... }:

{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption ({ config, pkgs, lib, system, ... }:
    let
      # Import base Neovim configuration
      baseNeovim = import ../neovim/base.nix { inherit pkgs; };

      # Import all language modules
      languageModules = import ../neovim/languages { inherit pkgs lib; };

      # Available language names
      availableLanguages = builtins.attrNames languageModules;

      # Language submodule type
      languageSubmodule = lib.types.submodule {
        options.enable = lib.mkEnableOption "this language";
      };

      # Shell configuration submodule
      shellSubmodule = lib.types.submodule ({ config, name, ... }: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Name of the devshell (shown in PS1)";
          };

          languages = lib.mkOption {
            type = lib.types.attrsOf languageSubmodule;
            default = {};
            description = "Languages to enable in this shell";
          };

          extraLanguageModules = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = {};
            description = "Additional language modules to include";
          };

          extraPackages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to include in the shell";
          };

          extraPlugins = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional Neovim plugins to include";
          };

          extraConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "Additional Lua configuration for Neovim";
          };

          shellHook = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "Shell hook to run when entering the shell";
          };
        };
      });

      # Build a shell from a shell configuration
      buildShell = shellName: shellConfig:
        let
          # Merge built-in and extra language modules
          allLanguageModules = languageModules // shellConfig.extraLanguageModules;

          # Get enabled languages
          enabledLanguages = lib.filterAttrs 
            (name: cfg: cfg.enable && builtins.hasAttr name allLanguageModules) 
            shellConfig.languages;
          enabledNames = builtins.attrNames enabledLanguages;

          # Get configs for enabled languages
          configs = map (name: allLanguageModules.${name}) enabledNames;

          # Merge all language configs
          merged = {
            plugins = builtins.concatLists (map (c: c.plugins or []) configs);
            packages = builtins.concatLists (map (c: c.packages or []) configs);
            config = builtins.concatStringsSep "\n\n" (
              map (c: "-- ${c.name or "unknown"}\n${c.config or ""}") configs
            );
          };

          # Build Neovim with merged config
          neovim = pkgs.neovim.override {
            configure = {
              packages.myPlugins = {
                start = baseNeovim.plugins ++ merged.plugins ++ shellConfig.extraPlugins;
              };
              customRC = ''
                lua << EOF
                ${baseNeovim.config}

                -- Language-specific configurations
                ${merged.config}

                -- User extra config
                ${shellConfig.extraConfig}
                EOF
              '';
            };
          };
        in
        pkgs.mkShell {
          name = shellConfig.name;

          packages = [
            neovim
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.fzf
            pkgs.lazygit
            pkgs.delta
          ] ++ merged.packages ++ shellConfig.extraPackages;

          shellHook = ''
            export PS1='\[\033[1;34m\][${shellConfig.name}]\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] \$ '
            
            echo ""
            echo "╭────────────────────────────────────────╮"
            echo "│ 🚀 ${shellConfig.name}"
            echo "│ Languages: ${builtins.concatStringsSep ", " enabledNames}"
            echo "╰────────────────────────────────────────╯"
            echo ""
            ${shellConfig.shellHook}
          '';
        };

    in
    {
      options.devshells = {
        shells = lib.mkOption {
          type = lib.types.attrsOf shellSubmodule;
          default = {};
          description = "Devshell configurations";
        };

        # Expose internals for advanced usage
        lib = lib.mkOption {
          type = lib.types.attrs;
          readOnly = true;
          description = "Library functions for building devshells";
        };
      };

      config = {
        # Build devShells from shell configurations
        devShells = lib.mapAttrs buildShell config.devshells.shells;

        # Expose library for external use
        devshells.lib = {
          inherit baseNeovim languageModules availableLanguages;
          inherit buildShell;
          
          # Convenience function for simple language list
          mkDevShell = { name, languages ? [], extraPackages ? [], extraPlugins ? [], extraConfig ? "", shellHook ? "" }:
            buildShell name {
              inherit name extraPackages extraPlugins extraConfig shellHook;
              languages = lib.genAttrs languages (_: { enable = true; });
              extraLanguageModules = {};
            };
        };
      };
    }
  );
}
