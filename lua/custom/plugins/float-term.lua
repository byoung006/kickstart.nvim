-- lazygit-window.lua

local M = {}

local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  -- Define window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal', -- No borders or extra UI elements
    border = 'rounded',
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

function M.toggle_terminal(command)
  local job_id = 0
  if not command then
    command = ''
  end
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.term()
      job_id = vim.bo.channel
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(state.floating.win) then
          vim.fn.chansend(job_id, { command .. '\r\n' })
        end
      end, 100)
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end
function M.setup()
  -- now if we have a floating terminal we should close it
  vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>:Floaterm<CR>')
  -- lets create a command we can call
  vim.api.nvim_create_user_command('Floaterm', function(args)
    if #args.fargs > 0 then -- Check if any arguments were provided
      local command = table.concat(args.fargs, ' ') -- Concatenate arguments with spaces
      M.toggle_terminal(command)
    else
      M.toggle_terminal() -- Call toggle_terminal without arguments if none were provided
    end
  end, { nargs = '*' })

  vim.keymap.set('n', '<leader>lg', ':Floaterm lazygit<CR>')
end
return M
