vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true


-- Other settings
vim.opt.number = true
vim.opt.autoindent = true
vim.opt.cursorcolumn = true
vim.opt.cursorline = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
-- vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- Tab appearance settings
vim.opt.showtabline = 1 -- Always show tabline
vim.api.nvim_set_hl(0, 'TabLine', { bg = 'NONE', fg = "#565f89" })
vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'TabLineSel', { bg = '#1a1b26', fg = '#7aa2f7', bold = true })

-- Window transparency settings
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' }) -- This is for non-current (inactive) windows
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })

-- Ensure consistent transparency
vim.opt.pumblend = 0  -- Keep popup menu solid
vim.opt.winblend = 0  -- Keep active window solid

-- Set winblend for inactive windows
vim.opt.winblend = 80

--vim.opt.scrolloff = 9
--vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50
--vim.opt.colorcolumn = "80"

vim.g.mapleader = " "
