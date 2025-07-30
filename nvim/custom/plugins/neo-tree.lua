return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    {
      's1n7ax/nvim-window-picker', -- for open_with_window_picker keymaps
      version = '2.*',
      config = function()
        require('window-picker').setup {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { 'terminal', 'quickfix' },
            },
          },
        }
      end,
    },
    -- Optional image support for file preview: See `# Preview Mode` for more information.
    -- {"3rd/image.nvim", opts = {}},
    -- OR use snacks.nvim's image module:
    -- "folke/snacks.nvim",
  },
  lazy = false, -- neo-tree will lazily load itself
  config = function()
    vim.keymap.set('n', '<leader>nt', ':Neotree toggle<CR>', { desc = '[N]eotree [T]oggle', noremap = true, silent = true })
    vim.keymap.set('n', '<leader>nr', '<Cmd>Neotree reveal<CR>', { desc = '[N]eotree [R]eveal' })

    require('neo-tree').setup {
      enable_diagnostics = true,
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          padding = 0,
        },
        name = {
          trailing_slash = true,
          use_git_status_colors = true,
          highlight = 'NeoTreeFileName',
        },
        git_status = {
          symbols = {
            -- Change type
            added = '',
            modified = '',
            deleted = '✖', -- this can only be used in the git_status source
            renamed = '󰁕', -- this can only be used in the git_status source
            -- Status type
            untracked = '',
            ignored = '',
            unstaged = '󰄱',
            staged = '',
            conflict = '',
          },
        },
      },
      -- A list of functions, each representing a global custom command
      -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
      -- see `:h neo-tree-custom-commands-global`
      commands = {},
      window = {
        position = 'left',
        width = 25,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ['<space>'] = '',
        },
      },
    }
  end,
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {
    -- add options here
  },
}
