-- DevOps / SRE tooling not already covered by a LazyVim lang extra:
-- shell scripting (bashls + shellcheck + shfmt) and Kubernetes manifest/cluster browsing.
return {
  -- Bash/sh language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
    },
  },

  -- extra treesitter parsers useful for infra work
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "toml",
        "ini",
        "gitignore",
      },
    },
  },

  -- make sure mason installs the CLI tools the extras/lsp configs above rely on
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "shellcheck",
        "shfmt",
      },
    },
  },

  -- browse/edit Kubernetes cluster resources from within Neovim
  {
    "Ramilito/kubectl.nvim",
    cmd = { "Kubectl", "KubectlDelete" },
    keys = {
      { "<leader>k", "<cmd>lua require('kubectl').toggle()<cr>", desc = "Kubectl" },
    },
    opts = {},
  },
}
