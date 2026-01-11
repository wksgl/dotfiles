# 防止completion被多次初始化
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# ------------------
# Initialize Zim
# ------------------
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# 临时重定向stderr来隐藏compinit警告
exec 3>&2  # 保存原始的stderr
exec 2>/dev/null  # 重定向stderr到/dev/null
source ${ZIM_HOME}/init.zsh
exec 2>&3  # 恢复原始的stderr
exec 3>&-  # 关闭文件描述符3

export PATH="/usr/local/bin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Claude CLI 路径
export PATH="$PATH:/home/zane/.vscode/extensions/anthropic.claude-code-2.0.43-linux-x64/resources/native-binary"

# -----------------
# User configuration
# -----------------
setopt HIST_IGNORE_ALL_DUPS
bindkey -v
WORDCHARS=${WORDCHARS//[\/]}

# fzf integrati
source ~/fzf.zsh

# ------------------
# Initialize Starship (放在最后)
# ------------------
eval "$(starship init zsh)"

# 手动重新绑定自动建议
if (( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )) && (( ${+functions[_zsh_autosuggest_bind_widgets]} )); then
  _zsh_autosuggest_bind_widgets
fi
