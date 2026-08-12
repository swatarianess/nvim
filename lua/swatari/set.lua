vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true


-- Font stuff
-- vim.o.guifont = "FiraCode:h18"

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
vim.opt.winblend = 0  -- Keep windows solid

-- Neovide Opacity settings
vim.g.neovide_opacity = 0.80
vim.g.neovide_normal_opacity = 0.95

vim.opt.updatetime = 50
--vim.opt.colorcolumn = "80"

-- Leader key is set in lua/swatari/remap.lua
