return {
    -- 主题 1: TokyoNight (当前关闭)
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        enabled = true, -- 想用它就把这里改成 true，把下面的改成 false
        config = function()
            require("tokyonight").setup()
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- 主题 2: Catppuccin (当前开启)
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        enabled = false, -- 当前生效
        config = function()
            require("catppuccin").setup({ flavour = "mocha" })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    
    -- 主题 3: Gruvbox (备用)
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        enabled = false,
        config = function()
            vim.cmd.colorscheme("gruvbox")
        end,
    }
}

