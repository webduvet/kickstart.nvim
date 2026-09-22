set termguicolors

set timeoutlen=1000 ttimeoutlen=0

set nu
set colorcolumn=100
set wrap

" visible hidden characters
set list listchars+=nbsp:· listchars-=eol:$
"set listchars=tab:\ \ ,nbsp:·
let &listchars = 'tab:| ,nbsp:·'

" turn off autofolding
set nofoldenable

" tabs for different files and default
"set tabstop=4 shiftwidth=4 smarttab expandtab
set tabstop=4 shiftwidth=4 smarttab noexpandtab

" for js/coffee/jade files, 4 spaces
autocmd Filetype javascript setlocal ts=4 sw=4 noexpandtab
autocmd Filetype json setlocal ts=4 sw=4 noexpandtab
autocmd Filetype c setlocal ts=8 sw=8 noexpandtab


" prettier settings
" this prettify everything upon the save - not very user friendly
"autocmd FileType javascript set formatprg=prettier\ --stdin
"autocmd BufWritePre *.js :normal gggqG
"autocmd BufWritePre *.jsx :normal gggqG

let g:python3_host_prog='/usr/bin/python3'
"let g:python_host_prog='/usr/bin/python'

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdcommenter'
"  Plug 'pangloss/vim-javascript'
Plug 'rking/ag.vim'
Plug 'prettier/vim-prettier'
"Plug 'mxw/vim-jsx'
"Plug 'HerringtonDarkholme/vim-jsx-pretty'
Plug 'MaxMEllon/vim-jsx-pretty'

"Plug 'w0rp/ale'
"let g:ale_linters = {'javascript': ['eslint']}  
Plug 'plasticboy/vim-markdown'
Plug 'jiangmiao/auto-pairs'
Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'udalov/kotlin-vim'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'lygaret/autohighlight.vim'
Plug 'scrooloose/nerdtree'
Plug 'easymotion/vim-easymotion'
Plug 'pboettch/vim-highlight-cursor-words'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'
"Plug 'Yggdroot/indentLine'

Plug 'aserebryakov/vim-todo-lists'
Plug 'leafgarland/typescript-vim'

Plug 'vim-latex/vim-latex'

"Grammar
Plug 'rhysd/vim-grammarous'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

"Plug 'github/copilot.vim'

Plug 'preservim/tagbar'
Plug 'udalov/kotlin-vim'

Plug 'endel/vim-github-colorscheme'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'webduvet/vim-yankref'

" Initialize plugin system
call plug#end()

" colorscheme needs vim plug
"colorscheme tokyonight

" for buffergator allow swap unsaved buffer
set hidden

" deoplete configuration
let g:deoplete#enable_at_startup = 1

inoremap <silent><expr> <TAB>
			\ pumvisible() ? "\<C-n>" :
			\ <SID>check_back_space() ? "\<TAB>" :
			\ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~ '\s'
	endfunction"}}}

	set clipboard=unnamedplus

	" hot key and other keys mapping
	let mapleader = ','
	map J <c-d>
	map K <c-u>

	map <leader>f :Files<cr>
	map <leader>q :bw<cr>

	map <c-a> :Ag 

	" buffergator
	"map <leader>bb :BuffergatorOpen<cr>

	let NERDTreeShowHidden=1

	" search text under cursor
	map <leader>s :$s/\<<C-r><C-w>\>/

	let g:airline#extensions#tabline#enabled = 1
	nnoremap <C-J> <C-W><C-J>
	nnoremap <C-K> <C-W><C-K>
	nnoremap <C-L> <C-W><C-L>
	nnoremap <C-H> <C-W><C-H>

	" NERDTree
	map <leader>n :NERDTreeToggle<cr>
	:let g:NERDTreeWinSize=60

	" map ESC
	imap § <Esc>

	" table mapping simple
	"map <leader>| │
	"map <leader>l └
	"map <leader>- ─
	"map <leader>e ├

	augroup filetype_c
		autocmd!
		:autocmd FileType c setlocal tabstop=8 shiftwidth=8 softtabstop=8 expandtab smarttab
		:autocmd FileType c nnoremap <buffer> <localleader>c I/*<space><esc><s-a><space>*/<esc>
	augroup end

	nmap <F8> :TagbarToggle<CR>

	"colorscheme jellybeans
	"colorscheme tokyonight-moon
	"colorscheme github
	colorscheme wildcharm

	" vim prettier
	let g:prettier#autoformat = 1
	let g:prettier#autoformat_config_present = 1
	let g:prettier#exec_cmd_path = '<path-to-your-prettier>'
	let g:prettier#quickfix_enabled = 0
	let g:prettier#config#tab_width = 4   " Adjust tab width to your preference
	let g:prettier#config#use_tabs = 'true'  " Use tabs instead of spaces

	"autocmd FileType typescriptreact setlocal formatprg=prettier\ --stdin-filepath\ % --parser\ typescript

" Map Normal mode trigger
nmap <leader>a <Plug>(YankRefNormal)

" Map Visual mode trigger
xmap <leader>a <Plug>(YankRefVisual)
