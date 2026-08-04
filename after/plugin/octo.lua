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

-- ---------------------------------------------------------------------------
-- :PRDelta  -  view a PR's diff piped through `delta` (single unified pane).
--
-- Octo's own review UI is buffer-based and can't embed delta, so this opens a
-- terminal split running `gh pr diff <n> | delta`. Delta gives a gorgeous,
-- single-column unified diff with syntax highlighting and line numbers.
-- Great as a *reading* companion: keep this open on one side and use the Octo
-- review window on the other to leave comments / mark files viewed.
--
-- Usage:
--   :PRDelta          -> diff for the PR of the current branch (or Octo buffer)
--   :PRDelta 123      -> diff for PR #123
local function pr_delta(opts)
    local num = opts.args and opts.args ~= "" and opts.args or nil

    -- If no number given, try to read it from the current Octo buffer.
    if not num then
        local ok, octo_buffer = pcall(function()
            return require("octo.utils").get_current_buffer()
        end)
        if ok and octo_buffer and octo_buffer.number then
            num = tostring(octo_buffer.number)
        end
    end

    -- `gh pr diff` accepts a number or, with none, uses the current branch's PR.
    local gh_cmd = num and ("gh pr diff " .. num) or "gh pr diff"
    -- Delta is single-column (unified) by default, which is exactly what we
    -- want. paging=never so it fills the terminal buffer and we scroll with
    -- normal nvim keys instead of an internal pager.
    local cmd = string.format(
        "%s | delta --paging=never --line-numbers",
        gh_cmd
    )

    vim.cmd("botright vsplit")
    vim.cmd("enew")
    vim.fn.termopen({ "bash", "-lc", cmd })
    vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("PRDelta", pr_delta, {
    nargs = "?",
    desc = "View PR diff via delta (single unified pane)",
})

map("n", "<leader>opd", "<cmd>PRDelta<cr>", { desc = "Octo: PR diff via delta" })
