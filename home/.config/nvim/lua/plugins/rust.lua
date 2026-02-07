return {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    -- [关键修复 1] 显式声明依赖，确保 blink.cmp 在 rustaceanvim 之前或同时被索引
    dependencies = { "saghen/blink.cmp" }, 
    
    config = function()
        vim.g.rustaceanvim = {
            server = {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
                on_attach = function(client, bufnr)
                    vim.notify("Rust LSP attached!", vim.log.levels.INFO)
                end,

                default_settings = {
                    ['rust-analyzer'] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            buildScripts = { enable = true },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                    },
                },
            },
        }
    end,
}

