-- NOTE:Settings specific to .c files

-- Set desc for <leader>x
local wk = require 'which-key'
wk.add({
  { '<leader>x', group = 'Compile and run file' },
}, { buffer = true })

-- Settings
local map = vim.keymap.set
local percent_of_win = 0.4
local win_height = vim.api.nvim_win_get_height(0)
local term_height = math.floor(win_height * percent_of_win)
local init_time_ms = 500

-- C specific settings
local compiler = 'clang'
local cflags = '-Wall -Wextra -pedantic'
local makefile_name = 'Makefile'
local debugger = 'gdb'
local debug_config = '.gdbinit'

local function GetMakefileTemplate(main, bin)
  return {
    'SRC := ' .. main,
    'BIN := ' .. bin,
    'CC ?= clang',
    'CFLAGS ?= -Wall -Wextra -pedantic',
    'LDFLAGS ?=',
    'LDLIBS ?=',
    'DEBUG_FLAGS = -DDEBUG -O0 -g -fno-omit-frame-pointer -fno-optimize-sibling-calls -fsanitize=address',
    'RELEASE_FLAGS = -DNDEBUG -O2',
    '',
    'config ?= debug',
    '',
    'ifeq ($(config), debug)',
    '	CFLAGS += $(DEBUG_FLAGS)',
    'else',
    '	CFLAGS += $(RELEASE_FLAGS)',
    'endif',
    '',
    'all: $(BIN)',
    '',
    '$(BIN):',
    '	$(CC) $(SRC) -o $(BIN) $(CFLAGS)',
    '',
    '.PHONY: all clean debug release ' .. bin,
    '',
    'clean:',
    '	rm $(BIN)',
    '',
    'debug:',
    '	@$(MAKE) config=debug',
    '',
    'release:',
    '	@$(MAKE) config=release',
  }
end

local function GetDebugTemplate()
  return {
    '# For debuging in glibc (path may vary)',
    'set substitute-path ./csu /usr/src/glibc/glibc-2.35/csu',
    'set substitute-path . /usr/src/glibc/glibc-2.35',
    '',
    '# Disable LeakSanitizer in gdb',
    '# (run program directly in terminal for LSan)',
    'set env ASAN_OPTIONS=detect_leaks=0',
    '',
    'set logging enabled on',
    'set logging file debug.log',
    'set print pretty on',
    '# set args <arg1> <arg2> ...',
    'b main',
    'r',
  }
end

-- <leader>xm Edit makefile
map('n', '<leader>xm', function()
  local file = vim.fn.expand '%:t'
  local file_dir = vim.fn.expand '%:p:h'
  local makefile = file_dir .. '/' .. makefile_name
  local bin = vim.fn.expand '%:t:r'

  if not (vim.fn.filereadable(makefile) == 1) then
    -- Makefile not found, create one
    vim.fn.writefile(GetMakefileTemplate(file, bin), makefile)
    vim.cmd('split | edit' .. makefile)
  else
    vim.cmd('split | edit' .. makefile)
  end
end, { desc = 'Edit Makefile' })

-- <leader>xd Debugger settings
map('n', '<leader>xd', function()
  local file_dir = vim.fn.expand '%:p:h'
  local debugfile = file_dir .. '/' .. debug_config

  if not (vim.fn.filereadable(debugfile) == 1) then
    -- .gdbinit not found, create one
    vim.fn.writefile(GetDebugTemplate(), debugfile)
    vim.cmd('split | edit' .. debugfile)
  else
    vim.cmd('split | edit' .. debugfile)
  end
end, { desc = 'Edit debug settings' })

-- <leader>xa Execute current file in terminal (horizontal)
map('n', '<leader>xa', function()
  local file = vim.fn.expand '%:t'
  local file_dir = vim.fn.expand '%:p:h'
  local makefile = file_dir .. '/' .. makefile_name
  local debugfile = file_dir .. '/' .. debug_config
  local bin = vim.fn.expand '%:t:r'

  if (vim.fn.filereadable(makefile) == 1) and (vim.fn.filereadable(debugfile) == 1) then
    -- Makefile and .gdbinit exist
    -- split and open terminal
    vim.cmd(':below' .. term_height .. 'split | terminal')
    vim.wait(init_time_ms)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')

    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'make\n')
    vim.wait(init_time_ms)

    local debug_cmd = debugger .. ' -x ' .. debug_config .. ' ' .. bin
    vim.api.nvim_chan_send(vim.b.terminal_job_id, debug_cmd)
    vim.cmd 'startinsert'
    return
  end

  if not (vim.fn.filereadable(makefile) == 1) then
    -- Makefile not found, create or continue
    local create = vim.fn.confirm('Makefile not found. Create one?', '&Yes\n&No', 1)
    if create == 1 then
      vim.fn.writefile(GetMakefileTemplate(file, bin), makefile)
      vim.cmd(':below' .. term_height .. 'split | edit' .. makefile)
      return
    else
      local compile_cmd = compiler .. file .. ' -o ' .. bin .. ' ' .. ' ' .. cflags
      vim.cmd(':below' .. term_height .. 'split | terminal')
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, compile_cmd)
      vim.cmd 'startinsert'
      return
    end
  end

  if not (vim.fn.filereadable(debugfile) == 1) then
    -- .gdbinit not found
    local create = vim.fn.confirm('.gdbinit not found. Create one?', '&Yes\n&No', 1)
    if create == 1 then
      -- Create .gdbinit
      vim.fn.writefile(GetDebugTemplate(), debugfile)
      vim.cmd(':below' .. term_height .. 'split | edit' .. debugfile)
      return
    else
      -- Command lines only
      vim.cmd(':below' .. term_height .. 'split | terminal')
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, './' .. bin)
      vim.cmd 'startinsert'
      return
    end
  end
end, { desc = 'Run file (horizontal)', buffer = true })

-- <leader>xv Execute current file in terminal (vertical)
map('n', '<leader>xv', function()
  local file = vim.fn.expand '%:t'
  local file_dir = vim.fn.expand '%:p:h'
  local makefile = file_dir .. '/' .. makefile_name
  local debugfile = file_dir .. '/' .. debug_config
  local bin = vim.fn.expand '%:t:r'

  if (vim.fn.filereadable(makefile) == 1) and (vim.fn.filereadable(debugfile) == 1) then
    -- Makefile and .gdbinit exist
    -- split and open terminal
    vim.cmd 'vsplit | terminal'
    vim.wait(init_time_ms)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')

    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'make\n')
    vim.wait(init_time_ms)

    local debug_cmd = debugger .. ' -x ' .. debug_config .. ' ' .. bin
    vim.api.nvim_chan_send(vim.b.terminal_job_id, debug_cmd)
    vim.cmd 'startinsert'
    return
  end

  if not (vim.fn.filereadable(makefile) == 1) then
    -- Makefile not found, create or continue
    local create = vim.fn.confirm('Makefile not found. Create one?', '&Yes\n&No', 1)
    if create == 1 then
      vim.fn.writefile(GetMakefileTemplate(file, bin), makefile)
      vim.cmd('vsplit | edit' .. makefile)
      return
    else
      local compile_cmd = compiler .. file .. ' -o ' .. bin .. ' ' .. ' ' .. cflags
      vim.cmd 'vsplit | terminal'
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, compile_cmd)
      vim.cmd 'startinsert'
      return
    end
  end

  if not (vim.fn.filereadable(debugfile) == 1) then
    -- .gdbinit not found
    local create = vim.fn.confirm('.gdbinit not found. Create one?', '&Yes\n&No', 1)
    if create == 1 then
      -- Create .gdbinit
      vim.fn.writefile(GetDebugTemplate(), debugfile)
      vim.cmd('vsplit | edit' .. debugfile)
      return
    else
      -- Command lines only
      vim.cmd 'vsplit | terminal'
      vim.wait(init_time_ms)
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'cd ' .. file_dir .. '\n')
      vim.api.nvim_chan_send(vim.b.terminal_job_id, './' .. bin)
      vim.cmd 'startinsert'
      return
    end
  end
end, { desc = 'Run file (vertical)', buffer = true })

-- vim: ts=2 sts=2 sw=2 et
