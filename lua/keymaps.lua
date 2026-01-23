local map = vim.keymap.set

-- [[ Basic Keymaps ]]
--  See `:help map()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- NOTE: Personal settings (leader)

-- For toggle execution with args file
USE_ARG = false
map('n', '<leader>ta', function()
  USE_ARG = not USE_ARG
  print('use_arg = ' .. tostring(USE_ARG))
end, { desc = 'Toggle run with arg' })

-- Open explorer view (Normal)
map({ 'n' }, '<leader>e', function()
  vim.cmd 'Ex'
end, { desc = '[E]xplorer view' })

-- Open explorer view of initial directory (Normal)
-- :e.

-- NOTE: F-keys

-- <F1> Preserved for help (Normal/Insert/Visual)

-- <F2> Toggle line wrap (Normal/Insert/Visual)
map({ 'n', 'i', 'v' }, '<F2>', function()
  vim.cmd 'set invwrap'
end, { desc = 'Toggle line wrap' })

-- <F3> Toggle line number (Normal/Insert/Visual)
map({ 'n', 'i', 'v' }, '<F3>', function()
  vim.cmd 'set invnumber'
end, { desc = 'Toggle line number' })

-- <F4> Fold by paired braces (Normal/Insert)
map('n', '<F4>', '%zf%', { desc = 'Fold by paired braces' })
map('i', '<F4>', '<C-o>%<C-o>zf%', { desc = 'Fold by paired braces' })

-- <F5> Toggle fold on cursor (Normal/Insert)
map('n', '<F5>', 'za', { desc = 'Toggle fold on cursor' })
map('i', '<F5>', '<C-o>za', { desc = 'Toggle fold on cursor' })

-- <F6> Switch between windows (Normal/Insert)
-- -- Try <C-h/j/k/l> instead (use <C-o> before when in insert mode)
map('n', '<F6>', '<C-w>w', { desc = 'Siwtch window' })
map('i', '<F6>', '<C-o><C-w>w', { desc = 'Switch window' })

-- <F7> Split window vertical (Normal/Insert)
map('n', '<F7>', '<C-w>v<C-w>l', { desc = 'Split window vertically' })
map('i', '<F7>', '<C-o><C-w>v<C-o><C-w>l', { desc = 'Split window vertically' })

-- <F8> Split window horizontal (Normal/Insert)
map('n', '<F8>', '<C-w>s<C-w>j', { desc = 'Split window horizontally' })
map('i', '<F8>', '<C-o><C-w>s<C-o><C-w>j', { desc = 'Split window horizontally' })

-- <F9> Open quick fix list (Normal/Insert/Visual)
local function ToggleQuickFix()
  local wins = vim.fn.getwininfo()
  local has_qf = false
  for _, w in ipairs(wins) do
    if w.quickfix == 1 then
      has_qf = true
      break
    end
  end
  if has_qf then
    vim.cmd 'cclose'
  else
    vim.cmd 'copen'
  end
end
map({ 'n', 'i', 'v' }, '<F9>', ToggleQuickFix, { desc = 'Toggle QuickFix', silent = true })

-- NOTE: Text operation
local quiet = { silent = true }

-- Movement (Normal/Insert/Visual)
-- -- Ctrl-Arrows Start of word
-- -- Shift-Arrows End of word
map({ 'n', 'v' }, '<S-Right>', 'e', { desc = 'Next EOW' })
map('i', '<S-Right>', '<C-o>e', { desc = 'Next EOW' })
map({ 'n', 'v' }, '<S-Left>', 'ge', { desc = 'Prev EOW' })
map('i', '<S-Left>', '<C-o>ge', { desc = 'Prev EOW' })
-- -- Ctrl-Arrows Jump paragraph
map({ 'n', 'v' }, '<C-Up>', '{', { desc = 'Prev paragraph' })
map('i', '<C-Up>', '<C-o>{', { desc = 'Prev paragraph' })
map({ 'n', 'v' }, '<C-Down>', '}', { desc = 'Next paragraph' })
map('i', '<C-Down>', '<C-o>}', { desc = 'Next paragraph' })

-- Line dragging
-- -- Alt-Arrows (Normal)
map('n', '<M-Up>', ':m-2<CR>', { desc = 'Move current line up' })
map('n', '<M-Down>', ':m+1<CR>', { desc = 'Move current line down' })
-- -- Alt-Arrows (Insert)
map('i', '<M-Up>', '<C-o>:m-2<CR>', { desc = 'Move current line up' })
map('i', '<M-Down>', '<C-o>:m+1<CR>', { desc = 'Move current line down' })
-- -- Alt-Arrows (Visual)
map('v', '<M-Up>', ":m '<-2<CR>gv", { desc = 'Move selected line up' })
map('v', '<M-Down>', ":m '>+1<CR>gv", { desc = 'Move selected line down' })

-- Indenting
-- -- Alt-Arrows (Normal)
map('n', '<M-Right>', 'i<C-t><Esc>', { desc = 'Indent' })
map('n', '<M-Left>', 'i<C-d><Esc>', { desc = 'Dedent' })
-- -- Alt-Arrows (Insert)
map('i', '<M-Right>', '<C-t>', { desc = 'Indent' })
map('i', '<M-Left>', '<C-d>', { desc = 'Dedent' })
-- -- Alt-Arrows (Visual)
map('v', '<M-Right>', '>gv', { desc = 'Indent' })
map('v', '<M-Left>', '<gv', { desc = 'Dedent' })
-- -- Tab/Shift-Tab (Visual)
map('v', '<Tab>', '>gv', { desc = 'Indent' })
map('v', '<S-Tab>', '<gv', { desc = 'Dedent' })

-- Deletion/Backspace (Insert)
-- -- Ctrl-h Backspace
-- -- Ctrl-l Delete
map('i', '<C-l>', '<Del>', { desc = 'Delete' })
-- -- Ctrl-b Delete until end of word
map('i', '<C-b>', '<C-o>de', { desc = 'Delete to EOW' })
-- -- Ctrl-w Delete until start of word
-- -- Ctrl-u Delete until start of line
-- -- Ctrl-z Delete until end of the line
map('i', '<C-z>', '<C-o>D', { desc = 'Delete to EOL' })

-- Paste (Normal)
-- -- p Paste after cursor
-- -- P Paste before cursor

-- Replace (Visual)
map('v', '<C-f>', 'y<ESC>/<C-r>"<CR>:%s//', { desc = 'Replace selected part' })

-- Execute (Visual)
map('v', '<C-x>', 'y<ESC>:split|term<CR>pa', { desc = 'Execute selected code (horizontal)' })
map('v', '<C-v>', 'y<ESC>:vsplit|term<CR>pa', { desc = 'Execute selected code (vertical)' })
-- -- Ctrl-d to disconnect terminal

-- See `.config/nvim/lua/ftplugin` for configs executing different code file.
-- -- <leader>c Edit execution config (make, args, etc.)
-- -- <leader>x Execute file horizontal
-- -- <leader>v Execute file vertical

-- Search vimgrep (Visual)
-- -- Ctrl-/ to vimgrep selected text
-- -- Ctrl-o to go back to previous position
map('v', '<C-_>', 'y<ESC>:copen|vim /<C-r>"/ *', { desc = 'Vimgrep selected text' })
-- Treverse quickfix list
-- -- [q / ]q Previous / Next match
-- -- [Q / ]Q First / Last match
-- For more info about vimgrep, see vimgrep-cheatsheet.md

-- vim: ts=2 sts=2 sw=2 et
