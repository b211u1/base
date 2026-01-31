# neovim/languages/rust.nix
{ pkgs }:

{
  name = "rust";

  plugins = with pkgs.vimPlugins; [
    rustaceanvim
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

    -- Rust (rustaceanvim - successor to rust-tools)
    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
      },
      server = {
        capabilities = _G.lsp_capabilities,
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
      },
    }

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
        vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", opts)
        vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp debuggables<cr>", opts)
        vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<cr>", opts)
        vim.keymap.set("n", "<leader>rc", "<cmd>RustLsp openCargo<cr>", opts)
        vim.keymap.set("n", "<leader>rp", "<cmd>RustLsp parentModule<cr>", opts)
        vim.keymap.set("n", "J", "<cmd>RustLsp joinLines<cr>", opts)
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
