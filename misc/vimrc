" Enable Codeium plugin
let g:codeium_disable_bindings = 0

" Map <Tab> and <Shift-Tab> to accept/previous suggestions
inoremap <silent><expr> <Tab> codeium#Accept()
inoremap <silent><expr> <S-Tab> codeium#Previous()

" Enable Codeium when entering Insert mode
autocmd InsertEnter * call codeium#Enable()

" Optional: Check Codeium status with a custom function
function! CheckCodeiumStatus()
    let status = luaeval("vim.api.nvim_call_function('codeium#GetStatusString', {})")
    echo "Codeium Status: " . status
endfunction

" Map <Leader>cs to check Codeium status
nnoremap <Leader>cs :call CheckCodeiumStatus()<CR>

" TABLE-MODE
let g:table_mode_corner='|'
let g:table_mode_corner_corner='+'
let g:table_mode_header_fillchar='='

function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'



" Common settings for Neovim

syntax on
filetype plugin indent on
set laststatus=2
set so=7
set foldcolumn=1
"#set encoding=utf8
set ffs=unix,dos
set cmdheight=1
set hlsearch
set lazyredraw
set magic
set showmatch
set mat=2
set foldcolumn=1
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set ai "Auto indent
set si "Smart indent
set nobackup
set nowb
set nocp
set autowrite
set hidden
set mouse=a
set noswapfile
set nu
set relativenumber
set t_Co=256
set cursorcolumn
set cursorline
set ruler
set scrolloff=10

" netrw filemanager settings

let g:netrw_menu = 1
let g:netrw_preview = 1
let g:netrw_winsize = 20
let g:netrw_banner = 0
let g:netrw_lifestyle = 1
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4

" Leader and other mappings

let mapleader = ","
nnoremap <Leader>te :terminal<CR>
nnoremap <Leader>tc :terminal<CR>sudo -u batan bash /home/batan/check/vim.cmd.sh <CR>
nnoremap <Leader>xc :w !xclip -selection clipboard<CR>	"copy page to clipboard
nnoremap <leader>dd :Lexplore %:p:h<CR>		"open netrw in 20% of the screen to teh left
nnoremap <Leader>da :Lexplore<CR>
nnoremap <leader>vv :split <CR>		"edit vimrc
nnoremap <leader>sv :source <CR>	"source vimrc
nnoremap <leader>ra :<C-U>RangerChooser<CR>
nmap <F8> :TagbarToggle<CR>				"tagbar toggle

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

"###################		TEMPLATES		################################
autocmd! BufNewFile *.sh 0r ~/.config/nvim/templates/sklt.sh |call setpos('.', [0, 29, 1, 0])
autocmd! BufNewFile *popup.html 0r ~/.config/nvim/templates/popup.html
autocmd! BufNewFile *popup.css 0r ~/.config/nvim/templates/popup.css
autocmd! BufNewFile *popup.js 0r ~/.config/nvim/templates/popup.js
autocmd! BufNewFile *.html 0r ~/.config/nvim/templates/sklt.html
autocmd! BufNewFile *.txt 0r ~/.config/nvim/templates/sklt.txt
if has ('autocmd') " Remain compatible with earlier versions
 augroup vimrc     " Source vim configuration upon save
    autocmd! BufWritePost  source % | echom "Reloaded " .  | redraw
    autocmd! BufWritePost  if has('gui_running') | so % | echom "Reloaded " .  | endif | redraw
  augroup END
endif " has autocmd

"##########################   TASK WIKI   ###############################
" default task report type
let g:task_report_name     = 'next'
" custom reports have to be listed explicitly to make them available
let g:task_report_command  = []
" whether the field under the cursor is highlighted
let g:task_highlight_field = 1
" can not make change to task data when set to 1
let g:task_readonly        = 0
" vim built-in term for task undo in gvim
let g:task_gui_term        = 1
" allows user to override task configurations. Seperated by space. Defaults to ''
let g:task_rc_override     = 'rc.defaultwidth=999'
" default fields to ask when adding a new task
let g:task_default_prompt  = ['due', 'description']
" whether the info window is splited vertically
let g:task_info_vsplit     = 0
" info window size
let g:task_info_size       = 15
" info window position
let g:task_info_position   = 'belowright'
" directory to store log files defaults to taskwarrior data.location
let g:task_log_directory   = '~/.task'
" max number of historical entries
let g:task_log_max         = '20'
" forward arrow shown on statusline
let g:task_left_arrow      = ' <<'
" backward arrow ...
let g:task_left_arrow      = '>> '

"###   STARTUP PAGE   ##############################################################

fun! Start()
    if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode
        return
    endif

    " Force clear buffer
    enew
    call setline(1, []) " Clear content explicitly

    " Set buffer options
    setlocal bufhidden=wipe buftype=nofile nobuflisted nocursorcolumn nocursorline nolist nonumber noswapfile norelativenumber

    " Append task output
    let lines = split(system('task'), '\n')
    for line in lines
        call append('$', '            ' . line)
    endfor

    " Make buffer unmodifiable
    setlocal nomodifiable nomodified

    " Key mappings for convenience
    nnoremap <buffer><silent> e :enew<CR>
    nnoremap <buffer><silent> i :enew <bar> startinsert<CR>
    nnoremap <buffer><silent> o :enew <bar> startinsert<CR>
endfun

augroup StartPage
    autocmd!
    autocmd VimEnter * call Start()
augroup END


