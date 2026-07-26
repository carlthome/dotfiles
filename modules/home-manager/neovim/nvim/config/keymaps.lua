vim.keymap.set(
  "n",
  "<F8>",
  "<cmd>TagbarToggle<cr>",
  { desc = "Toggle Tagbar" }
)

vim.keymap.set(
  "v",
  "<C-r>",
  "hy:%s/<C-r>h//gc<Left><Left><Left>",
  {
    noremap = true,
    desc = "Search and replace selection",
  }
)

vim.keymap.set(
  "n",
  "<leader>fm",
  vim.lsp.buf.format,
  { desc = "Format the current buffer" }
)

vim.keymap.set(
  "n",
  "<C-k>",
  "<cmd>bprev<cr>",
  { desc = "Previous buffer" }
)

vim.keymap.set(
  "n",
  "<C-j>",
  "<cmd>bnext<cr>",
  { desc = "Next buffer" }
)
