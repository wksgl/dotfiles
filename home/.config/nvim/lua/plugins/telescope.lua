return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { 
        "nvim-telescope/telescope-fzf-native.nvim", 
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          preview = {
             treesitter = false, -- 禁用 Treesitter 预览高亮，避免 main 分支报错
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/*",
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
      })

      -- Enable telescope fzf native, if installed
      pcall(require("telescope").load_extension, "fzf")

      -- set keymaps
      local keymap = vim.keymap -- for conciseness
      local builtin = require("telescope.builtin")

      keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
      keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
      keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
      keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })
    end,
  },
}
