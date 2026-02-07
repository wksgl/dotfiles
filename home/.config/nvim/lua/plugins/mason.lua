return {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",
    },
    opts = {
        ensure_installed = {
            "lua_ls",
            "pyright",
            "clangd",
            "rust_analyzer",
        },
    },
    config = function(_, opts)
        -- 获取 blink.cmp 的补全能力支持
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- 1. 启动 Mason
        require("mason").setup()

        -- 2. 预先配置 LSP
        vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            }
        })
        
        vim.lsp.config('clangd', {
             capabilities = capabilities,
             cmd = {
                 "clangd",
                 "--background-index",
                 "--clang-tidy",
                 "--header-insertion=iwyu",
                 "--completion-style=detailed",
                 "--function-arg-placeholders",
                 "--fallback-style=llvm",
             },
             init_options = {
                 usePlaceholders = true,
                 completeUnimported = true,
                 clangdFileStatus = true,
             },
         })

        vim.lsp.config('pyright', {
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic",
                    }
                }
            }
        })

        -- 3. 启动 Mason-LSPConfig
        require("mason-lspconfig").setup({
            ensure_installed = opts.ensure_installed,
            automatic_enable = true,
        })

        -- 4. 全局诊断样式配置
        vim.diagnostic.config({
            virtual_text = true,
        })
    end
}

