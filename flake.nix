{
  description = "Composable development shells with shared Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # ============================================
        # NEOVIM CONFIGURATION SYSTEM
        # ============================================

        # Base Neovim plugins shared across all configurations
        baseNeovimPlugins = with pkgs.vimPlugins; [
          # Core functionality
          plenary-nvim
          nvim-web-devicons

          # Treesitter for syntax highlighting
          nvim-treesitter.withAllGrammars

          # LSP Support (using native vim.lsp.config in Neovim 0.11+)
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip
          fidget-nvim
          lsp-format-nvim

          # UI enhancements
          lualine-nvim
          bufferline-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          indent-blankline-nvim
          trouble-nvim
          todo-comments-nvim
          toggleterm-nvim

          # Editor enhancements
          nvim-autopairs
          comment-nvim
          gitsigns-nvim
          which-key-nvim
          nvim-surround
          better-escape-nvim

          # File explorer
          nvim-tree-lua

          # Theme
          cyberdream-nvim
        ];

        # Base Neovim Lua configuration
        baseNeovimConfig = ''
          -- ============================================
          -- BASIC SETTINGS
          -- ============================================
          vim.g.mapleader = " "
          vim.g.maplocalleader = " "

          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.wrap = false
          vim.opt.expandtab = true
          vim.opt.shiftwidth = 2
          vim.opt.tabstop = 2
          vim.opt.smartindent = true

          -- Search
          vim.opt.hlsearch = false
          vim.opt.incsearch = true
          vim.opt.ignorecase = true
          vim.opt.smartcase = true

          -- UI
          vim.opt.termguicolors = true
          vim.opt.scrolloff = 8
          vim.opt.signcolumn = "yes"
          vim.opt.cursorline = true
          vim.opt.colorcolumn = "88"

          -- Files
          vim.opt.swapfile = false
          vim.opt.backup = false
          vim.opt.undofile = true

          -- Performance
          vim.opt.updatetime = 50
          vim.opt.timeoutlen = 300

          -- Splits
          vim.opt.splitright = true
          vim.opt.splitbelow = true

          -- Mouse & clipboard
          vim.opt.mouse = "a"
          vim.opt.clipboard = "unnamedplus"

          -- ============================================
          -- CYBERDREAM THEME (transparent)
          -- ============================================
          require("cyberdream").setup({
            transparent = true,
            italic_comments = true,
            hide_fillchars = true,
            terminal_colors = true,
            theme = {
              saturation = 1,
              colors = {
                bg = "#16181a",
                bgAlt = "#1e2124",
                bgHighlight = "#3c4048",
                fg = "#ffffff",
                grey = "#7b8496",
                blue = "#5ea1ff",
                green = "#5eff6c",
                cyan = "#5ef1ff",
                red = "#ff6e5e",
                yellow = "#f1ff5e",
                magenta = "#ff5ef1",
                pink = "#ff5ea0",
                orange = "#ffbd5e",
                purple = "#bd5eff",
              },
              highlights = {
                Comment = { fg = "#696969", bg = "NONE", italic = true },
              },
            },
          })
          vim.cmd.colorscheme("cyberdream")

          -- ============================================
          -- LUALINE
          -- ============================================
          require("lualine").setup({
            options = {
              theme = "auto",
              component_separators = { left = "|", right = "|" },
              section_separators = { left = "", right = "" },
            },
            sections = {
              lualine_a = { "mode" },
              lualine_b = { "branch", "diff", "diagnostics" },
              lualine_c = { "filename" },
              lualine_x = { "encoding", "fileformat", "filetype" },
              lualine_y = { "progress" },
              lualine_z = { "location" },
            },
          })

          -- ============================================
          -- BUFFERLINE
          -- ============================================
          require("bufferline").setup({
            options = {
              mode = "buffers",
              diagnostics = "nvim_lsp",
              show_buffer_close_icons = true,
              show_close_icon = false,
              separator_style = "thin",
              always_show_bufferline = true,
              offsets = {
                { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", separator = true },
              },
            },
          })

          -- ============================================
          -- TELESCOPE
          -- ============================================
          local telescope = require("telescope")
          local actions = require("telescope.actions")
          telescope.setup({
            defaults = {
              layout_strategy = "horizontal",
              layout_config = {
                prompt_position = "top",
                preview_width = 0.55,
              },
              sorting_strategy = "ascending",
              file_ignore_patterns = {
                "node_modules", ".git/", "dist/", "build/", "__pycache__/", "%.pyc",
              },
              mappings = {
                i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                },
              },
            },
          })
          telescope.load_extension("fzf")

          vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
          vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
          vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
          vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
          vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
          vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })

          -- ============================================
          -- NVIM-TREE
          -- ============================================
          require("nvim-tree").setup({
            disable_netrw = true,
            hijack_cursor = true,
            update_focused_file = { enable = true },
            diagnostics = { enable = true },
            renderer = {
              highlight_git = true,
              icons = {
                show = { git = true, file = true, folder = true, folder_arrow = true },
              },
            },
          })
          vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

          -- ============================================
          -- GITSIGNS
          -- ============================================
          require("gitsigns").setup({
            current_line_blame = true,
            current_line_blame_opts = { delay = 300 },
            signs = {
              add = { text = "│" },
              change = { text = "│" },
              delete = { text = "_" },
              topdelete = { text = "‾" },
              changedelete = { text = "~" },
              untracked = { text = "┆" },
            },
            on_attach = function(bufnr)
              local gs = package.loaded.gitsigns
              local opts = { buffer = bufnr }
              vim.keymap.set("n", "]c", gs.next_hunk, opts)
              vim.keymap.set("n", "[c", gs.prev_hunk, opts)
              vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
              vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
              vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
              vim.keymap.set("n", "<leader>hb", gs.blame_line, opts)
            end,
          })

          -- ============================================
          -- EDITOR PLUGINS
          -- ============================================
          require("nvim-autopairs").setup({
            check_ts = true,
            ts_config = {
              javascript = { "template_string" },
              typescript = { "template_string" },
            },
          })

          require("Comment").setup({
            padding = true,
            sticky = true,
            toggler = { line = "gcc", block = "gbc" },
          })

          require("nvim-surround").setup({})

          require("better_escape").setup({
            timeout = 200,
            default_mappings = false,
            mappings = {
              i = {
                j = {
                  k = "<Esc>",
                  j = "<Esc>",
                },
              },
            },
          })

          require("which-key").setup({
            delay = 500,
            icons = { mappings = true },
          })

          require("ibl").setup({
            scope = { enabled = true, show_start = true, show_end = false },
            indent = { char = "│" },
          })

          require("trouble").setup({ use_diagnostic_signs = true })
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })

          require("todo-comments").setup({
            keywords = {
              FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
              TODO = { icon = " ", color = "info" },
              HACK = { icon = " ", color = "warning" },
              WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
              PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
              NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            },
          })

          -- ============================================
          -- TREESITTER
          -- ============================================
          require("nvim-treesitter").setup({
            highlight = { enable = true },
            indent = { enable = true },
          })

          -- Incremental selection
          vim.keymap.set("n", "<C-space>", function()
            require("nvim-treesitter.incremental_selection").init_selection()
          end, { desc = "Init treesitter selection" })
          vim.keymap.set("v", "<C-space>", function()
            require("nvim-treesitter.incremental_selection").node_incremental()
          end, { desc = "Increment treesitter selection" })
          vim.keymap.set("v", "<bs>", function()
            require("nvim-treesitter.incremental_selection").node_decremental()
          end, { desc = "Decrement treesitter selection" })

          -- ============================================
          -- LSP & COMPLETION
          -- ============================================
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          local cmp = require("cmp")
          local luasnip = require("luasnip")

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { "i", "s" }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
            }, {
              { name = "buffer" },
              { name = "path" },
            }),
          })

          -- LSP keymaps
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local opts = { buffer = args.buf }
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
              vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
              vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
              vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
              vim.keymap.set("n", "<leader>f", function()
                vim.lsp.buf.format({ async = true })
              end, opts)
              vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
              vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
              vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
            end,
          })

          -- ============================================
          -- ADDITIONAL KEYMAPS
          -- ============================================
          -- Buffer navigation
          vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
          vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
          vim.keymap.set("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

          -- Window navigation
          vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
          vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
          vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
          vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

          -- Resize windows
          vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
          vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
          vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
          vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

          -- Move lines
          vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
          vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

          -- Keep cursor centered
          vim.keymap.set("n", "<C-d>", "<C-d>zz")
          vim.keymap.set("n", "<C-u>", "<C-u>zz")
          vim.keymap.set("n", "n", "nzzzv")
          vim.keymap.set("n", "N", "Nzzzv")

          -- Clear search highlight
          vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

          -- Save file
          vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

          -- Export capabilities for language configs
          _G.lsp_capabilities = capabilities
        '';

        # ============================================
        # LANGUAGE-SPECIFIC CONFIGURATIONS
        # ============================================

        languageConfigs = {
          python = {
            extraPlugins = with pkgs.vimPlugins; [ ];
            extraPackages = with pkgs; [
              python3
              ruff
              pyright
              black
              isort
            ];
            extraConfig = ''
              -- Python LSP (Pyright) using native vim.lsp.config
              vim.lsp.config.pyright = {
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
              }
              vim.lsp.enable("pyright")

              -- Ruff for linting/formatting
              vim.lsp.config.ruff = {
                cmd = { "ruff", "server" },
                filetypes = { "python" },
                root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
              }
              vim.lsp.enable("ruff")
            '';
          };

          typescript = {
            extraPlugins = with pkgs.vimPlugins; [ ];
            extraPackages = with pkgs; [
              nodejs
              nodePackages.typescript
              nodePackages.typescript-language-server
              nodePackages.prettier
              biome
            ];
            extraConfig = ''
              -- TypeScript LSP using native vim.lsp.config
              vim.lsp.config.ts_ls = {
                cmd = { "typescript-language-server", "--stdio" },
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
              }
              vim.lsp.enable("ts_ls")
            '';
          };

          rust = {
            extraPlugins = with pkgs.vimPlugins; [
              crates-nvim
            ];
            extraPackages = with pkgs; [
              rustc
              cargo
              rust-analyzer
              rustfmt
              clippy
            ];
            extraConfig = ''
              -- Rust LSP using native vim.lsp.config
              vim.lsp.config.rust_analyzer = {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml", "rust-project.json", ".git" },
                settings = {
                  ["rust-analyzer"] = {
                    checkOnSave = { command = "clippy" },
                    cargo = { allFeatures = true },
                  },
                },
              }
              vim.lsp.enable("rust_analyzer")

              -- Crates.nvim for Cargo.toml
              require("crates").setup({})
            '';
          };

          csharp = {
            extraPlugins = with pkgs.vimPlugins; [ ];
            extraPackages = with pkgs; [
              dotnet-sdk_8
              omnisharp-roslyn
              csharpier
            ];
            extraConfig = ''
              -- C# / .NET using native vim.lsp.config
              vim.lsp.config.omnisharp = {
                cmd = { "${pkgs.omnisharp-roslyn}/bin/OmniSharp", "--languageserver" },
                filetypes = { "cs" },
                root_markers = { "*.sln", "*.csproj", ".git" },
              }
              vim.lsp.enable("omnisharp")
            '';
          };

          go = {
            extraPlugins = with pkgs.vimPlugins; [ ];
            extraPackages = with pkgs; [
              go
              gopls
              gotools
              golangci-lint
            ];
            extraConfig = ''
              -- Go using native vim.lsp.config
              vim.lsp.config.gopls = {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_markers = { "go.mod", "go.work", ".git" },
              }
              vim.lsp.enable("gopls")
            '';
          };

          nix = {
            extraPlugins = with pkgs.vimPlugins; [ ];
            extraPackages = with pkgs; [
              nil
              nixpkgs-fmt
            ];
            extraConfig = ''
              -- Nix using native vim.lsp.config
              vim.lsp.config.nil_ls = {
                cmd = { "nil" },
                filetypes = { "nix" },
                root_markers = { "flake.nix", ".git" },
                settings = {
                  ["nil"] = {
                    formatting = { command = { "nixpkgs-fmt" } },
                  },
                },
              }
              vim.lsp.enable("nil_ls")
            '';
          };

          lua = {
            extraPlugins = with pkgs.vimPlugins; [
              lazydev-nvim
            ];
            extraPackages = with pkgs; [
              lua-language-server
              stylua
            ];
            extraConfig = ''
              -- Lazydev for Neovim Lua development
              require("lazydev").setup({})

              -- Lua using native vim.lsp.config
              vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
                settings = {
                  Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                  },
                },
              }
              vim.lsp.enable("lua_ls")
            '';
          };
        };

        # ============================================
        # SHELL BUILDER FUNCTION
        # ============================================

        # Build a customized Neovim with specific language support
        mkNeovim = { languages ? [ ] }:
          let
            selectedConfigs = map (l: languageConfigs.${l}) languages;
            allExtraPlugins = builtins.concatLists (map (c: c.extraPlugins) selectedConfigs);
            allExtraConfig = builtins.concatStringsSep "\n" (map (c: c.extraConfig) selectedConfigs);
          in
          pkgs.neovim.override {
            configure = {
              packages.myPlugins = {
                start = baseNeovimPlugins ++ allExtraPlugins;
              };
              customRC = ''
                lua << EOF
                ${baseNeovimConfig}
                ${allExtraConfig}
                EOF
              '';
            };
          };

        # Build a development shell with Neovim and language tooling
        mkDevShell = { name, languages, extraPackages ? [ ] }:
          let
            selectedConfigs = map (l: languageConfigs.${l}) languages;
            allExtraPackages = builtins.concatLists (map (c: c.extraPackages) selectedConfigs);
            neovim = mkNeovim { inherit languages; };
          in
          pkgs.mkShell {
            inherit name;
            packages = [
              neovim
              pkgs.git
              pkgs.ripgrep
              pkgs.fd
              pkgs.fzf
            ] ++ allExtraPackages ++ extraPackages;

            shellHook = ''
              export PS1='\[\033[1;34m\][${name}]\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] \$ '
              
              echo "🚀 ${name} development shell"
              echo "Languages: ${builtins.concatStringsSep ", " languages}"
              echo ""
              echo "Run 'nvim' to start editing with full LSP support"
            '';
          };

      in
      {
        # ============================================
        # EXPORTED DEVELOPMENT SHELLS
        # ============================================

        devShells = {
          # Default shell with all languages (might be heavy)
          default = mkDevShell {
            name = "full-stack";
            languages = [ "typescript" "python" "nix" ];
          };

          # Single-language shells
          python = mkDevShell {
            name = "python-dev";
            languages = [ "python" "nix" ];
          };

          typescript = mkDevShell {
            name = "typescript-dev";
            languages = [ "typescript" "nix" ];
          };

          rust = mkDevShell {
            name = "rust-dev";
            languages = [ "rust" "nix" ];
          };

          csharp = mkDevShell {
            name = "csharp-dev";
            languages = [ "csharp" "nix" ];
          };

          go = mkDevShell {
            name = "go-dev";
            languages = [ "go" "nix" ];
          };

          lua = mkDevShell {
            name = "lua-dev";
            languages = [ "lua" "nix" ];
          };

          nix = mkDevShell {
            name = "nix-dev";
            languages = [ "nix" ];
          };

          # Combined shells for common stacks
          fullstack = mkDevShell {
            name = "fullstack-dev";
            languages = [ "typescript" "python" "nix" ];
            extraPackages = with pkgs; [ docker-compose postgresql ];
          };

          webdev = mkDevShell {
            name = "webdev";
            languages = [ "typescript" "nix" ];
            extraPackages = with pkgs; [ nodePackages.pnpm ];
          };
        };

        # ============================================
        # LIBRARY EXPORTS FOR COMPOSITION
        # ============================================

        lib = {
          inherit mkDevShell mkNeovim languageConfigs baseNeovimPlugins baseNeovimConfig;
        };
      }
    );
}
