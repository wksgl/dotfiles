# ------------------
# 1. 基础优化
# ------------------
# 防止补全被多次初始化
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
setopt HIST_IGNORE_ALL_DUPS
bindkey -v
# 优化单词删除字符（移除 /，这样按 Ctrl+W 时不会把路径全删掉）
WORDCHARS=${WORDCHARS//[\/]}

# ------------------
# 2. 初始化 Zim (插件管理器)
# ------------------
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# 屏蔽 init 时的警告信息
exec 3>&2 
exec 2>/dev/null 
source ${ZIM_HOME}/init.zsh
exec 2>&3 
exec 3>&- 

# ------------------
# 3. 环境变量与 PATH (关键修复)
# ------------------
# NVM 配置 (必须放在 PATH 设置之前或之中，以便生效)
export NVM_DIR="$HOME/.nvm"
# 修复语法错误：把 \. 改为 source
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# 整合 PATH 设置 (保持条理清晰)
# 注意：把 $PATH 放在最后，确保你自定义的优先级高于系统默认
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# 修复 Claude 路径：使用通配符 * 避免版本号更新导致路径失效
# 这行命令会动态寻找最新的 claude 插件目录
CLAUDE_BIN=$(find $HOME/.vscode/extensions -maxdepth 1 -type d -name "anthropic.claude-code-*" 2>/dev/null | sort -V | tail -n 1)/resources/native-binary
if [ -d "$CLAUDE_BIN" ]; then
    export PATH="$PATH:$CLAUDE_BIN"
fi

# ------------------
# 4. 插件与工具
# ------------------
# FZF (先检查文件是否存在，防止报错)
[ -f ~/fzf.zsh ] && source ~/fzf.zsh

# ------------------
# 5. Prompt 与 钩子
# ------------------
# 初始化 Starship (放在 NVM 之后)
eval "$(starship init zsh)"

# 手动重新绑定自动建议 (Zim特定)
if (( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )) && (( ${+functions[_zsh_autosuggest_bind_widgets]} )); then
  _zsh_autosuggest_bind_widgets
fi

# ------------------
# 6. 本地私有配置 (救命稻草)
# ------------------
# 将你的 Token 和不想上传到 Git 的配置写在 ~/.zshrc.local 里
[ -f ~/.zshrc.local ] && source ~/.zshrc.local


