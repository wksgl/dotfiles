#!/bin/bash
# 从正常显示器读取当前壁纸路径，重新应用到所有显示器
# 同时处理主守护进程和 overview 命名空间的壁纸恢复
sleep 0.5

# --- 主守护进程 ---
main_img=$(awww query --json 2>/dev/null | grep -oP '"image":\s*"\K[^"]+') || true
if [ -n "$main_img" ] && [ -f "$main_img" ]; then
    awww img "$main_img" &
fi

# --- overview 守护进程 (overview 背景的模糊暗化壁纸) ---
if pgrep -f "awww-daemon.*overview" > /dev/null 2>&1; then
    overview_img=$(awww query --json -n overview 2>/dev/null | grep -oP '"image":\s*"\K[^"]+') || true
    if [ -n "$overview_img" ] && [ -f "$overview_img" ]; then
        awww img -n overview "$overview_img" &
    fi
fi
