" Keep this at the top of the file
set nocompatible

" General Settings
set backspace=2         " allow backspacing over everything in insert mode
set cscopetagorder=1    " check tags file before cscope
set cscopetag           " search cscope on ctrl-] and :tag
set history=1000        " keep 1000 lines of command line history
"set listchars=tab:»·,trail:·    " how to display some special chars
set report=0            " threshold for reporting nr. of lines changed
set ruler               " show the cursor position all the time
set shortmess+=at       " list of flags, reduce length of messages
set showcmd             " show (partial) command in status line
set showmode            " message on status line to show current mode
set showmatch           " briefly jump to matching bracket
set nowarn              " don't warn for shell command when buffer changed
set wildmode=longest,list,full

" Statusline thanks to Ciaran
set laststatus=2        " always show a status line (with the current filename)
set statusline=
set statusline+=%-3.3n\                      " buffer number
set statusline+=%f\                          " file name
set statusline+=%h%m%r%w                     " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=0x%-8B\                      " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

" Tabs and Indents
set autoindent
set comments+=b:##      " add ## as a potential comment leader
set expandtab
" formatoptions are in the order presented in fo-table
set formatoptions+=t    " auto-wrap using textwidth (not comments)
set formatoptions+=c    " auto-wrap comments too
set formatoptions+=r    " continue the comment header automatically on <CR>
set formatoptions+=o    " insert the current comment leader with 'o' or 'O'
set formatoptions+=q    " allow formatting of comments with gq
set formatoptions-=w    " double-carriage-return indicates paragraph
set formatoptions-=a    " don't reformat automatically
set formatoptions+=n    " recognize numbered lists when autoindenting
set formatoptions+=2    " use second line of paragraph when autoindenting
set formatoptions-=v    " don't worry about vi compatiblity
set formatoptions-=b    " don't worry about vi compatiblity
set formatoptions+=l    " don't break long lines in insert mode
set formatoptions+=1    " don't break lines after one-letter words, if possible
set shiftround          " round indent < and > to multiple of shiftwidth
set shiftwidth=4
set smarttab            " use shiftwidth when inserting <TAB>
set tabstop=8           " number of spaces that <Tab> in file uses
set textwidth=80        " by default, although plugins or autocmds can modify

" Search settings
set incsearch           " show matches while still typing pattern
set nohlsearch          " don't highlight matches after they're found
set ignorecase          " "foo" matches "Foo", etc
set smartcase           " ignorecase only when the pattern is all lower

" Syntax and filetypes
let g:bash_is_sh=1
syntax on
filetype on
filetype plugin on
filetype indent on

" Windowing settings
set equalalways         " keep windows equal when splitting (default)
set eadirection=hor     " ver/hor/both - where does equalalways apply

set background=dark

" Setup the ~/.vim directory
if (!isdirectory($HOME."/.vim"))
  call system("mkdir -p $HOME/.vim/bak $HOME/.vim/swap")
endif
if (isdirectory($HOME."/.vim/bak"))
  set backup
  set backupdir=~/.vim/bak,.
  set backupext=''
endif
if (isdirectory($HOME."/.vimswap"))
  set directory=~/.vimswap,.
endif
if (isdirectory($HOME."/.viminfo"))
  set viminfo='50,n~/.viminfo/viminfo
  let $CVIMSYN='~/.vim/'
endif

" Command line editing, emacs style (See ":help <>")
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <ESC>b <S-Left>
cnoremap <ESC>f <S-Right>
cnoremap <ESC><C-H> <C-W>

" Toggle list mode
map ,l  :set nolist<CR>
map ,L  :set list<CR>

" Reformat current paragraph
nmap Q }{gq}
vmap Q gq 

" Add support for html tidy
map ,t  :%!tidy -q --indent auto --output-xhtml yes<CR>
map ,T  :%!tidy -q --indent auto -xml<CR>
map ,ct :%!tidy -q --clean --indent auto -xml<CR>

" command line editing, emacs style (See ":help <>")
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <ESC>b <S-Left>
cnoremap <ESC>f <S-Right>
cnoremap <ESC><C-H> <C-W>

" Vimdiff mappings
noremap ,dp :diffput<CR>
noremap ,dg :diffget<CR>
noremap ,du :diffupdate<CR>

"=================================== GPG ===================================
" Decrypts the current buffer and displays any stderr in a new split
function! GPGDecryptWindow() 
  let t = tempname()
  exec '%!gpg 2>' t
  exec 'sp' t
  setlocal buftype=nofile
  if winheight(0) > line('$')
    exec 'resize' line('$')
  endif
  noremap <buffer> <SPACE> <C-W>p
  wincmd p
  exec "au BufLeave" t "call delete('".t."') | close"
endfunc

" GPG bindings
noremap <C-p>s :%!gpg      --clearsign         2>/dev/null<CR>
noremap <C-p>e :%!gpg --encrypt        --armor 2>/dev/null<CR>
noremap <C-p>b :%!gpg --encrypt --sign --armor 2>/dev/null<CR>
noremap <C-p>d :call GPGDecryptWindow()<CR>

" GPG autocmds
augroup gpg
  au!

  " Read and write gpg files
  au BufReadPost  *.gpg  call GPGDecryptWindow()|set nomod noswapfile|wincmd p
  au BufWritePre  *.gpg  %y z | %!gpg -r$USER --encrypt --armor 2>/dev/null
  au BufWritePost *.gpg  %d | normal "zP"zy0
  au BufWritePost *.gpg  set nomod
augroup END

"=================================== MAIL ==================================
" Load mutt aliases as insert-abbreviations
function! AliasAbbr(f)
  if filereadable(a:f)
    exe "new " . a:f
    silent %s/^alias/iab <buffer>/
    global/^alias/yank z
    q!
    silent @z
  endif
endfunction

" Helps in navigation of email headers
function! MailHeaderCmd(headcmd, normalchar)
  if a:headcmd == 0
    let headstr = "}o\<ESC>"
  elseif a:headcmd == 1
    let headstr = "/^[-A-Za-z]*:\<CR>A \<ESC>$"
  endif
  if getline(line(".")) =~ "^[-A-Za-z]*: "
    exe "normal! " . headstr
    return ''
  else
    return a:normalchar
  endif
endfunction

" Set up mail header navigation and load aliases as abbreviations
function! LoadTypeMail()
  map      <buffer> <tab> /^[-A-Za-z]*:<CR>A
  inoremap <buffer> <tab> <C-R>=MailHeaderCmd(1, "\t")<CR>
  inoremap <buffer> }     <C-R>=MailHeaderCmd(0, "}")<CR>
  call AliasAbbr("~/.muttrc-zk3aliases")
  call AliasAbbr("~/.muttrc-aliases")
  set tw=70
endfunction

augroup mail
  au!
  au FileType     mail     call LoadTypeMail()
augroup END

"==================================== C ====================================
" Chouser's experimental errorformat for Tru64
function! SetTru64Errorformat()
  " clear the default because most of it is unnecessary
  set errorformat=''

  " now add back in the default (from 6.0w, anyway) for GNU Make
  set errorformat+=%D%*\\a[%*\\d]:\ Entering\ directory\ `%f'
  set errorformat+=%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f'
  set errorformat+=%DMaking\ %*\\a\ in\ %f

  " add in chouser's hand-made Tru64 matches
  " note that vim gets the column wrong when there are tabs in the source code
  set errorformat+=%Wcc:\ Warning:\ %f\\,\ line\ %l:\ %m
  set errorformat+=%Ecc:\ Error:\ %f\\,\ line\ %l:\ %m
  set errorformat+=%Z%p^

  " now match all other lines and throw them away
  set errorformat+=%-G%*[^!]
endfunction

" Default options for C files
function! LoadTypeC()
  set formatoptions-=tc " don't wrap text or comments automatically
  set cindent
  set cinoptions=(0,u0,t0,l1
  iab <buffer> #i #include
  iab <buffer> #d #define

  " CTX scope context for C files; emerge app-vim/ctx
  set updatetime=500
  let CTX_minrows=1
  let CTX_maxrows=1

  " Reformat long #defines
  vnoremap ,c :'<,'>perldo s/(.*?) *\\*$/$1.(' 'x(79-length $1)).'\\'/e
endfunction

" Add support for various types of cscope searches based on the current word
if (has("cscope"))
  noremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>i :cs find i <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
  noremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
endif

" Set errorformat
let OS = system("uname -s")
if (OS =~ "OSF1")
  call SetTru64Errorformat()
endif

augroup c
  au!
  au FileType     c,cpp    call LoadTypeC()
augroup END

"=================================== XML ===================================
function! LoadTypeXML()
  " TODO: figure out how to use this: source ~/viml/closetag.vim
  syntax cluster xmlRegionHook add=SpellErrors,SpellCorrected
endfunction

augroup xml
  au!
  au FileType     html,xml call LoadTypeXML()
augroup END

"================================= GENERAL =================================
" Detect settings of file being edited and change ours to match
function! DetectSettings()
    " if any lines begin with <tab>, assume that's what we want to do
    if search("^\t", 'w') > 0
        setlocal noexpandtab
    endif
    1

    " placeholder to respond to emacs-style file format tags
    "--EMACS--
endfunction

augroup general
  au!
  " detect settings of file being edited and change ours to match
  au BufReadPost  *      call DetectSettings()

  " for crontab -e
  au BufWritePre   */tmp/* set backupcopy=yes
  au BufWritePost  */tmp/* set backupcopy=auto
augroup END

""""""""""""""""""""""""""""""""""
" mine
autocmd BufEnter *.php call PHPFunctionSearching()
autocmd BufEnter *.pl call PerlFunctionSearching()
autocmd BufEnter *.vbs call VBSFunctionSearching()

" http://vimrc-dissection.blogspot.com/2006/09/vim-7-re-turn-off-parenparenthesiswhat.html
let loaded_matchparen = 1

let mapleader = ","

" Always change vim's current working dir to where the file in the buffer
" lives
autocmd BufEnter * call Change_Curr_Dir()

" Let the syntax highlighting know the background is dark, so it will use
" colors that are more visible.
autocmd BufEnter * set background=dark

" personal settings
set wildmenu
set cmdheight=2
set scrolloff=5
set noignorecase
set matchpairs+=<:>

" Speed up for vim7
set complete-=t

set mouse=""
set backup
set writebackup
set modeline modelines=5 " set to insecure /* vim:shiftwidth=4 */
set tags=tags;/

set directory=~/.swp//,.
if (!isdirectory($HOME."/.swp"))
  !mkdir "$HOME/.swp"
endif
set backupdir=~/.bak,.
if (!isdirectory($HOME."/.bak"))
  !mkdir "$HOME/.bak"
endif
set backupext=''

" c indenting options (borrowed from bobbell)
  set cinoptions=(0,u0,t0,*50	" My style, strict HP-UX would include :0

" personal abbreviations to correct my recurring misspellings
iab tihs this
iab teh the
iab apparrent apparent
iab aparrent apparent
iab apparrant apparent
iab woudl would

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key Bindings                                         "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" if this is a vimdiff session, use 
" * F6 to re-do all folding so everything is pretty and lined up
if (&diff)
    vmap <F6> zX
    nmap <F6> zX
endif

function! VBSFunctionSearching()
  vmap ]] :set ic<CR>mz/^[ \t]*function[ \t]<CR>:set noic<CR>
  nmap ]] :set ic<CR>mz/^[ \t]*function[ \t]<CR>:set noic<CR>
  vmap [[ :set ic<CR>mz?^[ \t]*function[ \t]<CR>:set noic<CR>
  nmap [[ :set ic<CR>mz?^[ \t]*function[ \t]<CR>:set noic<CR>
endfunction

function! PerlFunctionSearching()
  vmap ]] mz/^[ \t]*sub[ \t]<CR>
  nmap ]] mz/^[ \t]*sub[ \t]<CR>
  vmap [[ mz?^[ \t]*sub[ \t]<CR>
  nmap [[ mz?^[ \t]*sub[ \t]<CR>
endfunction

function! PHPFunctionSearching()
  vmap ]] mz/^[ \t]*function[ \t]<CR>
  nmap ]] mz/^[ \t]*function[ \t]<CR>
  vmap [[ mz?^[ \t]*function[ \t]<CR>
  nmap [[ mz?^[ \t]*function[ \t]<CR>
endfunction

" use F6 to print full path of current file
vmap <F6> :echo expand ("%:p")<CR>
nmap <F6> :echo expand ("%:p")<CR>
" use F7 to obfuscate email addresses
vmap <F7> :call Obfuscate_Email_Addrs()<CR>
nmap <F7> :call Obfuscate_Email_Addrs()<CR>
" use F8 to spam-proof all email addresses
vmap <F8> :call No_Email_Addrs()<CR>
nmap <F8> :call No_Email_Addrs()<CR>
" use F9 to delete EOL Whitespace
vmap <F9> :call No_EOL_Whitespace()<CR>
nmap <F9> :call No_EOL_Whitespace()<CR>

" Always move around by screen lines
vmap j gj
nmap j gj
vmap k gk
nmap k gk

" set cscope keybindings
if (has("cscope"))
    " Key binding for various types of cscope searches based on the current word
    noremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>i :cs find i <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    noremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Changes the current directory to the location of the file in the current
" buffer.
function! Change_Curr_Dir()
  let _dir = fnameescape(expand("%:p:h"))
  exec "cd " . _dir
  unlet _dir
endfunction

function! Settings_By_Path()
  
endfunction

function! TEST_FILETYPE()
    if ( &filetype == "mail" )
        " you're editing mail - change the colorscheme so you can read the
        " stinkin' thing.
        colorscheme default
    "else
        "colorscheme default
    endif
endfunction

" toggles between showing tabs and trailing whitespace and not
function! List_Toggle()
"    if (exists("&list"))
    if (&list)
"        echo "list exists"
        set nolist
    else
"        echo "list does not exist"
        set list
    endif
endfunction

function! TryGeneralCscope()
    if (has("cscope"))
	"
	" Maybe there is a local cscope.out or cscope.db laying around.
	" Start with the current working directory, and walk up the directory
	" tree until cscope.out or cscope.db is found or we reach the root
	" directory.
	"
	" To build this database (for a standalone project):
	"   find . -name '*.[ch]' > cscope.files
	"   cscope -b
	"   rm cscope.files
	"
	let dir = getcwd()
	while( dir != "/" )
	    if filereadable(dir . "/cscope.out")
		exe 'cscope add '.dir.'/cscope.out '.dir
		echo "using cscope database: ".dir."/cscope.out"
		break
	    elseif filereadable(dir . "/cscope.db")
		exe 'cscope add '.dir.'/cscope.db '.dir
		echo "using cscope database: ".dir."/cscope.db"
		break
            else
                echo "no cscope file in ".dir
	    endif
	    let dir = fnamemodify(dir,":h")         " remove last directory name
	endwhile
    endif
endfunction

function! No_EOL_Whitespace()
  :%sub/[ \t]\+$//g
  echo "deleted all end-of-line whitespace"
endfunction

function! Obfuscate_Email_Addrs()
  :%s/\([A-z0-9_\-.]*\)@\([A-z0-9_\-.]*\)/\1 -AT- \2/gc
  echo "obfuscated email addresses"
endfunction

" source local settings
if filereadable($HOME."/.vim/.vimrc.local")
  source ~/.vim/.vimrc.local
endif

execute pathogen#infect()

" vim:set sw=2:

