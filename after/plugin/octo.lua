-- Octo.nvim: review GitHub PRs/issues from inside nvim.
-- Loads lazily via the `:Octo` command (see init.lua).

-- ---------------------------------------------------------------------------
-- Upstream bug workaround (octo.nvim): generate_position2line_map crashes with
-- "attempt to perform arithmetic on local 'left_side_line' (a nil value)" when
-- a review comment's diffhunk header has no line count, e.g. "@@ -1 +1 @@"
-- (single-line hunks in small/new files). Octo's regex requires a comma
-- (`-N,M`), returns nil, and then does nil+1 in the loop.
--
-- We replace the function at runtime from our OWN config so the fix survives
-- `:Lazy update` (which would overwrite a direct edit to the plugin file).
-- Remove this block once the upstream PR is merged.
local function patch_octo_position_map()
    local ok, utils = pcall(require, "octo.utils")
    if not ok or type(utils) ~= "table" then
        return
    end
    if utils.__position_map_patched then
        return
    end
    utils.__position_map_patched = true

    utils.generate_position2line_map = function(diffhunk)
        local diffhunk_lines = vim.split(diffhunk, "\n")
        local diff_directive = diffhunk_lines[1] or ""
        local left_offset, right_offset =
            string.match(diff_directive, "@@%s*%-(%d+),%d+%s%+(%d+)")
        -- Fallback for headers without a left-side line count (e.g. "@@ -1 +1 @@").
        if left_offset == nil then
            left_offset, right_offset =
                string.match(diff_directive, "@@%s*%-(%d+)%D.-%+(%d+)")
        end
        -- Never let the loop below do nil arithmetic.
        left_offset = tonumber(left_offset) or 0
        right_offset = tonumber(right_offset) or 0

        local right_side_lines = {}
        local left_side_lines = {}
        local right_side_line = right_offset
        local left_side_line = left_offset
        for i = 2, #diffhunk_lines do
            local line = diffhunk_lines[i]
            if vim.startswith(line, "+") then
                right_side_lines[i] = right_side_line
                right_side_line = right_side_line + 1
            elseif vim.startswith(line, "-") then
                left_side_lines[i] = left_side_line
                left_side_line = left_side_line + 1
            else
                right_side_lines[i] = right_side_line
                left_side_lines[i] = left_side_line
                right_side_line = right_side_line + 1
                left_side_line = left_side_line + 1
            end
        end

        return {
            left_side_lines = left_side_lines,
            right_side_lines = right_side_lines,
            right_offset = right_offset,
            left_offset = left_offset,
        }
    end
end

-- Apply now if octo is already loaded, and also whenever it loads via lazy.
patch_octo_position_map()
vim.api.nvim_create_autocmd("User", {
    pattern = { "LazyLoad" },
    callback = function(ev)
        if ev.data == "octo.nvim" then
            patch_octo_position_map()
        end
    end,
})

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
-- terminal running `gh pr diff <n> | delta`. Delta gives a gorgeous,
-- single-column unified diff with syntax highlighting and line numbers.
--
-- It pulls context straight from Octo when available:
--   * the PR number from the current Octo buffer, and
--   * the file you're currently viewing in a review (so delta scrolls to it).
--
-- Usage:
--   :PRDelta          -> current PR (float). If in a review, jumps to the
--                        file under your cursor.
--   :PRDelta 123      -> PR #123 in a float
--   :PRDelta!         -> full PR in a bottom split instead of a float
local function octo_context()
    local num, file, repo
    local ok_u, octo_buffer = pcall(function()
        return require("octo.utils").get_current_buffer()
    end)
    if ok_u and octo_buffer then
        if octo_buffer.number then
            num = tostring(octo_buffer.number)
        end
        -- The repo the PR actually belongs to (e.g. "owner/name"). Without this
        -- gh guesses from the cwd/branch, which gives the wrong or no diff when
        -- you're not checked out on that repo/branch.
        if octo_buffer.repo then
            repo = octo_buffer.repo
        end
    end
    -- If we're in an active review, grab the file currently focused so we can
    -- scroll delta to it.
    local ok_r, reviews = pcall(require, "octo.reviews")
    if ok_r then
        local review = reviews.get_current_review and reviews.get_current_review()
        if review and review.layout then
            local ok_f, f = pcall(function()
                return review.layout:get_current_file()
            end)
            if ok_f and f and f.path then
                file = f.path
            end
        end
    end
    return num, file, repo
end

local function open_delta_float()
    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor((ui and ui.width or vim.o.columns) * 0.85)
    local height = math.floor((ui and ui.height or vim.o.lines) * 0.85)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " PR diff (delta) ",
        title_pos = "center",
    })
    -- Give this float a SOLID dark background. Your colors.lua makes the global
    -- NormalFloat transparent, which let the diff behind bleed through and made
    -- delta unreadable. We define dedicated opaque groups and point the window
    -- at them via winhighlight so only THIS float is solid.
    vim.api.nvim_set_hl(0, "DeltaFloatNormal", { bg = "#11121a", fg = "#c0caf5" })
    vim.api.nvim_set_hl(0, "DeltaFloatBorder", { bg = "#11121a", fg = "#565f89" })
    vim.wo[win].winhighlight =
        "Normal:DeltaFloatNormal,NormalFloat:DeltaFloatNormal,FloatBorder:DeltaFloatBorder"
    vim.wo[win].winblend = 0
    -- q or <Esc> closes the float.
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n><cmd>close<cr>]], { buffer = buf })
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
    return buf, win
end

local function pr_delta(opts)
    local num = opts.args and opts.args ~= "" and opts.args or nil
    local file, repo
    -- Always try to read Octo context (for repo + focused file), even when a PR
    -- number was given explicitly.
    local ctx_num, ctx_file, ctx_repo = octo_context()
    num = num or ctx_num
    file = ctx_file
    repo = ctx_repo

    -- Build: gh pr diff [num] [--repo owner/name]
    local parts = { "gh pr diff" }
    if num then
        table.insert(parts, num)
    end
    if repo then
        table.insert(parts, "--repo " .. vim.fn.shellescape(repo))
    end
    local gh_cmd = table.concat(parts, " ")
    -- Delta is single-column (unified) by default. paging=never so it fills the
    -- buffer and we scroll with normal nvim keys.
    local cmd = string.format("%s | delta --paging=never --line-numbers", gh_cmd)

    if opts.bang then
        -- Full diff in a bottom split.
        vim.cmd("botright split")
        vim.cmd("enew")
    else
        -- Floating window overlaid on the review.
        open_delta_float()
    end

    vim.fn.termopen({ "bash", "-lc", cmd })

    -- If we know the focused review file, search delta's output for its header
    -- and scroll there once the terminal has rendered.
    if file then
        local target = vim.api.nvim_get_current_buf()
        vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(target) then
                return
            end
            local wins = vim.fn.win_findbuf(target)
            if not wins[1] then
                return
            end
            local win = wins[1]
            -- Leave terminal-mode so we can move the cursor (otherwise any
            -- normal-mode command errors with "Can't re-enter normal mode
            -- from terminal mode").
            pcall(vim.api.nvim_set_current_win, win)
            pcall(vim.cmd, "stopinsert")
            vim.api.nvim_win_call(win, function()
                -- Delta prints the file path as a header; find it and put that
                -- line at the top of the window. Escape magic chars so the path
                -- matches literally.
                local pat = vim.fn.escape(file, "/\\.*$^~[]")
                local lnum = vim.fn.search(pat, "w")
                if lnum > 0 then
                    -- Scroll so the match sits at the top, without `normal!`.
                    vim.fn.winrestview({ topline = lnum, lnum = lnum, col = 0 })
                end
            end)
        end, 400)
    end

    vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("PRDelta", pr_delta, {
    nargs = "?",
    bang = true,
    desc = "View PR diff via delta (float; ! = split). Uses Octo PR + file context.",
})

map("n", "<leader>opd", "<cmd>PRDelta<cr>", { desc = "Octo: PR diff via delta (float)" })
map("n", "<leader>opD", "<cmd>PRDelta!<cr>", { desc = "Octo: PR diff via delta (split)" })
