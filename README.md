# devshells

Composable Nix development shells with a fully-configured Neovim.

The base provides editor infrastructure — theme, completion, navigation, keybindings — without language specifics. Language modules add LSPs, formatters, and snippets. Compose what you need.

## Quick Start

```bash
# Clone and enter a shell
cd devshells/modular
nix develop .#python      # Python + Pyright + Ruff
nix develop .#typescript  # TypeScript + ts_ls
nix develop .#fullstack   # Python + TypeScript + tooling
```

## Use in Your Project

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshells.url = "github:yourusername/devshells";
  };

  outputs = inputs@{ flake-parts, devshells, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      
      imports = [ devshells.flakeModules.default ];

      perSystem = { pkgs, ... }: {
        devshells.shells.default = {
          name = "my-project";
          languages = {
            python.enable = true;
            typescript.enable = true;
            nix.enable = true;
          };
          extraPackages = with pkgs; [ docker-compose ];
        };
      };
    };
}
```

## Add Custom Language Modules

You can add your own language modules without forking:

```nix
devshells.shells.default = {
  name = "ai-coding";
  languages = {
    python.enable = true;
    claude.enable = true;  # Your custom module
  };
  
  extraLanguageModules = {
    claude = {
      name = "claude";
      plugins = with pkgs.vimPlugins; [ ];
      packages = with pkgs; [ /* claude-code */ ];
      config = ''
        -- Your Neovim config for this language
        vim.keymap.set("n", "<leader>cc", "<cmd>TermExec cmd='claude'<cr>")
      '';
    };
  };
};
```

## Design

- **Base is language-agnostic** — Cyberdream theme, nvim-cmp, Telescope, Treesitter, toggleterm, gitsigns
- **Languages are additive** — Each module brings LSP, tooling, snippets, filetype settings
- **Native Neovim 0.11+** — Uses `vim.lsp.config` directly
- **Flake-parts module** — Import in other flakes, compose freely

## Available Languages

| Language | LSP | Formatter | Extras |
|----------|-----|-----------|--------|
| `python` | Pyright | Ruff | pytest snippets |
| `typescript` | ts_ls | Biome | JS/TS/React |
| `csharp` | OmniSharp | CSharpier | .NET SDK |
| `rust` | rust-analyzer | rustfmt | crates.nvim |
| `nix` | nil | nixpkgs-fmt | statix, deadnix |

## Pre-built Shells

| Shell | Languages |
|-------|-----------|
| `default` | nix |
| `python` | python, nix |
| `typescript` | typescript, nix |
| `csharp` | csharp, nix |
| `rust` | rust, nix |
| `fullstack` | typescript, python, nix |
| `dotnet-fullstack` | csharp, typescript, nix |

## Adding a New Language

Create `neovim/languages/go.nix`:

```nix
{ pkgs }:

{
  name = "go";

  plugins = with pkgs.vimPlugins; [
    friendly-snippets
  ];

  packages = with pkgs; [
    go
    gopls
    gotools
    golangci-lint
  ];

  config = ''
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "go" }
    })

    vim.lsp.config.gopls = {
      cmd = { "gopls" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_markers = { "go.mod", "go.work", ".git" },
    }
    vim.lsp.enable("gopls")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "go",
      callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = false
      end,
    })
  '';
}
```

It's automatically discovered and available as `languages.go.enable = true`.

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e` | File explorer |
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `<leader>x` | Close buffer |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>fm` | Format |
| `<C-\>` | Toggle terminal |
| `jk` / `jj` | Exit insert mode |

## Structure

```
modular/
├── flake.nix                 # Flake-parts entry point
├── modules/
│   └── devshell.nix          # The flake-parts module
└── neovim/
    ├── base.nix              # Language-agnostic Neovim config
    └── languages/
        ├── default.nix       # Auto-imports siblings
        ├── python.nix
        ├── typescript.nix
        ├── csharp.nix
        ├── rust.nix
        └── nix.nix
```

## License

MIT
