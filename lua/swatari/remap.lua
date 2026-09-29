vim.g.mapleader = " "

-- Key mappings to disable Q and set tab and split navigation
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })
vim.keymap.set("n", "<C-End>", "<cmd>:tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<C-Insert>", "<cmd>:tabnew<CR>", { desc = "New tab" })

-- thanks to asbjornHaland
vim.keymap.set({ "n", "v", }, "<leader>y", [["+y"]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y"]], { desc = "Yank line to system clipboard" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer (LSP)" })

-- Execute python code
vim.keymap.set("n", "<leader>p", "<cmd>!python3 %<CR>", { desc = "Run file with python3" })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
    print("ShoutOut!")
end, { desc = "Source current file" })

-- Quickfix list (]q / [q for next / previous are Neovim defaults)
vim.keymap.set("n", "<leader>q", function()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 and win.loclist == 0 then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end, { desc = "Toggle quickfix list" })

-- Key mappings to switch between tab pages
vim.keymap.set("n", "<leader>h", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>l", "<cmd>tabnext<CR>", { desc = "Next tab" })

