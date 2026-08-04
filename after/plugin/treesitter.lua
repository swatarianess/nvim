-- nvim-treesitter `main` branch (rewrite) config.
-- The old `require('nvim-treesitter.configs').setup{}` API is gone.
-- Highlighting/folding are now driven by Neovim core (vim.treesitter.start()),
-- and parsers are installed via require('nvim-treesitter').install{}.

local ts = require("nvim-treesitter")

-- Default install dir is fine; this is just explicit.
ts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Parsers we always want available (async install, no-op if present).
ts.install({
    "javascript", "typescript", "c", "lua", "vim", "vimdoc", "query",
    "python", "bash", "json", "yaml", "toml", "markdown", "markdown_inline",
    "diff", "html", "xml", "dockerfile", "gitignore", "terraform", "hcl",
    "make", "ssh_config", "git_config", "gitcommit", "git_rebase",
})

-- Start highlighting (and auto-install a missing parser) when opening a file.
-- Replaces the old `highlight = { enable = true }` + `auto_install = true`.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local buf = args.buf
        local ft = args.match
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end

        local ts_config = require("nvim-treesitter.config")
        local installed = ts_config.get_installed("parsers")
        local have = vim.tbl_contains(installed, lang)

        if have then
            pcall(vim.treesitter.start, buf, lang)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        else
            -- Only attempt install for languages that actually have a parser
            -- upstream. This avoids warnings for plugin UI filetypes like
            -- `octo_panel` (get_lang falls back to the ft name, which is not a
            -- real parser).
            if not vim.tbl_contains(ts_config.get_available(), lang) then
                return
            end
            -- Install asynchronously, then start highlighting on that buffer.
            ts.install({ lang }):await(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    pcall(vim.treesitter.start, buf, lang)
                end
            end)
        end
    end,
})
