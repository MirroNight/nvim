-- NOTE:Settings specific to .py files

-- Set desc for <leader>x
local wk = require 'which-key'
wk.add({
  { '<leader>x', group = 'Run file' },
}, { buffer = true })

-- Settings
local argsfilename = '.args'
local map = vim.keymap.set
local percent_of_win = 0.4
local win_height = vim.api.nvim_win_get_height(0)
local term_height = math.floor(win_height * percent_of_win)
local init_time_ms = 500

-- <leader>ta Toggle execution with args (create edit when needed)

-- <leader>xc Edit arguments configs
map('n', '<leader>xc', function()
  local file_dir = vim.fn.expand '%:p:h'
  local args_file = file_dir .. '/' .. argsfilename
  vim.cmd('split | edit' .. args_file)
end, { desc = 'Edit arguments config' })

-- <leader>xa Execute current file in terminal (horizontal)
map('n', '<leader>xa', function()
  local file = vim.fn.expand '%:t'
  local file_dir = vim.fn.expand '%:p:h'
  local args_file = file_dir .. '/' .. argsfilename
  local run_cmd = 'python ' .. file

  if USE_ARG then
    if vim.fn.filereadable(args_file) == 1 then
      -- .args file found
      -- Split and open terminal
      vim.cmd(':below' .. term_height .. 'split | terminal')
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
      -- Run with args
      vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd .. ' $(cat ' .. argsfilename .. ')')
      vim.cmd 'startinsert'
    else
      -- .args file not found
      vim.schedule(function()
        local create = vim.fn.confirm('.args not found. Create it?', '&Yes\n&No', 1)
        if create == 1 then
          -- Create .args
          vim.cmd(':below' .. term_height .. 'split | edit' .. args_file)
        else
          -- Split and open terminal
          vim.cmd(':below' .. term_height .. 'split | terminal')
          vim.wait(init_time_ms)
          vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
          vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
          -- Run without args
          vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd)
          vim.cmd 'startinsert'
        end
      end)
    end
  else
    -- use_arg = false run without args
    -- split and open terminal
    vim.cmd(':below' .. term_height .. 'split | terminal')
    vim.wait(init_time_ms)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
    vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd)
    vim.cmd 'startinsert'
  end
end, { desc = 'Run python file (horizontal)', buffer = true })

-- <leader>xv Execute current file in terminal (vertical)
map('n', '<leader>xv', function()
  local file = vim.fn.expand '%:t'
  local file_dir = vim.fn.expand '%:p:h'
  local args_file = file_dir .. '/' .. argsfilename
  local run_cmd = 'python ' .. file

  if USE_ARG then
    if vim.fn.filereadable(args_file) == 1 then
      -- .args file found
      -- Split and open terminal
      vim.cmd 'vsplit | terminal'
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
      -- Run with args
      vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd .. ' $(cat ' .. argsfilename .. ')')
      vim.cmd 'startinsert'
    else
      -- .args file not found
      vim.schedule(function()
        local create = vim.fn.confirm('.args not found. Create it?', '&Yes\n&No', 1)
        if create == 1 then
          -- Create .args
          vim.cmd('vsplit | edit' .. args_file)
        else
          -- Split and open terminal
          vim.cmd 'vsplit | terminal'
          vim.wait(init_time_ms)
          vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
          vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
          -- Run without args
          vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd)
          vim.cmd 'startinsert'
        end
      end)
    end
  else
    -- use_arg = false run without args
    -- split and open terminal
    vim.cmd 'vsplit | terminal'
    vim.wait(init_time_ms)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'which python && python --version\n')
    vim.api.nvim_chan_send(vim.b.terminal_job_id, run_cmd)
    vim.cmd 'startinsert'
  end
end, { desc = 'Run python file (vertical)', buffer = true })

-- vim: ts=2 sts=2 sw=2 et
