# Niri 外接屏壁纸变灰/变黑 Bug 修复

## 问题现象

- 外接屏 (HDMI-A-1) 壁纸显示为灰色/黑色纯色，内屏正常
- 锁屏解锁或休眠唤醒后出现
- 切换工作区 (Win+2/Win+3) 时新工作区壁纸也会变灰
- overview (Mod+O) 模式下外接屏背景也是灰色

## 根因分析

### 直接原因

`awww-daemon` 在多显示器环境下，壁纸图片只被设置到了内屏 (eDP-1)，外接屏 (HDMI-A-1) 的 layer 处于纯色状态 (`color: #000000`)。

用 `awww query --json --all` 可以看到：

```
[main]     eDP-1    -> image: /path/to/wallpaper.jpg
[main]     HDMI-A-1 -> color: #0              ← 纯黑，没有图片
[overview] eDP-1    -> image: /path/to/blur.jpg
[overview] HDMI-A-1 -> color: #0              ← 纯黑
```

### 为什么只在某些场景触发

1. **启动时**：`waypaper --random` 调用 `awww img <file>` 理论上应应用到所有输出，但外接屏可能初始化较慢，导致只应用到了已就绪的内屏
2. **锁屏/休眠后**：hyprlock 通过 ext-session-lock 接管显示器，或系统休眠导致 GPU shared memory 丢失；恢复后外接屏的 layer 状态未正确重建
3. **overview daemon** (`awww-daemon -n overview`)：独立的 daemon 实例，缓存独立，同样存在外接屏缺失的问题

### 为什么 `awww restore` 不生效

`awww restore` 依赖各 output 的缓存记录。但外接屏从未成功设置过壁纸或缓存被清除时，`restore` 找不到缓存条目，无法恢复。

## 解决方案

### 核心思路

不依赖 `awww restore`（不可靠的缓存），而是从**正常显示器（内屏）读取当前壁纸路径**，然后重新应用到所有显示器。

### 修改的文件

#### 1. `~/.config/niri/scripts/restore-wallpaper.sh`（新建）

```bash
#!/bin/bash
# 从正常显示器读取当前壁纸路径，重新应用到所有显示器
sleep 0.5

# --- 主守护进程 ---
main_img=$(awww query --json 2>/dev/null | grep -oP '"image":\s*"\K[^"]+') || true
if [ -n "$main_img" ] && [ -f "$main_img" ]; then
    awww img "$main_img" &
fi

# --- overview 守护进程 ---
if pgrep -f "awww-daemon.*overview" > /dev/null 2>&1; then
    overview_img=$(awww query --json -n overview 2>/dev/null | grep -oP '"image":\s*"\K[^"]+') || true
    if [ -n "$overview_img" ] && [ -f "$overview_img" ]; then
        awww img -n overview "$overview_img" &
    fi
fi
```

**逻辑**：
- 从 `awww query --json` 获取任意输出上已有的 image 路径
- 用 `awww img <path>` 重新应用到该 namespace 的**所有**输出
- 同时处理 main namespace 和 overview namespace

#### 2. `~/.config/niri/scripts/unlock-restore-wallpaper.sh`（新建）

```bash
#!/bin/bash
while true; do
    # 等待锁屏（hyprlock 进程出现）
    until pgrep -x hyprlock > /dev/null 2>&1; do
        sleep 2
    done
    # 等待解锁（hyprlock 进程退出）
    while pgrep -x hyprlock > /dev/null 2>&1; do
        sleep 0.5
    done
    # 恢复壁纸
    ~/.config/niri/scripts/restore-wallpaper.sh
done
```

**逻辑**：后台循环监控 hyprlock 的退出（= 会话解锁），解锁后自动调用恢复脚本。

#### 3. `~/.config/niri/config.kdl`

在启动项中加入 unlock watcher：

```kdl
// 锁屏/休眠唤醒后自动恢复外接屏壁纸（修复壁纸变灰的 bug）
spawn-at-startup "~/.config/niri/scripts/unlock-restore-wallpaper.sh"
```

#### 4. `~/.config/hypr/hypridle.conf`

在三个 resume hook 中加入 `restore-wallpaper.sh`：

```ini
# 休眠唤醒
after_sleep_cmd = sleep 1; niri msg action power-on-monitors; sleep 0.5; ~/.config/niri/scripts/restore-wallpaper.sh

# 显示器关屏恢复 (Phase 2)
on-resume = sleep 0.5; niri msg action power-on-monitors; sleep 0.5; ~/.config/niri/scripts/restore-wallpaper.sh

# 系统 suspend 恢复 (Phase 3)
on-resume = sleep 2; niri msg action power-on-monitors; sleep 1; ~/.config/niri/scripts/restore-wallpaper.sh
```

### 触发时机覆盖

| 场景 | 恢复机制 |
|------|----------|
| 手动锁屏后解锁 | `unlock-restore-wallpaper.sh` |
| 闲置自动锁屏后解锁 | `unlock-restore-wallpaper.sh` |
| 系统休眠唤醒后解锁 | `unlock-restore-wallpaper.sh` + `after_sleep_cmd` |
| 显示器关屏后恢复 | hypridle `on-resume` (Phase 2) |
| 系统 suspend 唤醒 | hypridle `on-resume` (Phase 3) + `after_sleep_cmd` |

### 排障命令

```bash
# 查看所有 daemon 所有输出的壁纸状态
awww query --json --all

# 手动恢复
~/.config/niri/scripts/restore-wallpaper.sh

# 检查后台进程
pgrep -f unlock-restore-wallpaper
pgrep -x hypridle
pgrep -f "awww-daemon"
```
