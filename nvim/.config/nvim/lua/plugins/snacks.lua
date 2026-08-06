-- Always show hidden and ignored files in the file explorer and pickers.
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        hidden = true,
        ignored = true,
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
        hidden = true,
        ignored = true,
      },
    },
  },
}
