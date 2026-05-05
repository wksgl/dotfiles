return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
        require("bufferline").setup {
            options = {
                mode = "buffers",
                numbers = "none",
                close_command = "bdelete! %d",
                right_mouse_command = "bdelete! %d",
                left_mouse_command = "buffer %d",
                middle_mouse_command = nil,
                indicator = {
                    icon = '▎',
                    style = 'icon',
                },
                buffer_close_icon = '󰅖',
                modified_icon = '●',
                close_icon = '',
                left_trunc_marker = '',
                right_trunc_marker = '',
                max_name_length = 18,
                max_prefix_length = 15,
                tab_size = 18,
                diagnostics = "nvim_lsp",
                diagnostics_update_in_insert = false,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true
                    }
                },
                color_icons = true,
                show_buffer_icons = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                persist_buffer_sort = true,
                separator_style = "thin",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
            }
        }

        if vim.bo.filetype == "alpha" then
            vim.opt.showtabline = 0
        end

        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
        if normal_bg then
            vim.api.nvim_set_hl(0, "BufferLineFill", { bg = normal_bg })
            vim.api.nvim_set_hl(0, "TabLineFill", { bg = normal_bg })
        end

        vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer (Tab)" })
        vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer (Tab)" })
        vim.keymap.set("n", "<Leader>b>", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })
        vim.keymap.set("n", "<Leader>b<", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })

        for i = 1, 9 do
            vim.keymap.set("n", "<A-" .. i .. ">", "<Cmd>lua require('bufferline').go_to(" .. i .. ", true)<CR>", { desc = "Go to Buffer " .. i })
        end

        vim.keymap.set("n", "<Leader>c", "<Cmd>bdelete<CR>", { desc = "Close Buffer" })
        vim.keymap.set("n", "<Leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Close Other Buffers" })
        vim.keymap.set("n", "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Close Buffers to the Right" })
        vim.keymap.set("n", "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Close Buffers to the Left" })
    end
}
