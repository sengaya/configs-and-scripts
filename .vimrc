syntax on
set background=dark

"groesserer buffer
set viminfo='20,\"1000

filetype plugin on

" Indentation / tab settings
set autoindent    "keep the current indentation level when going to next line
set smartindent   "automatic indent after e.g. a line that ends with a {
autocmd FileType python setlocal expandtab
autocmd FileType python setlocal shiftwidth=4
autocmd FileType python setlocal tabstop=4
autocmd FileType python setlocal softtabstop=4
" set expandtab     "insert spaces instead of tabs
" set shiftwidth=4
" set tabstop=4
" set softtabstop=4

" Linebreak
autocmd FileType python setlocal textwidth=79

" Show non-printable characters: show tabs as »· so tabs can be identified
" and replaced using :retab when neccessary
set list
set listchars=tab:»·

set paste
" toggle 'set paste'
:set pastetoggle=<F2>
inoremap <F2> <Esc><F2>a

" comments
map ## :s/^/#/<CR>
map #/ :s/^/\/\//<CR>
map #> :s/^/> /<CR>
map #" :s/^/\"/<CR>
map #% :s/^/%/<CR>
map #! :s/^/!/<CR>
map #; :s/^/;/<CR>
map #- :s/^/--/<CR>
map #+ :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>

if $TERM=='screen'
exe "set title titlestring=vim:%f"
exe "set title t_ts=\<ESC>k t_fs=\<ESC>\\"
endif

