return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- 1. 颜色插值工具
      local function hex_to_rgb(hex)
        hex = hex:gsub("#", "")
        return {
          tonumber(hex:sub(1, 2), 16),
          tonumber(hex:sub(3, 4), 16),
          tonumber(hex:sub(5, 6), 16)
        }
      end

      local function interpolate(c1, c2, t)
        local r1, g1, b1 = unpack(hex_to_rgb(c1))
        local r2, g2, b2 = unpack(hex_to_rgb(c2))
        local r = math.floor(r1 + (r2 - r1) * t)
        local g = math.floor(g1 + (g2 - g1) * t)
        local b = math.floor(b1 + (b2 - b1) * t)
        return string.format("#%02x%02x%02x", r, g, b)
      end

      -- 2. VSCODE 像素 Logo
      local logo = {
        [[      ██╗   ██╗ ██████╗  ██████╗  ██████╗  ██████╗  ███████╗    ]],
        [[      ██║   ██║██╔════╝ ██╔════╝ ██╔═══██╗ ██╔══██╗ ██╔════╝    ]],
        [[      ╚██╗ ██╔╝╚█████╗  ██║      ██║   ██║ ██║  ██║ █████╗      ]],
        [[       ╚████╔╝  ╚═══██╗ ██║      ██║   ██║ ██║  ██║ ██╔══╝      ]],
        [[        ╚██╔╝   ██████╔╝╚██████╗ ╚██████╔╝ ██████╔╝ ███████╗    ]],
        [[         ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝  ╚═════╝  ╚══════╝    ]],
      }

      -- 3. 调优后的色彩方案 (接近参考图的柔和渐变)
      local soft_blue   = "#5db3ff" -- 天蓝色
      local soft_purple = "#a387e0" -- 薰衣草紫
      local soft_pink   = "#e27bb0" -- 玫瑰粉

      local header_hl = {}
      for line_idx, line in ipairs(logo) do
        local line_hl = {}
        local current_byte = 0
        local _, line_chars = line:gsub('[^\128-\193]', '') 
        local char_count = 0

        for char in line:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
          char_count = char_count + 1
          local t = char_count / line_chars
          
          local color
          if t < 0.5 then
            color = interpolate(soft_blue, soft_purple, t * 2)
          else
            color = interpolate(soft_purple, soft_pink, (t - 0.5) * 2)
          end

          local hl_group = "AlphaVSCode_" .. line_idx .. "_" .. char_count
          -- 保持 bold 确保字符饱满，颜色亮度已在 hex 中下调
          vim.api.nvim_set_hl(0, hl_group, { fg = color, bold = true })
          
          local byte_len = #char
          table.insert(line_hl, { hl_group, current_byte, current_byte + byte_len })
          current_byte = current_byte + byte_len
        end
        table.insert(header_hl, line_hl)
      end

      dashboard.section.header.val = logo
      dashboard.section.header.opts.hl = header_hl

      -- 4. 按钮部分 (已添加 New file)
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
      }

      alpha.setup(dashboard.config)
    end,
  },
}
