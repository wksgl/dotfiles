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

        -- / 搜索过滤文件  l 打开/进入  h/Backspace 返回上级  a 新建

        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            window = {
                width = 30,
                mappings = {
                    ["/"] = "filter_on_submit",
                    ["l"] = "open",
                    ["h"] = "navigate_up",
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
                        ["h"] = "navigate_up",
                        ["<bs>"] = "navigate_up",
                    },
                },
            },
        })
    end,
}
