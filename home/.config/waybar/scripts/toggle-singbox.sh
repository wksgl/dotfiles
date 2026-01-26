#!/usr/bin/env bash
# 切换 sing-box 服务状态

if systemctl is-active --quiet sing-box; then
    # 如果服务正在运行，则停止它
    pkexec systemctl stop sing-box 2>/dev/null
else
    # 如果服务未运行，则启动它
    pkexec systemctl start sing-box 2>/dev/null
fi