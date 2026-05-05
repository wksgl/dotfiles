return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                numbers = "none",
                close_command = "bdelete! %d",
                left_mouse_command = "buffer %d",
                right_mouse_command = "bdelete! %d",
                middle_mouse_command = nil,
                indicator = { style = "icon", icon = " " },
                buffer_close_icon = "󰅖",
                modified_icon = "●",
                close_icon = "󰅖",
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        })

        -- 快捷键切换标签
        vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next tab" })
        vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Prev tab" })
        vim.keymap.set("n", "<Leader>q", ":bdelete<CR>", { desc = "Close buffer" })
    end,
}
