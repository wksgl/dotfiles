return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- 紧跟最新架构
    lazy = false,
    config = function()
        -- 1. 初始化插件
        local nvim_treesitter = require("nvim-treesitter")
        -- main 分支的 setup 通常不需要参数，或者参数极少
        pcall(nvim_treesitter.setup)

        -- 2. 定义核心需要的 Parser
        local ensure_installed = {
            "bash", "c", "lua", "markdown", "markdown_inline",
            "query", "vim", "vimdoc", "toml", "yaml"
        }

        -- 3. 智能安装逻辑
        for _, parser in ipairs(ensure_installed) do
            -- 使用原生 API 检测，如果报错则说明未安装
            -- inspect 可能会报错，所以用 pcall 包裹
            local installed, _ = pcall(vim.treesitter.language.inspect, parser)

            if not installed then
                vim.notify("SRE: Auto-installing parser: " .. parser, vim.log.levels.INFO)
                -- 异步安装
                nvim_treesitter.install(parser)
            end
        end

        -- 4. 启动高亮（SRE 鲁棒模式）
        -- 不使用 pattern 限制，而是监听所有 FileType。
        -- 这样无论你是自动安装的，还是手动 :TSInstall 的，只要有 parser 就能高亮。
        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                -- 尝试启动 treesitter
                local ok = pcall(vim.treesitter.start)
                if ok then
                    -- 只有启动成功了，才设置折叠和缩进，避免报错
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo.foldenable = false
                end
            end,
        })
        -- 5. 补刀：手动触发一次 FileType
        -- 防止 Lazy 加载太晚，当前打开的文件没赶上 Autocmd
        vim.api.nvim_exec_autocmds("FileType", {})
    end,
}