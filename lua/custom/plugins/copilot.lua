return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = { enabled = true },
        suggestion = {
          enabled = true,
          auto_trigger = false,
          hide_during_completion = false,
          debounce = 25,
          keymap = {
            accept = '<leader>y',
            accept_word = false,
            accept_line = '<Tab>',
            next = false,
            prev = false,
            dismiss = '<leader>n',
          },
        },
      }
    end,
  },
}
