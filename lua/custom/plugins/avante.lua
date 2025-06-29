return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  opts = {
    provider = 'claude',
    claude = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-3-5-sonnet-20240620',
      timeout = 30000,
      temperature = 0,
      max_tokens = 4096,
      disable_tools = true,
    },
  },
  config = function(_, opts)
    require('avante').setup(opts)

    -- Custom highlights for Avante
    vim.api.nvim_set_hl(0, 'AvanteActive', { bg = '#303030' }) -- Dark gray for active window
    vim.api.nvim_set_hl(0, 'AvanteInactive', { bg = '#1c1c1c' }) -- Darker gray for inactive windows

    -- Function to update Avante window highlights
    local function update_avante_highlights()
      local current_win = vim.api.nvim_get_current_win()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.bo[buf].filetype
        if filetype == 'Avante' or filetype == 'AvanteInput' or filetype == 'AvanteSelectedFiles' then
          local hl_group = win == current_win and 'AvanteActive' or 'AvanteInactive'
          vim.wo[win].winhighlight = string.format('Normal:%s', hl_group)
        end
      end
    end

    -- Apply custom highlights to Avante windows
    vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'BufEnter', 'FileType' }, {
      pattern = { '*' },
      callback = function()
        vim.schedule(update_avante_highlights)
      end,
    })

    -- Ensure Avante uses these custom highlights
    vim.g.avante_use_custom_highlights = true
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
        code = {
          enabled = false,
        },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
