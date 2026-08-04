local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, vim.tbl_extend("force", opts, { desc = "LSP: go to definition" }))
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, vim.tbl_extend("force", opts, { desc = "LSP: hover" }))
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, vim.tbl_extend("force", opts, { desc = "LSP: workspace symbol" }))
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, vim.tbl_extend("force", opts, { desc = "LSP: line diagnostics" }))
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, vim.tbl_extend("force", opts, { desc = "LSP: next diagnostic" }))
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, vim.tbl_extend("force", opts, { desc = "LSP: prev diagnostic" }))
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, vim.tbl_extend("force", opts, { desc = "LSP: code action" }))
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, vim.tbl_extend("force", opts, { desc = "LSP: references" }))
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, vim.tbl_extend("force", opts, { desc = "LSP: rename" }))
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, vim.tbl_extend("force", opts, { desc = "LSP: signature help" }))
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'ts_ls', 'rust_analyzer', 'yamlls'},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
    yamlls = function()
        require('lspconfig').yamlls.setup {
            settings = {
                yaml = {
                    schemas = {
                        kubernetes = "*.yaml"
                    }
                }
            }
        }
    end,
  }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
  },
  formatting = lsp_zero.cmp_format(),
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
})
