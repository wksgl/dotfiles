#!/bin/bash
# 持续监控会话解锁事件，解锁后恢复外接屏壁纸
# 解决方法：从正常显示器读取当前壁纸路径，重新应用到所有显示器
# （不使用 awww restore，因为外接屏的缓存可能不存在）

while true; do
    # 等待锁屏（hyprlock 进程出现）
    until pgrep -x hyprlock > /dev/null 2>&1; do
        sleep 2
    done

    # 等待解锁（hyprlock 进程退出）
    while pgrep -x hyprlock > /dev/null 2>&1; do
        sleep 0.5
    done

    # 使用统一的壁纸恢复脚本
    ~/.config/niri/scripts/restore-wallpaper.sh
done
