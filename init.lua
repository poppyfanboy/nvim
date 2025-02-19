-- Options

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.textwidth = 100
vim.o.colorcolumn = '100'
vim.o.wrap = false
vim.opt.formatoptions:append('n')   -- auto-wrap at textwidth while typing
vim.opt.formatoptions:append('t')   -- recognize numbered lists when wrapping

vim.o.sidescrolloff = 10

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.smartindent = true
vim.o.shiftround = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

vim.o.fileformat = 'unix'
vim.opt.fileformats = { 'unix', 'dos' }

vim.o.splitbelow = true
vim.o.splitright = true
vim.o.splitkeep = 'screen'

vim.o.list = true
vim.opt.listchars = {
    trail = '_',
}

vim.o.foldminlines = 5

vim.o.mouse = ''

vim.o.signcolumn = 'yes'

vim.o.pumheight = 10

vim.o.keymap = 'russian-jcukenwin'
vim.o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
vim.o.iminsert = 0
vim.o.imsearch = -1

-- Theme and appearance

vim.cmd.colorscheme('retrobox')
vim.cmd('hi IndentLine guifg=' .. vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Whitespace')), 'fg', 'gui'))
vim.cmd('hi IndentLineCurrent guifg=' .. vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('CursorLineNr')), 'fg', 'gui'))
vim.cmd('hi! ColorColumn guibg=' .. vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('CursorColumn')), 'bg', 'gui'))

require('indentmini').setup()

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
    end,
})

-- A picker plugin for selecting items from LSP, files, etc.

require('mini.pick').setup()
require('mini.extra').setup()

vim.keymap.set('n', '<leader>sf', '<cmd>Pick files<cr>')
vim.keymap.set('n', '<leader>sg', '<cmd>Pick grep_live<cr>')
vim.keymap.set('n', '<leader>/', '<cmd>Pick buf_lines<cr>')
vim.keymap.set('n', '<leader>ds', '<cmd>Pick lsp scope="document_symbol"<cr>')

-- Filetype

vim.filetype.add({
    h = 'c',
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'c',
    callback = function(event)
        vim.bo[event.buf].commentstring = '// %s'
    end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'yaml',
    callback = function(event)
        vim.bo[event.buf].tabstop = 2
        vim.bo[event.buf].expandtab = true
    end,
})

-- Hard-wrap man pages to 80 columns
vim.fn.setenv('MANWIDTH', '80')
vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'man',
    callback = function(event)
        vim.wo.wrap = false
    end,
})

-- LSP and completion

vim.lsp.set_log_level(vim.log.levels.OFF)

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'c',
    callback = function(event)
        vim.lsp.start({
            name = 'clangd',
            cmd = { 'clangd', '--header-insertion=never' },
            root_dir = vim.fs.root(event.buf, { '.git' }),
        })
    end,
})

require('mini.completion').setup({
    source_func = 'omnifunc',
    auto_setup = false,
    delay = { completion = 200, info = 200, signature = 100 },
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf })
        vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { buffer = event.buf })
        vim.keymap.set('n', '<c-j>', vim.lsp.buf.signature_help, { buffer = event.buf })

        vim.keymap.set('n', '<leader>i', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, { buffer = event.buf })
    end,
})

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dp', vim.diagnostic.open_float)

-- Keymaps

-- Faster <c-e>/<c-y> scrolling
vim.keymap.set('n', '<c-e>', '5<c-e>', { noremap = true })
vim.keymap.set('n', '<c-y>', '5<c-y>', { noremap = true })

-- Horizontal scrolling
vim.keymap.set('n', '<a-h>', '15zh', { noremap = true })
vim.keymap.set('n', '<a-l>', '15zl', { noremap = true })
vim.keymap.set('i', '<a-h>', '<c-o>15zh', { noremap = true })
vim.keymap.set('i', '<a-l>', '<c-o>15zl', { noremap = true })

-- Quickfix
vim.keymap.set('n', '<leader>co', vim.cmd.copen)
vim.keymap.set('n', '<leader>cx', vim.cmd.cclose)
vim.keymap.set('n', ']q', function()
    local ok, _ = pcall(vim.cmd.cnext)
    if not ok then
        pcall(vim.cmd.cfirst)
    end
end)
vim.keymap.set('n', '[q', function()
    local ok, _ = pcall(vim.cmd.cprevious)
    if not ok then
        pcall(vim.cmd.clast)
    end
end)

-- Hide highlighted text after search
vim.keymap.set('n', '<leader>nh', '<cmd>let @/ = ""<cr>')

-- Exit terminal mode
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>', { noremap = true })

-- Move between tabs
vim.keymap.set('n', '[t', vim.cmd.tabprevious)
vim.keymap.set('n', ']t', vim.cmd.tabnext)

-- Add empty lines above/below
vim.keymap.set('n', '[<space>', 'mzO<esc>0D`z', { noremap = true })
vim.keymap.set('n', ']<space>', 'mzo<esc>0D`z', { noremap = true })

-- Join with the line below while keeping the cursor in place
vim.keymap.set('n', 'J', 'mzJ`z', { noremap = true })

-- Resize splits
vim.keymap.set('n', '<left>', '10<c-w><', { noremap = true })
vim.keymap.set('n', '<right>', '10<c-w>>', { noremap = true })
vim.keymap.set('n', '<up>', '5<c-w>-', { noremap = true })
vim.keymap.set('n', '<down>', '5<c-w>+', { noremap = true })

-- Command mode: Ctrl+Enter to accept completion / Escape to cancel
vim.keymap.set('c', '<c-cr>', function()
    if vim.fn.pumvisible() == 1 then
        local confirm_key = vim.api.nvim_replace_termcodes('<c-y>', true, false, true)
        vim.api.nvim_feedkeys(confirm_key, 'n', false)
    else
        local enter_key = vim.api.nvim_replace_termcodes('<cr>', true, false, true)
        vim.api.nvim_feedkeys(enter_key, 'n', false)
    end
end)
vim.keymap.set('c', '<esc>', function()
    if vim.fn.pumvisible() == 1 then
        local cancel_key = vim.api.nvim_replace_termcodes('<c-e>', true, false, true)
        vim.api.nvim_feedkeys(cancel_key, 'n', false)
    else
        local ctrl_c_key = vim.api.nvim_replace_termcodes('<c-c>', true, false, true)
        vim.api.nvim_feedkeys(ctrl_c_key, 'n', false)
    end
end)

-- Switch between Russian and English
vim.keymap.set('n', '<c-l>', function()
    if vim.o.iminsert == 1 then
        vim.o.iminsert = 0
    else
        vim.o.iminsert = 1
    end
end)
vim.keymap.set({ 'i', 'c' }, '<c-l>', '<c-^>', { noremap = true })

-- Create/destroy treesitter folds
vim.keymap.set('n', '<leader>fo', function()
    if vim.wo.foldmethod == 'manual' then
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldtext = ''
    else
        vim.api.nvim_feedkeys('zE', 'n', true)

        vim.wo.foldmethod = 'manual'
        vim.wo.foldexpr = ''
        vim.wo.foldtext = 'foldtext()'
    end
end)

-- Delete to void register
vim.keymap.set('v', '<leader>d', '"_d', { noremap = true })
vim.keymap.set('v', '<leader>c', '"_c', { noremap = true })
vim.keymap.set('n', '<leader>C', '"_C', { noremap = true })

-- Switch between two last opened files
vim.keymap.set('n', '\\', '<c-^>', { noremap = true })

-- Indent multiple times in visual mode multiple times in a row
vim.keymap.set('v', '<', '<gv', { noremap = true })
vim.keymap.set('v', '>', '>gv', { noremap = true })

-- Replace a word under the cursor (dot-repeatable)
vim.keymap.set('n', '<leader>rw', '*``cgn', { noremap = true })
vim.keymap.set('v', '<leader>rw', '"zy/<c-r>z<cr>``cgn', { noremap = true })

-- MoveThroughWordsInCamelCasedIdentifiers
vim.keymap.set('n', '<a-.>', '<cmd>set nohls<cr>/\\v(\\u|.>|<)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<a-,>', '<cmd>set nohls<cr>?\\v(\\u|.<|>)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { noremap = true, silent = true })
vim.keymap.set('v', '<a-.>', '<cmd>set nohls<cr><esc>/\\v(\\u|.>|<)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { noremap = true, silent = true })
vim.keymap.set('v', '<a-,>', '<cmd>set nohls<cr><esc>?\\v(\\u|.<|>)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { noremap = true, silent = true })

-- Move_though_words_in_snake_cased_identifiers
vim.keymap.set('n', '<a-n>', '<cmd>set nohls<cr>/\\v(_|..>|.<|$)/s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<a-p>', '<cmd>set nohls<cr>?\\v(_|.<|.>|$)?s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { noremap = true, silent = true })
vim.keymap.set('v', '<a-n>', '<cmd>set nohls<cr><esc>/\\v(_|..>|.<|$)/s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { noremap = true, silent = true })
vim.keymap.set('v', '<a-p>', '<cmd>set nohls<cr><esc>?\\v(_|.<|.>|$)?s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { noremap = true, silent = true })

-- vim: et:sw=4
