vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "Q", "<nop>")

-- thanks to asbjornHaland
vim.keymap.set({ "n", "v", }, "<leader>y", [["+y"]])
vim.keymap.set("n", "<leader>Y", [["+Y"]])

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
    print("ShoutOut!")
end)
