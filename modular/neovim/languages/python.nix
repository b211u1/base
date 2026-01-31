# neovim/languages/python.nix
{ pkgs }:

{
  name = "python";

  plugins = with pkgs.vimPlugins; [
    friendly-snippets  # VSCode-style snippets for Python
  ];

  packages = with pkgs; [
    python3
    ruff
    pyright
    black
    isort
    python3Packages.debugpy
  ];

  config = ''
    -- Load Python snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "python" }
    })

    -- Custom Python/pytest snippets
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local fmt = require("luasnip.extras.fmt").fmt

    ls.add_snippets("python", {
      -- pytest test function (AAA pattern)
      s("test", fmt([[
def test_{}():
    # Arrange
    {}

    # Act
    {}

    # Assert
    {}
]], {
        i(1, "something"),
        i(2, "expected = None"),
        i(3, "result = None"),
        i(4, "assert result == expected"),
      })),

      -- pytest test class
      s("testclass", fmt([[
class Test{}:
    """Test cases for {}."""

    def test_{}(self):
        # Arrange
        {}

        # Act
        {}

        # Assert
        {}
]], {
        i(1, "ClassName"),
        f(function(args) return args[1][1] end, {1}),
        i(2, "something"),
        i(3, "expected = None"),
        i(4, "result = None"),
        i(5, "assert result == expected"),
      })),

      -- pytest fixture
      s("fix", fmt([[
@pytest.fixture
def {}():
    """{}."""
    {}
    return {}
]], {
        i(1, "fixture_name"),
        i(2, "Fixture description"),
        i(3, "# setup"),
        i(4, "value"),
      })),

      -- Function with type hints
      s("def", fmt([[
def {}({}) -> {}:
    """{}."""
    {}
]], {
        i(1, "function_name"),
        i(2, ""),
        i(3, "None"),
        i(4, "Description"),
        i(5, "pass"),
      })),

      -- Dataclass
      s("dc", fmt([[
@dataclass
class {}:
    """{}."""
    {}: {}
]], {
        i(1, "ClassName"),
        i(2, "Description"),
        i(3, "field"),
        i(4, "str"),
      })),

      -- Assert equals
      s("aeq", t("assert result == expected")),

      -- Assert raises
      s("araises", fmt([[
with pytest.raises({}):
    {}
]], {
        i(1, "ValueError"),
        i(2, "pass"),
      })),

      -- Main guard
      s("main", fmt([[
if __name__ == "__main__":
    {}
]], { i(1, "pass") })),
    })

    -- Python LSP (Pyright) using native vim.lsp.config
    vim.lsp.config.pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoImportCompletions = true,
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    }
    vim.lsp.enable("pyright")

    -- Ruff for linting/formatting
    vim.lsp.config.ruff = {
      cmd = { "ruff", "server" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    }
    vim.lsp.enable("ruff")

    -- Python-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = true
        vim.opt_local.colorcolumn = "88"
      end,
    })

    -- Format on save for Python
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.py",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  '';
}
