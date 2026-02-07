return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
        "rafamadriz/friendly-snippets"
    },
    event = "VeryLazy",
    opts ={
        snippets = {
            preset = 'default',
        },
        completion = {
            documentation = {
                auto_show = true
            }
        },
        keymap = {
            preset = "super-tab",
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            providers = {
                lsp = {
                    score_offset = 100, -- 优先显示 LSP 的结果
                },
                snippets = {
                    score_offset = -1, -- 稍微降低 Snippets 的排名，避免干扰
                },
            },
        },
        cmdline = {
            keymap = {
                preset = "super-tab"
            },
            completion = {
                menu = {
                    auto_show = true
                }
            }
        }
    },
}
