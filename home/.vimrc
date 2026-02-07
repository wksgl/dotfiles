"不兼容vi
set nocompatible
"显示正在输入的命令
set showcmd
"显示光标位置
set ruler
"显示行号
set number
"显示相对行号
set relativenumber
"高亮当前行
set cursorline
"语法高亮
syntax on 
"启用文件类型检测和插件
filetype plugin indent on
"tab显示为4个空格
set tabstop=4
"自动缩进4
set shiftwidth=4

set laststatus=2
set backspace=indent,eol,start
" 开启自动缩进，新的一行会自动与上一行对齐
set smarttab
set smartindent
set autoindent
"高亮搜索
set hlsearch
" 在输入搜索词时，实时高亮显示匹配项（增量搜索）
set incsearch
" 高亮显示所有搜索结果
set hlsearch
" 搜索时忽略大小写
set ignorecase
" 如果搜索词中包含了大写字母，则自动切换为大小写敏感搜索
set smartcase
" 开启持久化撤销（undo），即使关闭再打开文件，也能撤销之前的更改
set undofile
"====================================
"C语言编译配置
"====================================

"gcc作为make工具
set makeprg=gcc\ -Wall\ -Wextra\ -g\ -O0\ %

"F5: 编译 + 运行当前C文件
nnoremap <F5> :!gcc -Wall -Wextra -g -O0 % -o %< && ./%<<CR>

" F6：只编译（不运行）
nnoremap <F6> :!gcc -Wall -Wextra -g -O0 % -o %<<CR>

" F7：make + 打开错误列表
nnoremap <F7> :make<CR>:copen<CR>

" ================================
" Quickfix（错误跳转）
" ================================
nnoremap <C-n> :cn<CR>       " 下一个错误
nnoremap <C-p> :cp<CR>       " 上一个错误
nnoremap <Leader>q :cclose<CR>

" ================================
" C 文件专属设置
" ================================
autocmd FileType c setlocal
    \ cindent
    \ noexpandtab

" undo目录
silent !mkdir -p ~/.cache/vim/undo
set undodir=~/.cache/vim/undo

" 剪贴板 gvim的功能
set clipboard=unnamedplus

" 接管鼠标事件
set mouse=a

" 加载本地私有配置（不提交到Git）
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif

