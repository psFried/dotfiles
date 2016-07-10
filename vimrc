filetype off
execute pathogen#infect()

set omnifunc=syntaxcomplete#Complete
set nocompatible
set tabstop=4 shiftwidth=4 expandtab
set autoindent smartindent
set showmatch
set mouse=a
set smartcase
set number
let g:netrw_liststyle=3
noremap E :Vexplore<Cr>
highlight LineNr ctermfg=252 ctermbg=235

set hidden

" for Racer plugin
let $RUST_SRC_PATH="/Users/pfried/projects/rust/src"
let g:racer_cmd = "/Users/pfried/.cargo/bin/racer"

" Stuff for Syntastic linter plugin
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" set autocomplete to ctrl-Space
inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-Space>

syntax on
filetype plugin indent on

let g:vim_markdown_folding_disabled=1

set wrap
set textwidth=0 

