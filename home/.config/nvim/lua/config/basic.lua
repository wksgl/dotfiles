-----------------------------------------------------------
-- 1. 基础选项 (对应以前的 set xxx)
-----------------------------------------------------------
-- 也就是 vim.opt.选项 = 值
vim.g.mapleader = " "
-- 开启行号
vim.opt.number = true
-- 开启相对行号 (可选，很适合跳转)
vim.opt.relativenumber = true
-- 高亮当前行
vim.opt.cursorline = true
-- 缩进设置 (4个空格)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- 自动重载
vim.opt.autoread = true
-- 鼠标支持 (a 表示所有模式)
vim.opt.mouse = 'a'
-- 禁用旧版兼容模式 (Neovim 默认就是关闭的，但写上无妨)
vim.opt.compatible = false
-- 忽略文件
vim.opt.wildignore = {'*.a', '*.o', '__pycache__'}

vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 设置数字增加对象 <C-a>数字/字母+1 <C-x>数字/字母-1
vim.opt.nrformats = "bin,hex,alpha"
-- 增加屏蔽项
vim.opt.shortmess:append("sIc")
--针对makefile等设置，显示不可见字符
--vim.opt.listchars = { space = '_', tab = '>~' }
--vim.opt.list = true
vim.opt.termguicolors = true
-- 排版助手 t控制自动换行 n控制识别列表 j控制智能合并注释
vim.opt.formatoptions = { n = true, j = true, t = true }

vim.opt.splitright = true
vim.opt.splitbelow=true

-----------------------------------------------------------
-- 2. 系统剪贴板
-----------------------------------------------------------
-- Neovim 会自动寻找 xclip (X11) 或 wl-clipboard (Wayland)
-- 只要你装了这两个包之一，下面这行就能打通系统剪贴板
vim.opt.clipboard = "unnamedplus"

-----------------------------------------------------------
-- 3. 语法高亮
-----------------------------------------------------------
-- 开启基础语法高亮
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

