#!/bin/bash
# 启动前先杀死已有的进程，防止重复
pgrep -x hypridle && killall hypridle

# 启动 hypridle
hypridle
