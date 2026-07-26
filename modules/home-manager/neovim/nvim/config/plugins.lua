require("nvim-web-devicons").setup({})
require("lualine").setup({})
require("bufferline").setup({})
require("edgy").setup({})
require("gitblame").setup({})
require("headlines").setup({})
require("neoscroll").setup({})
require("neotest").setup({})
require("noice").setup({})
require("statuscol").setup({})
require("telescope").setup({})
require("nvim-treesitter").setup({})
require("trouble").setup({})
require("twilight").setup({})
require("virt-column").setup({})
require("wtf").setup({})

require("toggleterm").setup({
  autochdir = true,
})

require("wilder").setup({
  modes = { ":", "/", "?" },
})

local which_key = require("which-key")

which_key.setup({})

which_key.add({
  {
    "<leader>g",
    group = "Git",
    mode = "n",
  },
})
