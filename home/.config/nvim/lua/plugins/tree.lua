return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        vim.keymap.set("n", "<Leader><Tab>", ":Neotree toggle<CR>", { desc = "Toggle file tree", silent = true })

        -- / 在树中搜索过滤文件名
        -- H 返回根目录
        -- <BS> 返回上级目录
        -- <CR> 打开文件
        -- a 新建文件/目录

        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            window = {
                width = 30,
                mappings = {
                    ["/"] = "filter_on_submit", -- 搜索过滤文件
                    ["H"] = "navigate_up",
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["<bs>"] = "navigate_up",
                },
            },
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                window = {
                    mappings = {
                        ["/"] = "filter_on_submit",
                        ["<bs>"] = "navigate_up",
                    },
                },
            },
        })
    end,
}
