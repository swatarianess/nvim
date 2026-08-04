-- which-key: the popup that shows available keybindings after you press <leader>.
-- Docked to the bottom-right and given an opaque background so it's readable
-- (your colors.lua makes NormalFloat transparent, which washed this out).

local wk = require("which-key")

wk.setup({
    preset = "helix", -- compact side panel style
    win = {
        border = "rounded",
        -- Anchor to the bottom-right corner of the editor.
        -- col = -1 / row = -1 pin it to the right/bottom edges.
        col = -1,
        row = -1,
        width = { min = 30, max = 50 },
        padding = { 0, 1 },
        -- Pseudo-transparency: 0 = opaque, 100 = fully transparent.
        -- Low value = subtle glass effect while staying readable.
        wo = {
            winblend = 15,
        },
    },
    layout = {
        align = "left",
    },
})

-- Register readable group names for leader prefixes so which-key shows
-- "+project", "+octo" etc instead of just "+N keymaps".
wk.add({
    { "<leader>p", group = "project/find" },
    { "<leader>v", group = "misc" },
    { "<leader>o", group = "octo (PR review)" },
    { "<leader>op", group = "octo: PR" },
    { "<leader>or", group = "octo: review" },
    { "<leader>oc", group = "octo: comment" },
    { "<leader>oi", group = "octo: issue" },
})

-- Force opaque backgrounds for the which-key floats, overriding the
-- transparent NormalFloat set in colors.lua. Re-applied on colorscheme change.
local function fix_whichkey_bg()
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#1a1b26" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#1a1b26", fg = "#565f89" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#1a1b26", })
    vim.api.nvim_set_hl(0, "WhichKeyTitle", { bg = "#1a1b26" })
end

fix_whichkey_bg()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = fix_whichkey_bg,
})
