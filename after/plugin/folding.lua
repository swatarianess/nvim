-- Folding behavior (indent-based, no dotted fill, custom fold text).

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
