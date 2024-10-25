vim.g.mapleader = " "

-- Key mappings to disable Q and set tab and split navigation
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-End>", "<cmd>:tabclose<CR>")
vim.keymap.set("n", "<C-Insert>", "<cmd>:tabnew<CR>")

-- thanks to asbjornHaland
vim.keymap.set({ "n", "v", }, "<leader>y", [["+y"]])
vim.keymap.set("n", "<leader>Y", [["+Y"]])

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Execute python code
vim.keymap.set("n", "<leader>p", "<cmd>!python3 %<CR>")

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
    print("ShoutOut!")
end)

-- Key mappings to switch between tab pages
vim.keymap.set("n", "<leader>h", "<cmd>tabprevious<CR>")
vim.keymap.set("n", "<leader>l", "<cmd>tabnext<CR>")

