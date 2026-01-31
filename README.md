# Composable Nix Development Shells with Shared Neovim Configuration

A Nix flakes-based system for creating development shells that share a common Neovim configuration while allowing language-specific extensions.

## Features

- **Cyberdream theme** with transparent background and custom color palette
- **Bufferline** for buffer tabs with LSP diagnostics
- **Language-specific extensions** that add LSPs, formatters, and tooling
- **Composable shells** - combine multiple languages in a single shell
- **Fully declarative** - all configuration is in Nix
- **Portable** - works on any system with Nix flakes enabled

## Base Neovim Setup

The configuration includes:
- **Theme**: Cyberdream with transparency, vibrant colors, gray italic comments
- **UI**: Lualine, Bufferline, NvimTree, Telescope, indent guides
- **Editor**: nvim-autopairs, Comment.nvim, nvim-surround, better-escape (jk/jj)
- **Git**: Gitsigns with current line blame
- **LSP/Completion**: nvim-lspconfig, nvim-cmp, luasnip
- **Diagnostics**: Trouble, todo-comments
- **Navigation**: which-key for keybinding hints

## Quick Start

```bash
# Enter a TypeScript development shell
nix develop github:yourusername/devshells#typescript

# Enter a Python development shell
nix develop github:yourusername/devshells#python

# Enter a C# development shell
nix develop github:yourusername/devshells#csharp

# Enter a full-stack shell (TypeScript + Python)
nix develop github:yourusername/devshells#fullstack
```

## Project Structure

```
.
├── flake.nix                 # Single-file version (simpler but may lag behind)
└── modular/                  # RECOMMENDED - modular version with separate files
    ├── flake.nix             # Modular version entry point
    └── neovim/
        ├── base.nix          # Base Neovim configuration (your full config)
        └── languages/
            ├── python.nix
            ├── typescript.nix
            ├── csharp.nix
            ├── rust.nix
            └── nix.nix
```

**Recommendation**: Use the `modular/` version for the most complete and maintainable setup.

## Usage in Your Project

### Option 1: Use Pre-built Shells Directly

Create a `flake.nix` in your project:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshells.url = "github:yourusername/devshells";
  };

  outputs = { self, nixpkgs, devshells, ... }:
    let
      system = "x86_64-linux"; # or "aarch64-darwin", etc.
    in {
      devShells.${system}.default = devshells.devShells.${system}.typescript;
    };
}
```

### Option 2: Create Custom Shells

Use the `mkDevShell` function to create customized shells:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshells.url = "github:yourusername/devshells";
  };

  outputs = { self, nixpkgs, flake-utils, devshells }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (devshells.lib.${system}) mkDevShell;
      in {
        devShells.default = mkDevShell {
          name = "my-project";
          languages = [ "typescript" "python" ];
          extraPackages = with pkgs; [
            awscli2
            docker-compose
            terraform
          ];
          shellHook = ''
            echo "Welcome to my project!"
          '';
        };
      }
    );
}
```

### Option 3: Add Custom Languages

Extend the language configurations:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshells.url = "github:yourusername/devshells";
  };

  outputs = { self, nixpkgs, flake-utils, devshells }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (devshells.lib.${system}) mkDevShell addLanguage;

        # Add a new language
        extendedConfigs = addLanguage "terraform" {
          name = "terraform";
          plugins = [];
          packages = with pkgs; [ terraform terraform-ls tflint ];
          config = ''
            require("lspconfig").terraformls.setup({
              capabilities = _G.lsp_capabilities,
            })
          '';
        };
      in {
        devShells.default = mkDevShell {
          name = "infra-project";
          languages = [ "terraform" "nix" ];
        };
      }
    );
}
```

## Available Shells

| Shell | Languages | Description |
|-------|-----------|-------------|
| `default` | nix | Minimal shell with Nix support |
| `python` | python, nix | Python development with Pyright + Ruff |
| `typescript` | typescript, nix | TypeScript/JS with typescript-tools |
| `csharp` | csharp, nix | .NET development with OmniSharp |
| `fullstack` | typescript, python, nix | Full-stack web development |
| `dotnet-fullstack` | csharp, typescript, nix | .NET + frontend development |

## Base Neovim Setup

The configuration includes everything from your personal setup:

### Options
- `guifont = "MartianMono Nerd Font:h12"`
- Line numbers (relative), no wrap, colorcolumn 88
- Smart search (ignorecase + smartcase)
- Split right/below, scrolloff 8
- No swap/backup, undofile enabled

### Theme & UI
- **Cyberdream** with transparent background
- Custom color palette (blue, green, cyan, red, yellow, magenta, pink, orange, purple)
- Gray italic comments (#696969)
- **Lualine** with your section config
- **Bufferline** - full config with icons, indicators, hover, diagnostics

### Diagnostics
- Custom signs: Error  , Warn  , Hint 󰌵 , Info  
- Virtual text with ● prefix
- Rounded borders on hover/signature help

### Plugins
- **LSP**: nvim-lspconfig, fidget (progress), lsp-format
- **Completion**: nvim-cmp with priorities, icons, rounded borders
- **Snippets**: luasnip + friendly-snippets
- **Syntax**: nvim-treesitter (all grammars)
- **Navigation**: telescope.nvim, nvim-tree (with filters)
- **Editing**: nvim-autopairs, Comment.nvim, nvim-surround, better-escape
- **Git**: gitsigns.nvim with current line blame
- **Terminal**: toggleterm (`<C-\>` to toggle)
- **Diagnostics**: trouble.nvim (auto-close), todo-comments
- **UI**: which-key, indent-blankline

### Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | n | Leader key |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fh` | n | Help tags |
| `<leader>fr` | n | Recent files |
| `<leader>fd` | n | Diagnostics |
| `<leader>e` | n | Toggle file explorer |
| `<leader>xx` | n | Toggle Trouble diagnostics |
| `gd` | n | Go to definition |
| `gr` | n | Find references |
| `K` | n | Hover documentation |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n | Code actions |
| `<leader>f` | n | Format buffer |
| `<leader>d` | n | Show diagnostic float |
| `[d` / `]d` | n | Prev/next diagnostic |
| `[c` / `]c` | n | Prev/next git hunk |
| `<leader>hs` | n | Stage hunk |
| `<leader>hr` | n | Reset hunk |
| `<leader>hp` | n | Preview hunk |
| `<leader>hb` | n | Blame line |
| `<S-h>` / `<S-l>` | n | Prev/next buffer |
| `<leader>x` | n | Close buffer |
| `<leader>w` | n | Save file |
| `<C-h/j/k/l>` | n | Window navigation |
| `jk` or `jj` | i | Exit insert mode |
| `gcc` | n | Toggle line comment |
| `gc` | v | Toggle selection comment |

## Language-Specific Features

### Python
- LSP: Pyright
- Linting/Formatting: Ruff
- Packages: python3, black, isort, debugpy

### TypeScript
- LSP: typescript-tools.nvim
- Formatting: Prettier, Biome
- Extra commands: `<leader>to` organize imports, `<leader>ta` add missing imports

### C#
- LSP: OmniSharp
- Formatting: CSharpier
- Enhanced go-to-definition for decompiled sources
- .NET SDK 8

### Nix
- LSP: nil
- Formatting: nixpkgs-fmt
- Linting: statix, deadnix

## Customizing the Base Configuration

You can override parts of the base configuration:

```nix
let
  inherit (devshells.lib.${system}) baseNeovim mkNeovim;

  customNeovim = mkNeovim {
    languages = [ "typescript" ];
    # The base config is always included
    # Language configs are added on top
  };
in
# Use customNeovim in your shell
```

## Tips

### Use direnv for automatic activation

Create `.envrc` in your project:

```bash
use flake
```

Then run `direnv allow`.

### Pin the flake input

For reproducible builds, use a specific revision:

```nix
devshells.url = "github:yourusername/devshells?rev=abc123...";
```

### Local development of the devshells flake

```bash
# Clone the repo
git clone https://github.com/yourusername/devshells
cd devshells

# Test a shell
nix develop .#typescript

# Or test the modular version
nix develop ./modular#typescript
```

## Adding New Languages

1. Create a new file in `neovim/languages/`:

```nix
# neovim/languages/rust.nix
{ pkgs }:

{
  name = "rust";

  plugins = with pkgs.vimPlugins; [
    rustaceanvim
    crates-nvim
    friendly-snippets  # Include if you want VSCode snippets for this language
  ];

  packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
  ];

  config = ''
    -- Load Rust snippets (optional)
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "rust" }
    })

    -- Custom snippets (optional)
    local ls = require("luasnip")
    local s = ls.snippet
    -- ... add custom snippets here

    -- LSP setup
    vim.g.rustaceanvim = {
      server = {
        capabilities = _G.lsp_capabilities,
      },
    }
    require("crates").setup({})
  '';
}
```

2. Import it in `flake.nix`:

```nix
languageConfigs = {
  # ... existing configs
  rust = import ./neovim/languages/rust.nix { inherit pkgs; };
};
```

3. Add a shell:

```nix
devShells = {
  # ... existing shells
  rust = mkDevShell {
    name = "rust-dev";
    languages = [ "rust" "nix" ];
  };
};
```

## Architecture Notes

The base configuration provides **language-agnostic infrastructure**:
- Editor settings, theme, UI plugins
- LSP client setup (but no language servers)
- Completion framework (nvim-cmp + luasnip)
- Keymaps for navigation, editing, LSP interaction

Language modules add **language-specific elements**:
- LSP servers and their configuration
- Formatters and linters
- Snippets (via `friendly-snippets` or custom)
- Language-specific keymaps and autocmds
- File type settings (indent, colorcolumn, etc.)

## License

MIT
