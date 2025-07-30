return {
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require('ibl').setup()
  end,
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {},
}
