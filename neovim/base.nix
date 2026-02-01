# neovim/base.nix
# Base Neovim configuration - C's personal setup
# Cyberdream theme with transparency, bufferline, and comprehensive plugins
{ pkgs }:

{
  plugins = with pkgs.vimPlugins; [
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

    # UI enhancements
    lualine-nvim
    bufferline-nvim
    telescope-nvim
    telescope-fzf-native-nvim
    indent-blankline-nvim
    trouble-nvim
    todo-comments-nvim

    # Editor enhancements
    nvim-autopairs
    comment-nvim
    gitsigns-nvim
    which-key-nvim
    nvim-surround
    better-escape-nvim
    toggleterm-nvim

    # File explorer
    nvim-tree-lua

    # Theme
    cyberdream-nvim
  ];

  config = ''
    -- ============================================
    -- BASIC SETTINGS
    -- ============================================
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.wrap = false
    vim.opt.guifont = "MartianMono Nerd Font:h12"
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
    -- DIAGNOSTIC SIGNS & CONFIG
    -- ============================================
    vim.diagnostic.config({
      virtual_text = { prefix = "●", spacing = 4 },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { focusable = false, style = "minimal", border = "rounded", source = "always" },
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

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
    -- BUFFERLINE (full config)
    -- ============================================
    require("bufferline").setup({
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        indicator = { style = "icon", icon = "▎" },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 20,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          { filetype = "NvimTree", text = "File Explorer", text_align = "center", separator = true },
        },
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = { enabled = true, delay = 200, reveal = { "close" } },
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
          ".pytest_cache/", ".mypy_cache/", ".ruff_cache/", "%.egg-info/",
          ".venv/", "venv/",
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
    vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })

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
    -- TOGGLETERM
    -- ============================================
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      shade_terminals = false,
      close_on_exit = true,
    })

    -- Terminal mode keymaps
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower window" })
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper window" })
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })

    -- Git keymaps (separate from gitsigns on_attach for convenience)
    vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame line", silent = true })
    vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk", silent = true })
    vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk", silent = true })

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

    require("trouble").setup({
      use_diagnostic_signs = true,
      auto_close = true,
    })
    vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics", silent = true })

    require("todo-comments").setup({
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      },
    })
    vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>", { desc = "Find todos", silent = true })

    -- ============================================
    -- FIDGET (LSP progress)
    -- ============================================
    require("fidget").setup({
      notification = {
        window = { winblend = 0 },
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

    -- Luasnip config (snippets are loaded by language modules)
    luasnip.config.setup({
      enable_autosnippets = true,
      store_selection_keys = "<Tab>",
    })

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
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "path", priority = 500 },
        { name = "buffer", priority = 250 },
      }),
      window = {
        completion = { border = "rounded" },
        documentation = { border = "rounded" },
      },
      formatting = {
        format = function(entry, vim_item)
          local icons = {
            Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
            Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
            Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
            Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
            File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
            Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
            TypeParameter = "",
          }
          vim_item.kind = string.format('%s %s', icons[vim_item.kind] or "", vim_item.kind)
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]
          return vim_item
        end,
      },
    })

    -- LSP keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        local opts = { buffer = bufnr }

        -- Enable inlay hints if supported
        if client and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>fm", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
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

    -- Better indenting (stay in visual mode)
    vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
    vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

    -- Move lines
    vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
    vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

    -- Keep cursor centered
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")

    -- Clear search highlight
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlighting" })

    -- Save and quit
    vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file", silent = true })
    vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit", silent = true })

    -- Clipboard (explicit system clipboard keymaps)
    vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
    vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
    vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
    vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

    -- Export capabilities for language configs
    _G.lsp_capabilities = capabilities
  '';
}
