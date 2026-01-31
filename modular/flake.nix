{
  description = "Composable development shells with modular Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Import base Neovim configuration
        baseNeovim = import ./neovim/base.nix { inherit pkgs; };

        # Import language configurations
        languageConfigs = {
          python = import ./neovim/languages/python.nix { inherit pkgs; };
          typescript = import ./neovim/languages/typescript.nix { inherit pkgs; };
          csharp = import ./neovim/languages/csharp.nix { inherit pkgs; };
          rust = import ./neovim/languages/rust.nix { inherit pkgs; };
          nix = import ./neovim/languages/nix.nix { inherit pkgs; };
        };

        # ============================================
        # BUILDER FUNCTIONS
        # ============================================

        # Merge language configurations
        mergeLanguageConfigs = languages:
          let
            configs = map (l: languageConfigs.${l}) languages;
          in
          {
            plugins = builtins.concatLists (map (c: c.plugins) configs);
            packages = builtins.concatLists (map (c: c.packages) configs);
            config = builtins.concatStringsSep "\n\n" (map (c: "-- ${c.name}\n${c.config}") configs);
          };

        # Build a customized Neovim with specific language support
        mkNeovim = { languages ? [ ] }:
          let
            merged = mergeLanguageConfigs languages;
          in
          pkgs.neovim.override {
            configure = {
              packages.myPlugins = {
                start = baseNeovim.plugins ++ merged.plugins;
              };
              customRC = ''
                lua << EOF
                ${baseNeovim.config}

                -- Language-specific configurations
                ${merged.config}
                EOF
              '';
            };
          };

        # Build a development shell with Neovim and language tooling
        mkDevShell =
          { name
          , languages
          , extraPackages ? [ ]
          , shellHook ? ""
          }:
          let
            merged = mergeLanguageConfigs languages;
            neovim = mkNeovim { inherit languages; };
          in
          pkgs.mkShell {
            inherit name;

            packages = [
              neovim
              # Core tools
              pkgs.git
              pkgs.ripgrep
              pkgs.fd
              pkgs.fzf
              pkgs.lazygit
              pkgs.delta
            ] ++ merged.packages ++ extraPackages;

            shellHook = ''
              export PS1='\[\033[1;34m\][${name}]\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] \$ '
              
              echo ""
              echo "╭────────────────────────────────────────╮"
              echo "│ 🚀 ${name}"
              echo "│ Languages: ${builtins.concatStringsSep ", " languages}"
              echo "╰────────────────────────────────────────╯"
              echo ""
              ${shellHook}
            '';
          };

        # ============================================
        # LIBRARY FOR EXTERNAL COMPOSITION
        # ============================================

        lib = {
          inherit mkDevShell mkNeovim mergeLanguageConfigs;
          inherit languageConfigs baseNeovim;

          # Helper to add a new language configuration
          addLanguage = name: config: languageConfigs // { ${name} = config; };

          # Helper to extend an existing language configuration
          extendLanguage = name: extension:
            let
              original = languageConfigs.${name};
            in
            languageConfigs // {
              ${name} = {
                inherit name;
                plugins = original.plugins ++ (extension.plugins or [ ]);
                packages = original.packages ++ (extension.packages or [ ]);
                config = original.config + "\n" + (extension.config or "");
              };
            };
        };

      in
      {
        # ============================================
        # DEVELOPMENT SHELLS
        # ============================================

        devShells = {
          default = mkDevShell {
            name = "default-dev";
            languages = [ "nix" ];
          };

          python = mkDevShell {
            name = "python-dev";
            languages = [ "python" "nix" ];
          };

          typescript = mkDevShell {
            name = "typescript-dev";
            languages = [ "typescript" "nix" ];
          };

          csharp = mkDevShell {
            name = "csharp-dev";
            languages = [ "csharp" "nix" ];
          };

          rust = mkDevShell {
            name = "rust-dev";
            languages = [ "rust" "nix" ];
          };

          fullstack = mkDevShell {
            name = "fullstack-dev";
            languages = [ "typescript" "python" "nix" ];
            extraPackages = with pkgs; [
              docker-compose
              postgresql
              redis
            ];
          };

          dotnet-fullstack = mkDevShell {
            name = "dotnet-fullstack";
            languages = [ "csharp" "typescript" "nix" ];
            extraPackages = with pkgs; [
              docker-compose
              azure-cli
            ];
          };
        };

        # Export library for composition
        inherit lib;
      }
    );
}
