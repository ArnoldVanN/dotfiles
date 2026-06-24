return {
  'JoosepAlviste/nvim-ts-context-commentstring',
  lazy = true,
  init = function()
    -- Skip the legacy nvim-treesitter "module" integration (a no-op on the
    -- treesitter `main` branch anyway) to speed up loading.
    vim.g.skip_ts_context_commentstring_module = true
  end,
  config = function()
    -- Disable the CursorHold autocmd that recomputes `commentstring`: it fires
    -- for every treesitter-active buffer and crashes on Nvim 0.12 when
    -- `vim.treesitter.get_parser()` returns nil. Comment.nvim already computes
    -- the commentstring on-demand via its `pre_hook` (see comment.lua), so the
    -- autocmd is redundant.
    require('ts_context_commentstring').setup { enable_autocmd = false }
  end,
}
