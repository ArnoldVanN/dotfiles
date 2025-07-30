-- plugins/yamlls.lua
return {
  'neovim/nvim-lspconfig',
  opts = {
    servers = {
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              kubernetes = '*.yaml',
              ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
              ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
              ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
              ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
              ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
              ['http://json.schemastore.org/ansible-playbook'] = '*play*.{yml,yaml}',
              ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
              ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = '*api*.{yml,yaml}',
              [vim.fn.expand '~/.config/nvim/k8s-crds/gameserver.schema.json'] = '**/*gameserver.yaml',
            },
            validate = true,
            completion = true,
            format = { enable = true },
          },
        },
      },
    },
  },
}
