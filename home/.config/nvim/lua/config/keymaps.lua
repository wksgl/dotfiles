
-----------------------------------------------------------
-- C语言 编译/调试 配置 (Lua 版)
-----------------------------------------------------------
-- 1. 设置 makeprg (对应 set makeprg=...)
-- 注意：在 Lua 中，不需要反斜杠转义空格，直接用引号包起来即可
vim.opt.makeprg = "gcc -Wall -Wextra -g -O0 %"
-- 2. 快捷键映射
-- 语法：vim.keymap.set('模式', '按键', '命令', {配置})
-- 'n' 代表 Normal 模式 (对应 nnoremap)
-- F5: 编译 + 运行 (优化版：右侧分屏 + 自动聚焦输入)
vim.keymap.set('n', '<F5>', function()
    -- 1. 保存当前文件
    vim.cmd('w')
    -- 2. 垂直分屏
    vim.cmd('vsp')
    -- 3. 在新窗口启动终端并运行编译命令
    -- 使用 lua 拼接字符串，比纯 vim 命令更稳定
    local cmd = 'gcc -Wall -Wextra -g -O0 ' .. vim.fn.expand('%') .. ' -o ' .. vim.fn.expand('%<') .. ' && ./' .. vim.fn.expand('%<')
    vim.cmd('term ' .. cmd)
    
    -- 5. 【关键】自动进入插入模式，光标直接对准输入框
    vim.cmd('startinsert')
end, { silent = true })

-- F6: 只编译
vim.keymap.set('n', '<F6>', ':!gcc -Wall -Wextra -g -O0 % -o %<<CR>', { silent = false })
-- F7: 调用 make (使用上面的 makeprg 设置) 并打开错误列表 (Quickfix)
vim.keymap.set('n', '<F7>', ':make<CR>:copen<CR>', { silent = true })
-----------------------------------------------------------
-- Quickfix 窗口导航 (错误跳转)
-----------------------------------------------------------
vim.keymap.set('n', '<C-n>', ':cn<CR>', { silent = true })      -- 下一个错误
vim.keymap.set('n', '<C-p>', ':cp<CR>', { silent = true })      -- 上一个错误
-- 关于 <Leader> 键：
-- Neovim 默认的 Leader 键是反斜杠 \
-- 如果你想改成空格（现在的流行做法），取消下面这行的注释：

vim.keymap.set('n', '<Leader>q', ':cclose<CR>', { silent = true }) -- 关闭错误窗口
-----------------------------------------------------------
-- C 文件专属设置 (Autocmd 自动命令)
-----------------------------------------------------------
-- 对应以前的 autocmd FileType c setlocal ...
-- Lua 写法更结构化，不会因为重复加载配置而导致多次绑定
vim.api.nvim_create_autocmd("FileType", {
    pattern = "c", -- 针对 c 语言文件
    callback = function()
        -- setlocal 在 Lua 中写作 vim.opt_local
        vim.opt_local.cindent = true      -- 开启 C 语言风格缩进
        vim.opt_local.expandtab = false   -- 不将 Tab 转换为空格 (保留 Tab 字符)
        
        -- 你也可以在这里加更多针对 C 的设置，比如：
        -- vim.opt_local.tabstop = 4
    end,
})

-----------------------------------------------------------
-- LSP 快捷键配置 (LspAttach 自动触发)
-----------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        
        -- <leader>gd: 跳转到定义
        vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
        
        -- <leader>gr: 列出引用 (使用 Telescope)
        vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, opts)
        
        -- <leader>rn: 重命名符号
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        
        -- <leader>ca: 代码修复/Code Action (支持 Normal 和 Visual 模式)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    end,
})
