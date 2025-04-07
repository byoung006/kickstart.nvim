local prompts = {
  -- Code related prompts
  Explain = 'Please explain how the following code works.',
  Review = 'Please review the following code and provide suggestions for improvement.',
  Tests = 'Please explain how the selected code works, then generate unit tests for it.',
  Refactor = 'Please refactor the following code to improve its clarity and readability.',
  FixCode = 'Please fix the following code to make it work as intended.',
  FixError = 'Please explain the error in the following text and provide a solution.',
  BetterNamings = 'Please provide better names for the following variables and functions.',
  Documentation = 'Please provide documentation for the following code.',
  SwaggerApiDocs = 'Please provide documentation for the following API using Swagger.',
  SwaggerJsDocs = 'Please write JSDoc for the following API using Swagger.',
  -- Text related prompts
  Summarize = 'Please summarize the following text.',
  Spelling = 'Please correct any grammar and spelling errors in the following text.',
  Wording = 'Please improve the grammar and wording of the following text.',
  Concise = 'Please rewrite the following text to make it more concise.',
}

local M = {}

M.setup = function()
  local chat = require 'CopilotChat'
  chat.setup {
    question_header = '## User ',
    answer_header = '## Copilot ',
    error_header = '## Error ',
    window = {
      layout = 'horizontal', -- 'vertical', 'horizontal', 'float', 'replace'
      width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
      height = 0.3, -- fractional height of parent, or absolute height in rows when > 1
    },
    prompts = {}, -- Define prompts or import if needed
    mappings = {
      complete = {
        detail = 'Use @<Tab> or /<Tab> for options.',
        insert = '<Tab>',
      },
      close = {
        normal = 'q',
        insert = '<C-c>',
      },
      reset = {
        normal = '<C-x>',
        insert = '<C-x>',
      },
      submit_prompt = {
        normal = '<CR>',
        insert = '<C-CR>',
      },
      accept_diff = {
        normal = '<C-y>',
        insert = '<C-y>',
      },
      show_help = {
        normal = 'g?',
      },
    },
  }

  local select = require 'CopilotChat.select'
  vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
    chat.ask(args.args, { selection = select.visual })
  end, { nargs = '*', range = true })

  vim.api.nvim_create_user_command('CopilotChatInline', function(args)
    chat.ask(args.args, {
      selection = select.visual,
      window = {
        layout = 'horizontal',
        relative = 'cursor',
        width = 1,
        height = 0.4,
        row = 1,
      },
    })
  end, { nargs = '*', range = true })

  vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
    chat.ask(args.args, { selection = select.buffer })
  end, { nargs = '*', range = true })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
      vim.opt_local.relativenumber = true
      vim.opt_local.number = true

      local ft = vim.bo.filetype
      if ft == 'copilot-chat' then
        vim.bo.filetype = 'markdown'
      end
    end,
  })
end

return M
