return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    ensure_installed = {
      'bash',
      'python',
      'prel',
      'R',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = {
      enable = true,
      disable = { 'ruby' },
    },
    -- incremental_selection = {
    --   enable = true,
    --   keymaps = {
    --     init_selection    = 'gnn',
    --     node_incremental  = 'grn',
    --     scope_incremental = 'grc',
    --     node_decremental  = 'grm',
    --   },
    -- },
  },
}
-- vim: ts=2 sts=2 sw=2 et
