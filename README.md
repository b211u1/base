# devshells

Composable Nix development shells with a fully-configured Neovim.

The base provides editor infrastructure — Cyberdream theme, completion, navigation, keybindings — without language specifics. Language modules add LSPs, formatters, and snippets. Compose what you need.

## Quick Start

```bash
nix develop                   # Nix only (default)
nix develop .#python          # Python + Pyright + Ruff
nix develop .#typescript      # TypeScript + ts_ls + Biome
nix develop .#fullstack       # Python + TypeScript + tooling
```

## Use in Your Project

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshells.url = "github:b211u1/base/flake-parts";
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

## Custom Language Modules

Add your own language modules without forking via `extraLanguageModules`:

```nix
devshells.shells.default = {
  name = "ai-coding";
  languages = {
    python.enable = true;
    claude.enable = true;
  };

  extraLanguageModules = {
    claude = {
      name = "claude";
      plugins = with pkgs.vimPlugins; [ ];
      packages = with pkgs; [ ];
      config = ''
        vim.keymap.set("n", "<leader>cc", "<cmd>TermExec cmd='claude'<cr>")
      '';
    };
  };
};
```

## Shell Options

Each shell accepts the following options:

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Shell name (shown in PS1 prompt) |
| `languages.<name>.enable` | bool | Enable a language module |
| `extraLanguageModules` | attrset | Custom language modules |
| `extraPackages` | list | Additional packages |
| `extraPlugins` | list | Additional Neovim plugins |
| `extraConfig` | string | Additional Lua config |
| `shellHook` | string | Extra shell hook |

## Design

- **Base is language-agnostic** — Cyberdream theme, nvim-cmp, Telescope, Treesitter, toggleterm, gitsigns, which-key, nvim-surround, bufferline, lualine, trouble, todo-comments
- **Languages are additive** — Each module brings its LSP, formatter, tooling, snippets, and filetype settings
- **Native Neovim 0.11+** — Uses `vim.lsp.config` / `vim.lsp.enable` directly, no lspconfig wrapper
- **Flake-parts module** — Import via `flakeModules.default` in other flakes, compose freely

## Available Languages

| Language | LSP | Formatter | Extras |
|----------|-----|-----------|--------|
| `python` | Pyright, Ruff | Black, isort | friendly-snippets, custom pytest snippets, debugpy |
| `typescript` | ts_ls, Biome | Prettier | JS/TS/JSX/TSX support |
| `csharp` | OmniSharp | CSharpier | .NET SDK 8, netcoredbg |
| `rust` | rust-analyzer | rustfmt | clippy, crates.nvim |
| `nix` | nil | nixpkgs-fmt | statix, deadnix |

## Pre-built Shells

| Shell | Languages | Extra Packages |
|-------|-----------|----------------|
| `default` | nix | — |
| `python` | python, nix | — |
| `typescript` | typescript, nix | — |
| `csharp` | csharp, nix | — |
| `rust` | rust, nix | — |
| `fullstack` | typescript, python, nix | docker-compose, postgresql, redis |
| `dotnet-fullstack` | csharp, typescript, nix | docker-compose, azure-cli |

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

It's automatically discovered by `neovim/languages/default.nix` and available as `languages.go.enable = true`.

## Keymaps

### Navigation

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fd` | Diagnostics |
| `<leader>fs` | Document symbols |
| `<leader>e` | Toggle file explorer |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>x` | Close buffer |
| `<C-h/j/k/l>` | Navigate windows |
| `<C-Up/Down/Left/Right>` | Resize windows |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | References |
| `gt` | Type definition |
| `K` | Hover docs |
| `<C-k>` | Signature help |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>fm` | Format |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>vd` | Diagnostic float |

### Git

| Key | Action |
|-----|--------|
| `<leader>gb` | Blame line |
| `<leader>gp` | Preview hunk |
| `<leader>gr` | Reset hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `]c` / `[c` | Next / previous hunk |

### Tools

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle terminal |
| `<leader>tt` | Toggle diagnostics (Trouble) |
| `<leader>td` | Find TODOs |
| `jk` / `jj` | Exit insert mode |

### Visual Mode

| Key | Action |
|-----|--------|
| `<` / `>` | Indent and reselect |
| `J` / `K` | Move lines up / down |

## Core Packages

Every shell includes: git, ripgrep, fd, fzf, lazygit, delta.

## Structure

```
├── flake.nix                 # Flake-parts entry point
├── modules/
│   └── devshell.nix          # Exportable flake-parts module
└── neovim/
    ├── base.nix              # Language-agnostic Neovim config
    └── languages/
        ├── default.nix       # Auto-discovers sibling modules
        ├── python.nix
        ├── typescript.nix
        ├── csharp.nix
        ├── rust.nix
        └── nix.nix
```

## License

MIT
