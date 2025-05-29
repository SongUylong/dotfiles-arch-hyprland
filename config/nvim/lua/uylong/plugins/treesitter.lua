return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({
      -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      -- ensure these language parsers are installed
      ensure_installed = {
        -- Web Development
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "graphql",
        "svelte",
        "vue",
        "astro",

        -- PHP (Laravel Stack)
        "php",
        "blade",

        -- Python
        "python",

        -- Backend Development
        "bash",
        "lua",
        "c",
        "cpp",
        "prisma",
        "sql",
        "ruby",
        "go",
        "rust",
        "java",
        "kotlin",
        "toml",
        "ini",
        "dockerfile",

        -- General Text & Configuration
        "markdown",
        "markdown_inline",
        "vimdoc",
        "regex",
        "query",
        "vim",
        "gitignore",
        "git_config",
        "git_rebase",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
    require("nvim-ts-autotag").setup({
      enable = true,
      filetypes = { "html", "xml", "tsx", "jsx", "php", "markdown", "svelte", "vue", "astro" },
    })
  end,
}
