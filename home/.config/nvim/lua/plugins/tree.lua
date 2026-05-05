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

        -- / 搜索过滤  l 文件=打开/目录=进入  h/BS 返回上级  a 新建

        local function l_or_enter(state)
            local node = state.tree:get_node()
            local cmd = require("neo-tree.sources.filesystem.commands")
            if node.type == "directory" then
                cmd.set_root(state)
            else
                cmd.open(state)
            end
        end

        local sources_list = { "filesystem", "buffers", "git_status" }

        local function cycle_source(state)
            local current = state.name
            for i, s in ipairs(sources_list) do
                if s == current then
                    local next_src = sources_list[(i % #sources_list) + 1]
                    require("neo-tree.command").execute({ source = next_src, action = "focus" })
                    return
                end
            end
        end

        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            source_selector = {
                winbar = true,
                sources = {
                    { source = "filesystem", display_name = "   󰉓 Files " },
                    { source = "buffers", display_name = "   󰈚 Buffers " },
                    { source = "git_status", display_name = "    Git " },
                },
            },
            window = {
                width = 30,
                mappings = {
                    ["/"] = "filter_on_submit",
                    ["l"] = l_or_enter,
                    ["h"] = "navigate_up",
                    ["<bs>"] = "navigate_up",
                    ["<Tab>"] = cycle_source,
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
                        ["l"] = l_or_enter,
                        ["h"] = "navigate_up",
                        ["<bs>"] = "navigate_up",
                        ["<Tab>"] = cycle_source,
                    },
                },
            },
        })
    end,
}
