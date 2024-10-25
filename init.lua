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
  {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
  {"preservim/nerdtree"},
  "folke/neodev.nvim",
  "nvim-treesitter/playground",
  "theprimeagen/harpoon",
  "mbbill/undotree",
  "tpope/vim-fugitive",
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  'L3MON4D3/LuaSnip'
})


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


