"if empty(glob('~/.vim/autoload/plug.vim'))
"  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
"    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
"endif
"
"call plug#begin()
""Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
"Plug 'AndrewRadev/splitjoin.vim'
"Plug 'chazy/dirsettings'
"Plug 'dhruvasagar/vim-table-mode'
"Plug 'embear/vim-foldsearch'
"Plug 'godoctor/godoctor.vim'
"Plug 'horkhork/markdownIR.vim'
"Plug 'jamessan/vim-gnupg'
""Plug 'jceb/vim-orgmode'
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Plug 'skywind3000/asyncrun.vim'
"Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
"call plug#end()

" Execute the current line in a bash subprocess
nnoremap ,w :.w !bash<CR>
" Execute the current selection in a bash subprocess
map ,W :w !bash<CR>
" Execute the current line in ex
nnoremap ,e :exe getline(".")<CR>
" Execute the current selection in ex
map ,E :<C-w>exe join(getline("'<","'>"),'<Bar>')<CR>

map <silent> ,c :'<,'>:w !tmux load-buffer -<CR>
map ,v :r!tmux save-buffer -<CR>

" FZF Customizations
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)

map <leader>b :Buffers<cr>
map <leader>h :History<cr>
map <leader>t :Tabularize /=<cr>

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Git customization
command! -bang -nargs=* Gadd
  \ !git add -p <args> %

" Move to the middle of a line
map gm :call cursor(0, virtcol('$')/2)<CR>

highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%>80v.\+/

let g:go_highlight_types = 1
"let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_auto_sameids = 1
let g:go_version_warning = 0

filetype on
filetype plugin indent on
syntax on
set nocompatible
set mouse=a
set colorcolumn=80
set autoindent
set smartindent
set textwidth=80
set hlsearch
set showmatch
set incsearch
set scrolloff=5
set laststatus=2
"set spell spelllang=en_us
set autochdir
set encoding=UTF-8
set guifont=DroidSansMono_Nerd_Font:h14
set expandtab
" Additional vim features to optionally uncomment.
set showcmd
set showmatch
set showmode
set incsearch
set ruler
set smarttab
set hidden
"set shiftwidth=4
set diffopt+=iwhite
map <leader>K :bd<cr>
map <leader>k :bp<bar>sp<bar>bn<bar>bd<CR>
" For GitGutter, update 100 milliseconds after keyboard inputs stop
set updatetime=100

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

let g:rehash256 = 1
let g:molokai_original = 1
colorscheme molokai

" Plugin related configurations
"
" Show airline tabs at the top
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:asyncrun_status = ''
"let g:airline_section_error = airline#section#create_right(['%{g:asyncrun_status}'])

command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

" Nerdtree settings
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__', '\.DS_Store']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

" Yank current file path into register p
nmap cp :let @" = expand('%:p')<cr>

map <leader>dr :diffget REMOTE<cr>
map <leader>db :diffget BASE<cr>
map <leader>dl :diffget LOCAL<cr>

"Standup macro - dump out markdown for current days standup template
map <leader>su o# Standup<cr>:standups:<cr><cr>Steve<esc>==o<cr><esc>gl-o<cr><cr><cr>Tian<esc>==o<cr><esc>gl-o<cr><cr><cr>Mike<esc>==o<cr><esc>gl-o<cr><cr><cr><esc>

" General customizations
"
" Insert date times. Idea from http://vim.wikia.com/wiki/Insert_current_date_or_time
map <leader>dd :put =strftime('%a, %d %h %Y %H:%M:%S %z')<cr>
map <leader>dt :put =strftime('%c')<cr>
map <leader>di :r!date --iso=seconds<cr>

" fold open/closed
map <leader>fo :foldopen<cr>
map <leader>ff :foldclosed<cr>

" " Better git add shortcuts
nmap <leader>gs :Gadd<cr>
nmap <leader>gu <Plug>(GitGutterUndoHunk)
"nmap <leader>gp <Plug>(GitGutterPrevHunk)
"nmap <leader>gg <Plug>(GitGutterNextHunk)

" Save Undo persistence through sessions
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

command! DeleteTrailingWs :%s/\s\+$//
command! Untab :%s/\t/        /g

"" VimWIKI
"map <Leader>wn <Plug>VimwikiNextLink
"map <Leader>wp <Plug>VimwikiPrevLink
""let g:vimwiki_folding = "expr"
"let g:vimwiki_auto_chdir = 1
"let wiki_1 = {}
"let wiki_1.path = '/home/steve/workspace/gatsbyjs/site'
"let wiki_1.syntax = 'markdown'
"let wiki_1.ext = '.md'
"let wiki_1.auto_tags = 1
"let wiki_1.auto_toc = 1
"let wiki_1.auto_diary_index = 1
"
"let g:vimwiki_list = [wiki_1]
"let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
"
"function! VimwikiLinkHandler(link)
"  " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
"  "   1) [[vfile:~/Code/PythonProject/abc123.py]]
"  "   2) [[vfile:./|Wiki Home]]
"  let link = a:link
"  if link =~# '^vfile:'
"    let link = link[1:]
"  else
"    return 0
"  endif
"  let link_infos = vimwiki#base#resolve_link(link)
"  if link_infos.filename == ''
"    echomsg 'Vimwiki Error: Unable to resolve link!'
"    return 0
"  else
"    exe 'tabnew ' . fnameescape(link_infos.filename)
"    return 1
"  endif
"endfunction
"
"" Ideas for Vimwiki Diary stuff from: https://blog.mague.com/?p=602
"au BufRead,BufNewFile *.wiki set filetype=vimwiki
"au BufRead,BufNewFile *.md set filetype=vimwiki
autocmd BufNewFile  *.md  0r ~/.vim/templates/skeleton.md
"function! ToggleCalendar()
"      execute ":Calendar"
"      if exists("g:calendar_open")
"        if g:calendar_open == 1
"          execute "q"
"          unlet g:calendar_open
"        else
"          g:calendar_open = 1
"        end
"      else
"        let g:calendar_open = 1
"      end
"endfunction
":autocmd FileType vimwiki map <leader>c :call ToggleCalendar()<cr>
"autocmd Filetype vimwiki setlocal ts=4 sw=4 et

" Mapping to push/pull the current file to the Git remote
map <leader>wp :silent! !git add .; git commit -m "vim autocommit"; git pull; git push

"let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 3
"set conceallevel=2
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_edit_url_in = 'vsplit'


" Wikitime.vim configs
"
" Mac settings:
let g:publish_dir = '/Volumes/ssosik/public_html/notes'
let g:pandoc_bin = '/usr/local/bin/pandoc'
let g:markdownIR_pandoc_bin = '/usr/local/bin/pandoc'
let g:markdownIR_content_root = '/Users/ssosik/.local/vimdiary'
let g:markdownIR_db = '/Users/ssosik/.local/markdownIR.db'
let g:pandoc_args = '-s -f markdown+pipe_tables -t html --toc --lua-filter=/Users/ssosik/.local/pandoc/lua/links-to-html.lua --self-contained --resource-path=.'

"" Linux settings:
"let g:publish_dir = '/u4/ssosik/public_html/notes'
"let g:pandoc_bin = '/usr/bin/pandoc'
"let g:markdownIR_pandoc_bin = '/usr/bin/pandoc'
"let g:markdownIR_content_root = '/home/ssosik/workspace/vimdiary'
"let g:markdownIR_db = '/home/ssosik/.local/markdownIR.db'
"let g:pandoc_args = '-s -f markdown+pipe_tables -t html --toc --lua-filter=/home/ssosik/.local/pandoc/lua/links-to-html.lua --self-contained --resource-path=.'

let g:markdownIR_file_pattern = '%Y-%m-%dT%T%z'
let g:markdownIR_timezone = 'US/Eastern'
let g:markdownIR_file_suffix = 'md'
let g:markdownIR_default_author = 'Steve Sosik'
map <leader>w<leader>w :NewEntry<cr>
map <leader>wi :ShowIndex<cr>
map <leader>ws :SearchByDate<cr>
map <leader>wr :SearchByRelevance<cr>
map <leader>wt :GetTags<cr>

" Filter markdown links to html, idea from https://stackoverflow.com/a/49396058
let g:publish_suffix = 'html'

function! PandocPublish()
python3 << EOF
import vim
import os.path
import subprocess
import frontmatter
import re

pandoc = vim.eval('g:pandoc_bin')
args = vim.eval('g:pandoc_args')
root = vim.eval('g:publish_dir')
suffix = vim.eval('g:publish_suffix')

filename = vim.current.buffer.name

with open(filename) as f:
    post = frontmatter.load(f)
    title = post['title']
    subdir = re.sub(r'[ ]', '-', title)

fname = os.path.splitext(os.path.basename(filename))[0]
outpath = os.path.join(root, subdir)
outfile = os.path.join(outpath, fname + '.' + suffix)

try:
    os.mkdir(outpath)
except FileExistsError:
    pass
cmd = '{} {} -o {} {}'.format(pandoc, args, outfile, filename)
subprocess.check_output(cmd.split(' '))

EOF
endfunction
command! -nargs=0 PandocPublish call PandocPublish()

