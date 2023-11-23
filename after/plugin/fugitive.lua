vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local Swatari_Fugitive = vim.api.nvim_create_augroup("Swatari_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = Swatari_Fugitive,
    pattern = "*",
    callback = function ()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_bug()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>p", function ()
            vim.cmd.Git('push')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>P", function ()
            vim.cmd.Git({"pull", "--rebase"})
        end, opts)
        -- Note: It allows me to easily set the branch i am pushing and any 
        -- tracking needed if I did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
    end,
})
