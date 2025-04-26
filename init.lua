-- Options

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.textwidth = 100
vim.o.colorcolumn = '100'
vim.o.wrap = false
vim.opt.formatoptions:append('n')   -- recognize numbered lists when wrapping
vim.opt.formatoptions:append('t')   -- auto-wrap at textwidth while typing

vim.o.sidescrolloff = 10

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

local indent = 4
vim.o.expandtab = true
vim.o.tabstop = indent
vim.o.shiftwidth = 0
vim.o.smartindent = true
vim.o.shiftround = true
vim.opt.cinoptions = {
    'l1',           -- disable the default weird indentation within switch cases
    ':0',           -- do not indent labels within switch statements
    '+0',           -- fix indentation within compound literals with designated initializers
    '(' .. indent,  -- indent only once on the next line after an opening parenthesis
}

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
    tab = '-->',
}

vim.o.foldminlines = 5

vim.o.mouse = ''

vim.o.signcolumn = 'yes'

vim.o.pumheight = 10
vim.opt.completeopt = { 'menuone', 'noselect' }
if vim.fn.has('nvim-0.11') == 1 then
    vim.opt.completeopt:append('fuzzy')
end
vim.opt.shortmess:append('c')
vim.opt.shortmess:append('C')

vim.g.netrw_winsize = 30
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4

vim.o.keymap = 'russian-jcukenwin'
vim.o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
vim.o.iminsert = 0
vim.o.imsearch = -1

-- Theme and appearance

function hl(highlight_group, key)
    local value = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(highlight_group)), key, 'gui')
    if value == '' then
        return nil
    else
        return value
    end
end

vim.cmd.colorscheme('retrobox')

vim.cmd('hi! IndentLine guifg=' .. hl('LineNr', 'fg'))
vim.cmd('hi! IndentLineCurrent guifg=' .. (hl('CursorLineNr', 'fg') or hl('Normal', 'fg')))
vim.cmd('hi! ColorColumn guibg=' .. hl('CursorColumn', 'bg'))
vim.cmd('hi! link PmenuKindSel PmenuSel')

if vim.fn.has('nvim-0.11') == 1 then
    if hl('PmenuKind', 'fg') ~= nil and hl('PmenuSel', 'fg') ~= nil then
        vim.cmd('hi! PmenuMatch guifg=' .. hl('PmenuKind', 'fg') .. ' gui=bold cterm=bold')
        vim.cmd('hi! PmenuMatchSel guifg=' .. hl('PmenuSel', 'fg') .. ' gui=bold cterm=bold')
    end
end

local ok_indentmini, indentmini = pcall(require, 'indentmini')
if ok_indentmini then
    indentmini.setup()
end

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
    end,
})

-- A picker plugin for selecting items from LSP, files, etc.

local ok_mini_pick, mini_pick = pcall(require, 'mini.pick')
if ok_mini_pick then
    mini_pick.setup()
    vim.keymap.set('n', '<leader>sf', '<cmd>Pick files<cr>')
    vim.keymap.set('n', '<leader>sg', '<cmd>Pick grep_live<cr>')
end

local ok_mini_extra, mini_extra = pcall(require, 'mini.extra')
if ok_mini_extra then
    mini_extra.setup()
    vim.keymap.set('n', '<leader>/', '<cmd>Pick buf_lines<cr>')
    vim.keymap.set('n', '<leader>ds', '<cmd>Pick lsp scope="document_symbol"<cr>')
end

-- Filetype

vim.filetype.add({
    extension = {
        h = 'c',
    },
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

-- Treesitter highlighting

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'lua' },
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- LSP and completion

vim.lsp.set_log_level(vim.log.levels.OFF)

local client_capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    {
        textDocument = {
            completion = { completionItem = { snippetSupport = false } },
        },
    }
)

if vim.fn.executable('clangd') == 1 then
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'c',
        callback = function(event)
            vim.lsp.start({
                name = 'clangd',
                cmd = { 'clangd', '--header-insertion=never' },
                root_dir = vim.fs.root(event.buf, { '.clangd', 'compile_flags.txt', '.git' }),
                capabilities = client_capabilities,
            })
        end,
    })
end

local ok_mini_completion, mini_completion = pcall(require, 'mini.completion')
if ok_mini_completion then
    mini_completion.setup({
        source_func = 'omnifunc',
        auto_setup = false,
        delay = { completion = 100, info = 200, signature = 10e7 },
        window = {
            info = { border = 'none' },
            signature = { border = 'none' },
        },
        set_vim_settings = false,
        lsp_completion = {
            process_items = function(items, base)
                local max_item_width = 60
                for _, item in ipairs(items) do
                    if vim.fn.strdisplaywidth(item.label) > max_item_width then
                        item.label = vim.fn.strcharpart(item.label, 0, max_item_width - 1) .. '…'
                    end
                end

                return mini_completion.default_process_items(items, base)
            end,
        },
    })
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        if ok_mini_completion then
            vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
        elseif vim.fn.has('nvim-0.11') == 1 then
            vim.lsp.completion.enable(true, event.data.client_id, event.buf, { autotrigger = true })
        end

        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf })
        vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { buffer = event.buf })
        vim.keymap.set({ 'n', 'v' }, '<leader>ff', vim.lsp.buf.format, { buffer = event.buf })

        vim.keymap.set({ 'i', 'n' }, '<c-s>', vim.lsp.buf.signature_help, { buffer = event.buf })

        vim.keymap.set({ 'i', 'n' }, '<c-j>', function()
            for _, window in ipairs(vim.api.nvim_list_wins()) do
                local config = vim.api.nvim_win_get_config(window)
                if config.relative ~= '' then
                    vim.api.nvim_win_close(window, false)
                end
            end
        end, { buffer = event.buf })

        vim.keymap.set('n', '<leader>i', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, { buffer = event.buf })
    end,
})

-- Keymaps

-- Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dp', vim.diagnostic.open_float)

-- Faster <c-e>/<c-y> scrolling
vim.keymap.set('n', '<c-e>', '5<c-e>')
vim.keymap.set('n', '<c-y>', '5<c-y>')

-- Horizontal scrolling
vim.keymap.set('n', '<a-h>', '15zh')
vim.keymap.set('n', '<a-l>', '15zl')
vim.keymap.set('i', '<a-h>', '<c-o>15zh')
vim.keymap.set('i', '<a-l>', '<c-o>15zl')

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
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

-- Tabs manipulation
vim.keymap.set('n', '[t', vim.cmd.tabprevious)
vim.keymap.set('n', ']t', vim.cmd.tabnext)
vim.keymap.set('n', '<leader>tx', vim.cmd.tabclose)

-- Add empty lines above/below
vim.keymap.set('n', '[<space>', 'mzO<esc>0D`z')
vim.keymap.set('n', ']<space>', 'mzo<esc>0D`z')

-- Join with the line below while keeping the cursor in place
vim.keymap.set('n', 'J', 'mzJ`z')

-- Resize splits
vim.keymap.set('n', '<left>', '10<c-w><')
vim.keymap.set('n', '<right>', '10<c-w>>')
vim.keymap.set('n', '<up>', '5<c-w>-')
vim.keymap.set('n', '<down>', '5<c-w>+')

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

-- Always insert a new line when pressing 'enter' key in insert mode, even when completion menu is
-- opened. (Instead of doing nothing and just closing the completion menu by default?)
vim.keymap.set('i', '<cr>', function()
    if vim.fn.pumvisible() == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<c-y><cr>', true, false, true), 'n', false)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, false, true), 'n', false)
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
vim.keymap.set({ 'i', 'c' }, '<c-l>', '<c-^>')

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
vim.keymap.set('v', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>c', '"_c')
vim.keymap.set('n', '<leader>C', '"_C')

-- Switch between two last opened files
vim.keymap.set('n', '\\', '<c-^>')

-- Indent in visual mode multiple times in a row
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Replace a word under the cursor (dot-repeatable)
vim.keymap.set('n', '<leader>rw', '*``"_cgn')
vim.keymap.set('v', '<leader>rw', '"zy/\\M<c-r>z<cr>``"_cgn')

-- MoveThroughWordsInCamelCasedIdentifiers
vim.keymap.set('n', '<a-.>', '<cmd>set nohls<cr>/\\v(\\u|.>|<)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { silent = true })
vim.keymap.set('n', '<a-,>', '<cmd>set nohls<cr>?\\v(\\u|.<|>)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { silent = true })
vim.keymap.set('v', '<a-.>', '<cmd>set nohls<cr><esc>/\\v(\\u|.>|<)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { silent = true })
vim.keymap.set('v', '<a-,>', '<cmd>set nohls<cr><esc>?\\v(\\u|.<|>)<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { silent = true })

-- Move_though_words_in_snake_cased_identifiers
vim.keymap.set('n', '<a-n>', '<cmd>set nohls<cr>/\\v(_|..>|.<|$)/s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { silent = true })
vim.keymap.set('n', '<a-p>', '<cmd>set nohls<cr>?\\v(_|.<|.>|$)?s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>', { silent = true })
vim.keymap.set('v', '<a-n>', '<cmd>set nohls<cr><esc>/\\v(_|..>|.<|$)/s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { silent = true })
vim.keymap.set('v', '<a-p>', '<cmd>set nohls<cr><esc>?\\v(_|.<|.>|$)?s+1<cr><cmd>let @/ = ""<cr><cmd>set hls<cr>mzgv`z', { silent = true })

-- Open the folder containing the current file in Netrw
vim.keymap.set('n', '<leader>o', '<cmd>Lex %:p:h<cr>')

-- Open the current working directory in Netrw
vim.keymap.set('n', '<leader>e', '<cmd>Lex<cr>')

-- Keymaps specific to the Netrw buffer
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function(event)
        -- :cd into the directory currently opened in Netrw
        vim.keymap.set('n', '`', function()
            vim.cmd('cd ' .. vim.b.netrw_curdir)
        end, { buffer = event.buf })

        -- Create a new file (the default '%' is bugged)
        vim.keymap.set('n', '<leader>%', function()
            local file_name = vim.fn.input('New file: ', '', 'file')
            vim.cmd('vsp ' .. vim.b.netrw_curdir .. '/' .. file_name)
        end, { buffer = event.buf })
    end,
})

-- Surround with X keymaps
vim.keymap.set('v', '<leader>(', '<cmd>let @z=@"<cr>c()<c-c>gP<cmd>let @"=@z<cr>')
vim.keymap.set('v', '<leader>[', '<cmd>let @z=@"<cr>c[]<c-c>gP<cmd>let @"=@z<cr>')
vim.keymap.set('v', '<leader>{', '<cmd>let @z=@"<cr>c{}<c-c>gP<cmd>let @"=@z<cr>')
vim.keymap.set('v', '<leader>}', '<cmd>let @z=@"<cr>c{  }<c-c>hgP<cmd>let @"=@z<cr>l')
vim.keymap.set('v', '<leader>\'', '<cmd>let @z=@"<cr>c\'\'<c-c>gP<cmd>let @"=@z<cr>')
vim.keymap.set('v', '<leader>"', '<cmd>let @z=@"<cr>c""<c-c>gP<cmd>let @"=@z<cr>')
vim.keymap.set('v', '<leader>`', '<cmd>let @z=@"<cr>c``<c-c>gP<cmd>let @"=@z<cr>')

-- Quickly open or switch to a tab with a terminal
vim.keymap.set('n', '<f1>', function()
    vim.g.quick_term_prev_window = vim.fn.win_getid()

    if vim.g.quick_term_buffer == nil or vim.fn.bufexists(vim.g.quick_term_buffer) == 0 then
        vim.cmd('tabnew')
        vim.cmd('ter')
        vim.cmd('file term_' .. vim.fn.win_getid())
        vim.g.quick_term_window = vim.fn.win_getid()
        vim.g.quick_term_buffer = vim.fn.winbufnr(vim.g.quick_term_window)
    else
        if vim.fn.winbufnr(vim.g.quick_term_window) == vim.g.quick_term_buffer then
            vim.fn.win_gotoid(vim.g.quick_term_window)
        else
            vim.cmd('tabnew')
            vim.cmd('b ' .. vim.g.quick_term_buffer)
            vim.g.quick_term_window = vim.fn.win_getid()
        end
    end

    vim.api.nvim_feedkeys('i', 'n', false)
end)
vim.keymap.set('t', '<f1>', function()
    if
        vim.g.quick_term_prev_window ~= nil and
        vim.fn.winbufnr(vim.g.quick_term_window) ~= -1
    then
        vim.fn.win_gotoid(vim.g.quick_term_prev_window)
    end
end)

-- Delete the current buffer without changing the window layout
-- A copy-paste from here: https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua
vim.keymap.set('n', '<leader>x', function()
    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_call(buf, function()
        if vim.bo.modified then
            return
        end

        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.api.nvim_win_call(win, function()
                if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
                    return
                end

                -- Try using alternate buffer
                local alt = vim.fn.bufnr('#')
                if alt ~= buf and vim.fn.buflisted(alt) == 1 then
                    vim.api.nvim_win_set_buf(win, alt)
                    return
                end

                -- Try using previous buffer
                local has_previous = pcall(vim.cmd, 'bprevious')
                    if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
                    return
                end

                -- Create new listed buffer
                local new_buf = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_win_set_buf(win, new_buf)
            end)
        end

        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.cmd, 'bdelete! ' .. buf)
        end
    end)
end)

-- vim: et:sw=4
