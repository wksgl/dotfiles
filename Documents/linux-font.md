# Linux字体渲染优化方案
## Arch Linux + niri桌面环境优化指南

**日期**: 2026-01-04
**系统**: Arch Linux
**桌面**: niri (Wayland)
**显示器**: 1920x1080 @ 240Hz
**问题**: VSCode和Firefox轻微模糊，不如Windows ClearType清晰

---

## 📏 缩放建议（针对1920x1080分辨率）

### 推荐设置：`scale 1.0`（100%）

| 显示器尺寸 | PPI估算 | 推荐缩放 | 说明 |
|------------|---------|----------|------|
| 24英寸 | ~92 PPI | **1.0** | 无需缩放，100%最清晰 |
| 27英寸 | ~82 PPI | **1.0** | 无需缩放 |
| 小于24英寸 | >96 PPI | 1.1-1.25 | 轻微放大改善可读性 |

**结论**：对于1080p分辨率，**不建议使用缩放**。模糊主要是字体渲染问题，与Windows ClearType对比的差异。

---

## 🎯 核心问题：字体渲染优化

Linux默认字体渲染不如Windows ClearType锐利，尤其在LCD屏幕上。需要手动优化：

---

## 方案一：启用FreeType2子像素渲染（最关键）

### 步骤：
1. 编辑 `/etc/profile.d/freetype2.sh`：
   ```bash
   sudo nano /etc/profile.d/fetype2.sh
   ```

2. 取消注释并修改为：
   ```bash
   export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
   ```

### 解释：
- `interpreter-version=35`：经典模式（默认）
- `interpreter-version=40`：**子像素渲染模式**（类似ClearType）
- `interpreter-version=38`：Infinality风格

### 生效方式：
- **重启会话**或重新登录生效
- 临时测试：
  ```bash
  export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
  # 然后启动应用程序测试
  ```

---

## 方案二：优化Fontconfig渲染设置

### 步骤：
1. 创建 `~/.config/fontconfig/conf.d/10-font-rendering.conf`：
   ```bash
   mkdir -p ~/.config/fontconfig/conf.d
   nano ~/.config/fontconfig/conf.d/10-font-rendering.conf
   ```

2. 添加以下内容：
   ```xml
   <?xml version="1.0"?>
   <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
   <fontconfig>
     <!-- 抗锯齿 -->
     <match target="font">
       <edit name="antialias" mode="assign"><bool>true</bool></edit>
     </match>

     <!-- Hinting设置 -->
     <match target="font">
       <edit name="hinting" mode="assign"><bool>true</bool></edit>
       <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
     </match>

     <!-- 次像素渲染（假设LCD为RGB排列）-->
     <match target="font">
       <edit name="rgba" mode="assign"><const>rgb</const></edit>
       <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
     </match>

     <!-- 中文字体微调 -->
     <match target="pattern">
       <test name="family"><string>Source Han Sans CN</string></test>
       <test name="family"><string>Source Han Serif CN</string></test>
       <test name="family"><string>Noto Sans CJK SC</string></test>
       <edit name="antialias" mode="assign"><bool>true</bool></edit>
       <edit name="hinting" mode="assign"><bool>true</bool></edit>
     </match>
   </fontconfig>
   ```

3. 刷新字体缓存：
   ```bash
   fc-cache -fv
   ```

---

## 方案三：设置环境变量（临时测试）

### 测试组合：
```bash
# 测试组合1：轻微缩放+字体优化
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
export GDK_SCALE=1.1
export GDK_DPI_SCALE=0.9  # 组合使用防止过大

# 测试组合2：仅字体优化
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
unset GDK_SCALE GDK_DPI_SCALE

# 启动应用测试
MOZ_ENABLE_WAYLAND=1 firefox &
code --enable-features=UseOzonePlatform --ozone-platform=wayland &
```

---

## 🔧 应用程序特定优化

### Firefox（Wayland模式已验证）
#### about:config 设置：
```
gfx.canvas.accelerated = true
gfx.webrender.all = true
gfx.webrender.enabled = true
layout.css.devPixelsPerPx = 1.0  # 保持1.0，用系统缩放
```

#### 字体渲染优化：
```
browser.display.use_document_fonts = 0  # 禁用网页字体（测试用）
gfx.font_rendering.cleartype_params.rendering_mode = 5
```

### VSCode
#### Wayland模式启动：
```bash
code --enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto
```

#### 如果Wayland模式有问题：
```bash
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
export GDK_SCALE=1.0
code &
```

#### VSCode设置（settings.json）：
```json
{
    "window.zoomLevel": 0,
    "editor.fontFamily": "JetBrains Maple Mono, monospace",
    "editor.fontSize": 14,
    "editor.fontLigatures": true,
    "editor.fontWeight": "400"
}
```

---

## 🧪 验证和测试步骤

### 1. 验证当前渲染状态
```bash
# 检查FreeType设置
echo $FREETYPE_PROPERTIES

# 检查字体渲染细节
fc-match --verbose sans-serif | grep -E "antialias|hintstyle|rgba"

# 检查应用程序Wayland状态
echo $XDG_SESSION_TYPE
```

### 2. A/B测试方法
```bash
# 终端A：优化前
unset FREETYPE_PROPERTIES
firefox &

# 终端B：优化后
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
firefox --new-instance &

# 并排打开 https://www.typekit.com/ 测试字体渲染
```

### 3. 快速恢复默认
```bash
# 清除所有优化设置
unset FREETYPE_PROPERTIES GDK_SCALE GDK_DPI_SCALE
rm -f ~/.config/fontconfig/conf.d/10-font-rendering.conf
fc-cache -fv
```

---

## 📊 预期改善程度

| 优化项目 | 改善程度 | 生效时间 |
|----------|----------|----------|
| FreeType解释器v40 | ★★★★★（显著） | 立即 |
| Fontconfig次像素渲染 | ★★★★☆ | 立即 |
| GDK缩放微调 | ★★☆☆☆ | 立即 |
| 应用程序设置 | ★★★☆☆ | 重启应用 |

---

## 🚀 推荐执行顺序

1. **先测试FreeType优化**（方案一）→ 效果最明显
2. **添加Fontconfig配置**（方案二）→ 进一步优化
3. **按需调整环境变量**（方案三）→ 微调
4. **应用程序优化** → 最后调整

**关键提示**：Linux字体渲染永远达不到Windows ClearType的**完全相同**效果，但通过上述优化可以**接近90-95%**的清晰度。

---

## ⚠️ 常见问题

### 1. 优化后字体太细/太粗
```bash
# 尝试不同解释器版本
export FREETYPE_PROPERTIES="truetype:interpreter-version=38"  # 稍粗
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"  # 标准
```

### 2. 部分应用无效果
- **GTK2应用**：需要单独配置
- **Java应用**：添加 `-Dawt.useSystemAAFontSettings=on`

### 3. 重启后失效
```bash
# 确保修改了 /etc/profile.d/freetype2.sh
# 并重新登录会话
```

### 4. 检查当前配置
```bash
# 检查当前生效的设置
fc-match --verbose sans-serif | head -30
# 检查FreeType版本
freetype-config --version 2>/dev/null || pacman -Q freetype2
```

---

## 📁 相关配置文件

| 文件路径 | 用途 |
|----------|------|
| `/etc/profile.d/freetype2.sh` | FreeType渲染引擎全局设置 |
| `~/.config/fontconfig/fonts.conf` | 字体别名和优先级 |
| `~/.config/fontconfig/conf.d/` | 用户级渲染配置 |
| `/etc/fonts/conf.d/` | 系统级字体配置 |
| `~/.config/niri/output.kdl` | niri显示器缩放设置 |
| `~/.config/gtk-3.0/settings.ini` | GTK3应用设置 |
| `~/.mozilla/firefox/*/prefs.js` | Firefox配置文件 |

---

## 🔄 系统当前配置总结

### 已确认配置：
- **Firefox**: 使用Wayland原生模式
- **显示器**: 1920x1080 @ 240Hz，`scale 1.0`
- **字体**: Source Han Sans CN（思源黑体）
- **桌面环境**: niri (Wayland)
- **会话类型**: Wayland (`XDG_SESSION_TYPE=wayland`)

### 待优化项目：
- [x] FreeType解释器版本（方案一）
- [ ] Fontconfig次像素渲染（方案二）
- [ ] 应用程序特定优化
- [ ] 环境变量微调

---

## 📝 更新日志

- **2026-01-04**: 创建文档，总结所有优化方案
- **状态**: 已采用方案一，需要重新登录会话生效

---

**注意**：优化后请重启应用程序或重新登录会话以使更改生效。建议逐步测试每个方案，观察改善效果。