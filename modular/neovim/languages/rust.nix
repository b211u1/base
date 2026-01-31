# neovim/languages/rust.nix
{ pkgs }:

{
  name = "rust";

  plugins = with pkgs.vimPlugins; [
    crates-nvim
    friendly-snippets  # VSCode-style snippets for Rust
  ];

  packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
    cargo-watch
    cargo-edit
    cargo-expand
  ];

  config = ''
    -- Load Rust snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "rust" }
    })

    -- Rust LSP (rust-analyzer) using native vim.lsp.config
    vim.lsp.config.rust_analyzer = {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_markers = { "Cargo.toml", "rust-project.json", ".git" },
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
          cargo = {
            allFeatures = true,
          },
          procMacro = {
            enable = true,
          },
        },
      },
    }
    vim.lsp.enable("rust_analyzer")

    -- Crates.nvim for Cargo.toml management
    require("crates").setup({
      popup = {
        autofocus = true,
      },
    })

    -- Rust-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        local opts = { buffer = true }
        -- Use LSP code actions for rust-analyzer commands
        vim.keymap.set("n", "<leader>rc", function()
          vim.cmd("edit Cargo.toml")
        end, { buffer = true, desc = "Open Cargo.toml" })
      end,
    })

    -- Crates.nvim keymaps for Cargo.toml
    vim.api.nvim_create_autocmd("BufRead", {
      pattern = "Cargo.toml",
      callback = function()
        local crates = require("crates")
        local opts = { buffer = true }
        vim.keymap.set("n", "<leader>ct", crates.toggle, opts)
        vim.keymap.set("n", "<leader>cr", crates.reload, opts)
        vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, opts)
        vim.keymap.set("n", "<leader>cf", crates.show_features_popup, opts)
        vim.keymap.set("n", "<leader>cu", crates.update_crate, opts)
        vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, opts)
      end,
    })
  '';
}
