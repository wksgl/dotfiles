return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function ()
        local api = require("nvim-tree.api")

        require("nvim-tree").setup {
            view = {
                width = 40,
                side = "left",
            },
            renderer = {
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "▶",
                            arrow_open = "▼",
                        },
                    },
                },
            },
            actions = {
                open_file = {
                    quit_on_open = true,  -- 打开文件后退出树窗口
                    window_picker = {
                        enable = true,
                    },
                },
            },
            filters = {
                dotfiles = false,  -- 显示点文件
            },
        }

        -- 全局映射：Leader+Tab 切换 nvim-tree
        vim.keymap.set("n", "<Leader><Tab>", api.tree.toggle, { desc = "Toggle nvim-tree", noremap = true, silent = true })
    end
}
