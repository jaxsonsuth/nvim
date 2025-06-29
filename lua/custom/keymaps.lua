local M = {}

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

M.session_mappings = function()
  local mini_sessions = require 'mini.sessions'
  local telescope = require 'telescope'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local sorters = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  keymap('n', '<leader>mw', function()
    mini_sessions.write()
    print 'Session saved.'
  end, { desc = 'Write (Save) Current Session' })

  keymap('n', '<leader>ms', function()
    local sessions = mini_sessions.detected
    local session_list = vim.tbl_keys(sessions)

    -- ✅ If no sessions exist, show "Create New Session" option
    if vim.tbl_isempty(session_list) then
      session_list = { 'No Sessions' }
    end

    pickers
      .new({}, {
        prompt_title = 'Manage Sessions 🗂  [n] New  [Enter] Load  [d] Delete',
        finder = finders.new_table { results = session_list },
        sorter = sorters.generic_sorter {},
        layout_config = {
          width = 0.4, -- 40% of the screen width
          height = 0.3, -- 30% of the screen height
          prompt_position = 'top',
        },
        attach_mappings = function(prompt_bufnr, map)
          -- ✅ Load session with 'l'
          map('i', '<CR>', function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            if selection and selection.value and selection.value ~= 'Create New Session' then
              mini_sessions.read(selection.value)
              print('Loaded session: ' .. selection.value)
            else
              print 'No session selected.'
            end
          end)

          -- ✅ Delete session with 'd'
          map('i', 'd', function()
            local selection = action_state.get_selected_entry()
            if selection and selection.value and selection.value ~= 'Create New Session' then
              mini_sessions.delete(selection.value)
              print('Deleted session: ' .. selection.value)
            end
            actions.close(prompt_bufnr)
          end)

          -- ✅ Create a new session with 'n'
          map('i', 'n', function()
            actions.close(prompt_bufnr)

            local new_session = vim.fn.input 'New session name: '
            if new_session ~= '' then
              mini_sessions.write(new_session)
              print('New session created: ' .. new_session)
            else
              print 'Session creation canceled.'
            end
          end)

          return true
        end,
      })
      :find()
  end, { desc = 'Manage Sessions' })
end

return M
