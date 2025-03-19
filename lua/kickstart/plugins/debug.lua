-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
local function get_pkg_path(pkg, path)
  pcall(require, 'mason')
  local root = vim.env.MASON or (vim.fn.stdpath 'data' .. '/mason')
  path = path or ''
  local ret = root .. '/packages/' .. pkg .. '/' .. path
  return ret
end
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'leoluz/nvim-dap-go',
    'theHamsta/nvim-dap-virtual-text',
    { 'nvim-neotest/nvim-nio' },
    {
      'microsoft/vscode-js-debug',
      opt = true,
      run = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    require('nvim-dap-virtual-text').setup()
    local adapters = { 'pwa-node', 'pwa-chrome' }
    local js_based_languages = { 'typescript', 'javascript', 'typescriptreact' }
    local debugger_path = get_pkg_path('js-debug-adapter', '/js-debug/src/dapDebugServer.js')

    -- Setup DAP config by VS Code launch.json file
    local dap_vscode = require 'dap.ext.vscode'
    local json = require 'plenary.json'
    ---@diagnostic disable-next-line: duplicate-set-field
    dap_vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str, {}))
    end

    -- Configure JS/TS adapters
    for _, adapter in ipairs(adapters) do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { debugger_path, '${port}' },
        },
      }
    end

    -- DAP configuration for JS-based languages
    for _, language in ipairs(js_based_languages) do
      dap.configurations[language] = {
        -- Debug single nodejs files
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        -- Debug nodejs processes (make sure to add --inspect when you run the process)
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        -- Debug web applications (client side)
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch & Debug Chrome',
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = 'Enter URL: ',
                default = 'http://localhost:3000',
              }, function(url)
                if url == nil or url == '' then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = vim.fn.getcwd(),
          protocol = 'inspector',
          sourceMaps = true,
          userDataDir = false,
        },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ -----',
          type = '',
          request = 'launch',
        },
      }
    end

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup { -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*', breakpoint = '⭔', logpoint = '◆' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })

    local breakpoint_icons = vim.g.have_nerd_font
        and {
          Breakpoint = '',
          BreakpointCondition = '',
          BreakpointRejected = '',
          LogPoint = '',
          Stopped = '',
        }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }

    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    vim.keymap.set('n', '<leader>b', function()
      require('dap').toggle_breakpoint()
    end)
    vim.keymap.set('n', '<leader>dd', function()
      require('dapui').toggle()
    end)
    vim.keymap.set('n', '<F5>', function()
      require('dap').continue()
    end)
    vim.keymap.set('n', '<F7>', function()
      require('dap').step_over()
    end)
    vim.keymap.set('n', '<F6>', function()
      require('dap').step_into()
    end)
    vim.keymap.set('n', '<F8>', function()
      require('dap').step_out()
    end)

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end,
}
