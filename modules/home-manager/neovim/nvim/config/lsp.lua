local group =
  vim.api.nvim_create_augroup("user-lsp-keymaps", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,

  callback = function(event)
    local function map(lhs, rhs, description)
      vim.keymap.set("n", lhs, rhs, {
        buffer = event.buf,
        desc = description,
      })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.references, "List references")
    map("gt", vim.lsp.buf.type_definition, "Go to type definition")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("K", vim.lsp.buf.hover, "LSP hover")
  end,
})

vim.lsp.enable({
  "bashls",
  "nixd",
})
