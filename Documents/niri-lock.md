# Niri Compositor 锁屏策略与 NVIDIA 显卡唤醒问题解决方案

## 问题描述
在使用 Niri compositor（Wayland）配合 NVIDIA 显卡时，锁屏后唤醒存在兼容性问题。主要表现为：
- 从锁屏状态唤醒时显示器无法正常点亮
- 系统响应延迟或卡顿
- 可能与 NVIDIA 驱动的电源状态管理冲突

## 环境信息
- **显示服务器**: Wayland (XDG_SESSION_TYPE=wayland)
- **桌面环境**: Niri compositor (XDG_CURRENT_DESKTOP=niri)
- **显卡**: NVIDIA（驱动版本 590.48.01）
- **锁屏程序**: swaylock 1.7.0.0（已安装 swaylock-effects 分支）

## 当前锁屏策略
通过 `swayidle` 管理空闲状态：
- **5分钟**: 锁屏
- **10分钟**: 关闭显示器
- **20分钟**: 系统休眠

## 已尝试的解决方案

### 方案一：禁用模糊特效（基础调整）
**文件**: `~/.config/swaylock/config`
```diff
- effect-blur=10x5
+ # effect-blur=10x5
```
**原理**: 减少 GPU 渲染负载，避免与 NVIDIA 电源管理冲突。

### 方案二：移除守护进程模式
**文件**: `~/.config/niri/scripts/swayidle.sh`
```diff
- timeout 300  'swaylock -f' \
+ timeout 300  'swaylock' \
```
**原理**: `-f` 参数让 swaylock 在后台守护进程化，可能影响唤醒时的进程管理。

### 方案三：调整执行顺序（推荐尝试）
**文件**: `~/.config/niri/scripts/swayidle.sh`
```bash
# 原配置
timeout 300  'swaylock' \
timeout 600  'niri msg action power-off-monitors' \

# 新配置（先关闭显示器再锁屏）
timeout 300  'niri msg action power-off-monitors && swaylock --grace 5' \
timeout 600  'niri msg action power-off-monitors' \
resume       'niri msg action power-on-monitors' \
timeout 1200 'systemctl suspend'
```

**优化点**:
1. **先关闭显示器再锁屏**: 减少 GPU 在锁屏时的渲染负载
2. **添加宽限期**: `--grace 5` 给用户5秒时间移动鼠标避免误锁
3. **保持恢复机制**: `resume` 命令在用户活动时重新打开显示器

## 当前生效配置
```bash
#!/usr/bin/env bash

# 5分钟锁屏，10分钟熄屏，20分钟休眠
exec swayidle -w \
timeout 300  'niri msg action power-off-monitors && swaylock --grace 5' \
timeout 600  'niri msg action power-off-monitors' \
resume       'niri msg action power-on-monitors' \
timeout 1200 'systemctl suspend'
```

## 测试方案

### 手动测试锁屏唤醒
1. **快捷键锁屏**: 按 `Mod+Alt+L`（通常是 `Super+Alt+L`）
2. **输入密码解锁**: 验证正常解锁功能
3. **观察日志**:
   ```bash
   journalctl --since "5 minutes ago" | grep -i "swaylock\|niri\|error"
   ```

### 自动锁屏测试（等待5分钟）
- **5分钟后**: 显示器应关闭并显示锁屏界面
- **移动鼠标/按键**: 应出现密码输入界面
- **输入密码后**: 显示器应重新点亮，系统恢复正常

## 备用调整方案

### 方案A：进一步分离执行顺序
```bash
# 先关闭显示器，5秒后再锁屏
timeout 295  'niri msg action power-off-monitors' \
timeout 300  'swaylock --grace 10' \
resume       'niri msg action power-on-monitors' \
```
**原理**: 给 GPU 更多状态切换时间，减少并发操作。

### 方案B：简化配置（仅关闭显示器）
```bash
# 完全移除 swaylock，仅用显示器电源管理
timeout 300  'niri msg action power-off-monitors' \
resume       'niri msg action power-on-monitors' \
timeout 1200 'systemctl suspend'
```
**注意**: 这不提供密码保护，仅适用于低安全需求环境。

### 方案C：使用 swaylock-effects
```bash
# 安装特效版本
sudo pacman -S swaylock-effects

# 修改命令
timeout 300 'swaylock-effects --grace 5'
```

### 方案D：尝试 waylock（轻量级替代）
```bash
# 安装
sudo pacman -S waylock

# 修改 swayidle.sh
timeout 300 'waylock'
```

### 方案E：系统级 NVIDIA 驱动调整
```bash
# 查看当前电源管理状态
nvidia-smi -q | grep -A5 "Power Management"

# 尝试禁用某些电源功能（如有）
sudo nvidia-smi -pm 0  # 禁用运行时电源管理
```

## 诊断命令

### 系统日志检查
```bash
# 查看 swaylock 相关日志
journalctl --since "5 minutes ago" | grep -i "swaylock\|nvidia\|error"

# 查看 niri 电源管理日志
journalctl --user -b | grep -i "power-off\|power-on"

# 查看内核 NVIDIA 相关消息
journalctl -k --grep=nvidia -n 20

# 实时监控日志
journalctl -f | grep -i "suspend\|resume\|wake"
```

### 进程状态检查
```bash
# 检查 swayidle 进程
ps aux | grep -E "swayidle|swaylock" | grep -v grep

# 检查 niri 进程
ps aux | grep niri | grep -v grep
```

### 配置验证
```bash
# 验证 swayidle 配置
cat ~/.config/niri/scripts/swayidle.sh

# 验证 swaylock 配置
cat ~/.config/swaylock/config

# 测试 swaylock 直接运行
swaylock --version
```

## 恢复原始配置
```bash
# 如果有备份
cp ~/.config/niri/scripts/swayidle.sh.backup ~/.config/niri/scripts/swayidle.sh

# 重启 swayidle
pkill swayidle && cd ~/.config/niri/scripts && nohup ./swayidle.sh > /dev/null 2>&1 &
```

## 关键发现
从系统日志中发现可能的问题点：
1. **NVIDIA 驱动挂起调用**: 日志中有 `nvKmsSuspend` 相关调用记录
2. **GL 渲染错误**: 可能存在与模糊特效相关的渲染问题
3. **进程管理**: `swaylock -f` 的守护进程模式可能与唤醒过程冲突

## 建议优先测试顺序
1. **当前配置**（方案三）：先关闭显示器再锁屏 + 宽限期
2. **方案A**：进一步分离关闭显示器和锁屏操作
3. **方案C**：尝试 swaylock-effects 分支
4. **方案D**：尝试 waylock 轻量级替代
5. **方案E**：调整 NVIDIA 驱动电源设置

---
**文档创建时间**: 2026-01-03
**最后测试配置**: 方案三（先关闭显示器再锁屏）
**问题状态**: 测试中