#!/bin/bash

# 复制zsh配置文件
echo "复制zsh配置文件..."
cp ~/.zshrc home/
cp ~/.zimrc home/
cp ~/.z home/
cp ~/.zfm.txt home/

# 复制zim目录（排除.git和编译文件）
echo "复制zim目录..."
rsync -av --exclude='.git' --exclude='*.zwc' ~/.zim/ home/.zim/ 2>/dev/null || cp -r ~/.zim/* home/.zim/ 2>/dev/null

# 复制vim配置文件
echo "复制vim配置文件..."
cp ~/.vimrc home/
cp ~/.viminfo home/
# 复制vim目录（如果存在）
if [ -d ~/.vim ] && [ "$(ls -A ~/.vim 2>/dev/null)" ]; then
    cp -r ~/.vim/* home/.vim/
fi

# 复制bash配置文件
echo "复制bash配置文件..."
cp ~/.bashrc home/
cp ~/.bash_profile home/
cp ~/.bash_logout home/
cp ~/.profile.tmp home/

# 复制git配置
echo "复制git配置..."
cp ~/.gitconfig home/

# 复制ssh配置
echo "复制ssh配置..."
cp -r ~/.ssh/* home/.ssh/

# 复制npm配置
echo "复制npm配置..."
cp -r ~/.npm/* home/.npm/

# 复制.config目录下的重要配置
echo "复制.config目录配置..."
cp ~/.config/starship.toml home/.config/
cp ~/.config/starship-clean.toml home/.config/
cp ~/.config/starship.toml.backup home/.config/
cp ~/.config/kdeglobals home/.config/
cp ~/.config/mimeapps.list home/.config/
cp ~/.config/pavucontrol.ini home/.config/
cp ~/.config/user-dirs.dirs home/.config/
cp ~/.config/user-dirs.locale home/.config/

# 复制Documents目录
echo "复制Documents目录..."
cp ~/Documents/* Documents/

# 复制壁纸
echo "复制壁纸..."
cp -r ~/Pictures/Wallpapers/* Pictures/Wallpapers/

# 复制sing-box配置（需要sudo权限）
echo "复制sing-box配置..."
echo "143" | sudo -S cp /etc/sing-box/config.json etc/sing-box/ 2>/dev/null
echo "143" | sudo -S chown $USER:$USER etc/sing-box/config.json 2>/dev/null

echo "所有文件复制完成！"