-- Octo.nvim: review GitHub PRs/issues from inside nvim.
-- Loads lazily via the `:Octo` command (see init.lua).

-- <leader>o namespace for Octo/PR review
local map = vim.keymap.set

-- PR listing / opening
map("n", "<leader>opl", "<cmd>Octo pr list<cr>", { desc = "Octo: PR list" })
map("n", "<leader>ops", "<cmd>Octo pr search<cr>", { desc = "Octo: PR search" })
map("n", "<leader>opo", function()
    local n = vim.fn.input("PR # > ")
    if n ~= "" then
        vim.cmd("Octo pr edit " .. n)
    end
end, { desc = "Octo: open PR by number" })

-- Review workflow (this is the big-PR flow)
map("n", "<leader>ors", "<cmd>Octo review start<cr>", { desc = "Octo: start review" })
map("n", "<leader>orr", "<cmd>Octo review resume<cr>", { desc = "Octo: resume review" })
map("n", "<leader>orc", "<cmd>Octo review commit<cr>", { desc = "Octo: pick review commit" })
map("n", "<leader>orf", "<cmd>Octo review submit<cr>", { desc = "Octo: submit review" })
map("n", "<leader>ord", "<cmd>Octo review discard<cr>", { desc = "Octo: discard review" })

-- Comments / threads (inside a review)
map("n", "<leader>oca", "<cmd>Octo comment add<cr>", { desc = "Octo: add comment" })
map("n", "<leader>ocd", "<cmd>Octo comment delete<cr>", { desc = "Octo: delete comment" })
map("n", "<leader>ot", "<cmd>Octo thread resolve<cr>", { desc = "Octo: resolve thread" })

-- Issues
map("n", "<leader>oil", "<cmd>Octo issue list<cr>", { desc = "Octo: issue list" })

-- ---------------------------------------------------------------------------
-- Transparency for Octo review diffs.
--
-- Octo shows PR diffs in real (tiled, non-floating) split windows. The empty
-- part of those panes already respects your transparent `Normal`, but the
-- actual diff lines are painted with SOLID DiffAdd/DiffDelete/DiffChange/DiffText
-- backgrounds, so your video wallpaper can't show through them.
--
-- Terminal transparency is all-or-nothing per cell: a highlight either has a
-- solid bg, or bg=none (wallpaper shows through). `winblend` does NOT help here
-- because it only affects floating windows, not tiled splits.
--
-- So we drop the diff backgrounds and instead show additions/deletions via
-- colored FOREGROUND text. Result: the wallpaper shows through the whole pane,
-- and +/- lines are still clearly colored (green/red), just without the fill.
local function transparent_diffs()
    -- Additions: green text, no background.
    vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#9ece6a", bg = "none" })
    -- Deletions: red text, no background.
    vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#f7768e", bg = "none" })
    -- Changed lines: yellow-ish text, no background.
    vim.api.nvim_set_hl(0, "DiffChange", { fg = "#e0af68", bg = "none" })
    -- Changed region within a line: keep a faint bg so it stands out.
    vim.api.nvim_set_hl(0, "DiffText", { fg = "#7dcfff", bg = "none", bold = true })
end

transparent_diffs()

-- Re-apply after any colorscheme change (which resets these groups).
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("OctoTransparentDiffs", { clear = true }),
    callback = transparent_diffs,
})
