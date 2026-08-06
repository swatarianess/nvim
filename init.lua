--- Import swatari configuration
require("swatari")

--- Set Python3 provider path
vim.g.python3_host_prog = '/usr/bin/python3'

--- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- Set leader key
vim.g.mapleader = " "

--- Remove annoying node warning
vim.g.loaded_node_provider = 0

--- Plugin setup with lazy.nvim
require("lazy").setup({
  "folke/which-key.nvim",
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      lazy = false,
      build = ':TSUpdate',
      dependencies = {
          "OXY2DEV/markview.nvim"
      }
  },
  {"preservim/nerdtree"},
  "folke/neodev.nvim",
  "theprimeagen/harpoon",
  "mbbill/undotree",
  "tpope/vim-fugitive",
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  {
      'adelarsq/image_preview.nvim',
      event = 'VeryLazy',
      config = function()
          require("image_preview").setup()
      end
  },
  'L3MON4D3/LuaSnip',
  {
      'kdheepak/lazygit.nvim',
      lazy = true,
      cmd = {
          "LazyGit",
          "LazyGitConfig",
          "LazyGitCurrentFile",
          "LazyGitFilter",
          "LazyGitFilterCurrentFile",
      },
      dependencies = {
          "nvim-lua/plenary.nvim",
      },
  },
  {
      "hat0uma/csvview.nvim",
      --- @module "csvview"
      --- @type CsvView.Options
      opts = {
          parser = { comments = { "#", "//" } },
          keymaps = {
              -- Text objects for selecting fields
              textobject_field_inner = { "if", mode = { "o", "x" } },
              textobject_field_outer = { "af", mode = { "o", "x" } },
              -- Excel-like navigation:
              -- Use <Tab> and <S-Tab> to move horiz between fields.
              -- Use <Enter> and <S-Enter> to move vertically between row and place the cursor at the end of the field.
              -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
              jump_next_field_end = { "<Tab>", mode = { "n", "v"} },
              jump_prev_field_end = { "<S-Tab>", mode = { "n", "v"} },
              jump_next_row = { "<Enter>", mode = { "n", "v"} },
              jump_prev_row = { "<S-Enter>", mode = { "n", "v"} },
          },
      },
      cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  },
  {
      "mikavilpas/yazi.nvim",
      event = "VeryLazy",
      dependencies = {
          { "nvim-lua/plenary.nvim", lazy = true },
      },
  },
  { "nvim-tree/nvim-web-devicons" },
  {
      -- Pretty markdown rendering (heading icons, concealed #/*, tables,
      -- bullets, callouts). We scope it to the `octo` filetype ONLY so it does
      -- not fight markview.nvim, which already renders real `.md` files.
      -- Relies on octo registering the markdown TS parser for octo buffers
      -- (see octo config below); render-markdown decorates that TS tree.
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "octo" },
      dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons",
      },
      opts = {
          file_types = { "octo" },
          -- Octo buffers are edited in place; render in normal mode but drop to
          -- raw text while inserting so editing titles/comments stays sane.
          render_modes = { "n", "c" },
      },
  },
  {
      "pwntester/octo.nvim",
      cmd = "Octo",
      dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-telescope/telescope.nvim",
          "nvim-tree/nvim-web-devicons",
      },
      config = function()
          require("octo").setup({
              enable_builtin = true,
              -- Use gh over the API; better for very large PRs
              picker = "telescope",
          })
          vim.treesitter.language.register("markdown", "octo")
      end,
  },
})

local lspconfig = require("lspconfig")

-- Enable folding and set fold method to 'indent'
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = true
vim.opt.foldlevel = 0

-- Customize fillchars to remove dots in folded lines
vim.opt.fillchars = { fold = ' ' }

vim.opt.foldtext = 'v:lua.custom_foldtext()'

-- Define a custom foldtext function in Lua
function _G.custom_foldtext()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_folded_lines = vim.v.foldend - vim.v.foldstart + 1
    return line .. ' ... ' .. num_folded_lines .. ' lines'
end


