-- NERDTree configuration

-- Set the global variable to keep NERDTree open when opening a file
vim.g.NERDTreeQuitOnOpen = 0

-- Show hidden files
vim.g.NERDTreeShowHidden = 1

-- Set the global variable to display Git status flags
vim.g.NERDTreeGitStatusWithFlags = 1

-- Automatically open NERDTree when Vim starts with a directory
vim.cmd [[
autocmd vimenter * if isdirectory(expand('%')) | NERDTree | endif
]]

-- Close Vim if NERDTree is the only window left
vim.cmd [[
autocmd bufenter * if (winnr('$') == 1 && bufname() == 'NERD_tree_1') | q | endif
]]

-- Key mappings for NERDTree
vim.keymap.set("n", "<leader>pv", "<cmd>NERDTreeToggle %<CR>", { desc = "Toggle NERDTree" })

-- Key mappings to switch between splits (windows)
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Window right" })
