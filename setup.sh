#!/bin/bash

# Dotfiles 部署脚本
# 用于在新机器上快速应用配置

set -e  # 出错时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
Dotfiles 部署脚本

使用方法: $0 [选项]

选项:
  -h, --help     显示此帮助信息
  -b, --backup   备份现有配置文件（默认启用）
  -n, --no-backup 不备份现有配置文件
  -l, --link-only 仅创建符号链接，不安装依赖
  -f, --force    强制覆盖现有文件
  -d, --dry-run  模拟运行，不实际执行操作

示例:
  $0              # 默认部署（备份文件）
  $0 --no-backup  # 不备份直接部署
  $0 --link-only  # 仅创建符号链接
  $0 --dry-run    # 模拟运行
EOF
}

# 解析命令行参数
BACKUP=true
FORCE=false
DRY_RUN=false
LINK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -n|--no-backup)
            BACKUP=false
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -l|--link-only)
            LINK_ONLY=true
            shift
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查是否在dotfiles目录中
if [[ ! -f "home/.zshrc" ]]; then
    log_error "请在dotfiles仓库根目录中运行此脚本"
    exit 1
fi

# 获取绝对路径
DOTFILES_DIR="$(pwd)"
log_info "Dotfiles目录: $DOTFILES_DIR"

# 创建备份目录
if [[ "$BACKUP" == true ]]; then
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    log_info "创建备份目录: $BACKUP_DIR"
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$BACKUP_DIR"
    fi
fi

# 备份文件函数
backup_file() {
    local file="$1"
    if [[ -e "$file" || -L "$file" ]]; then
        if [[ "$BACKUP" == true ]]; then
            local backup_path="$BACKUP_DIR/$(basename "$file")"
            log_info "备份: $file -> $backup_path"
            if [[ "$DRY_RUN" == false ]]; then
                cp -r "$file" "$backup_path" 2>/dev/null || true
            fi
        fi
        return 0
    else
        return 1
    fi
}

# 创建符号链接函数
create_link() {
    local source="$1"
    local target="$2"

    # 检查源文件是否存在
    if [[ ! -e "$source" ]]; then
        log_warning "源文件不存在: $source"
        return 1
    fi

    # 检查目标是否已经是正确的符号链接
    if [[ -L "$target" ]]; then
        local current_link="$(readlink -f "$target")"
        if [[ "$current_link" == "$(readlink -f "$source")" ]]; then
            log_info "符号链接已存在且正确: $target -> $source"
            return 0
        fi
    fi

    # 备份现有文件
    backup_file "$target"

    # 移除现有文件或链接
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$FORCE" == true ]]; then
            log_info "强制移除: $target"
            if [[ "$DRY_RUN" == false ]]; then
                rm -rf "$target"
            fi
        else
            log_error "文件已存在: $target (使用 --force 强制覆盖)"
            return 1
        fi
    fi

    # 创建父目录
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        log_info "创建目录: $target_dir"
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$target_dir"
        fi
    fi

    # 创建符号链接
    log_info "创建符号链接: $target -> $source"
    if [[ "$DRY_RUN" == false ]]; then
        ln -s "$source" "$target"
    fi

    return 0
}

# 主部署函数
deploy() {
    log_info "开始部署 dotfiles..."

    # 需要链接的文件列表
    # 格式: "源文件相对路径:目标路径"
    local links=(
        # 点文件
        "home/.zshrc:$HOME/.zshrc"
        "home/.vimrc:$HOME/.vimrc"
        "home/.gitconfig:$HOME/.gitconfig"
        "home/.zimrc:$HOME/.zimrc"
    )

    # 添加 .config 目录下的其他配置文件
    # 排除 .gitignore 中标记为生成/不必要的文件
    local config_files=()
    # 使用数组存储find结果，避免进程替换问题
    while IFS= read -r -d '' file; do
        config_files+=("$file")
    done < <(find home/.config -type f ! -path "*/.zim/*" -print0 2>/dev/null || true)

    for file in "${config_files[@]}"; do
        # 跳过不需要链接的文件
        if [[ "$file" == *"starship-clean.toml"* ]] || \
           [[ "$file" == *"user-dirs.dirs"* ]] || \
           [[ "$file" == *"user-dirs.locale"* ]] || \
           [[ "$file" == *"kdeglobals"* ]] || \
           [[ "$file" == *"mimeapps.list"* ]] || \
           [[ "$file" == *"pavucontrol.ini"* ]] || \
           [[ "$file" == *"lazy-lock.json"* ]]; then
            continue
        fi

        # 构建目标路径
        local rel_path="${file#home/}"
        local target="$HOME/$rel_path"

        # 添加到链接列表
        links+=("$file:$target")
    done

    # 处理符号链接
    local link_count=0
    local error_count=0

    for link in "${links[@]}"; do
        local source="${link%%:*}"
        local target="${link#*:}"
        source="$DOTFILES_DIR/$source"

        log_info "处理: $target"
        if create_link "$source" "$target"; then
            ((link_count+=1))
        else
            ((error_count+=1))
        fi
        echo
    done

    log_info "符号链接处理完成: $link_count 成功, $error_count 失败"

    # 安装依赖（如果不是仅链接模式）
    if [[ "$LINK_ONLY" == false ]] && [[ "$DRY_RUN" == false ]]; then
        install_dependencies
    fi

    log_success "部署完成!"

    if [[ "$error_count" -gt 0 ]]; then
        log_warning "有 $error_count 个文件处理失败，请检查上面的错误信息"
    fi

    if [[ "$BACKUP" == true ]] && [[ -d "$BACKUP_DIR" ]]; then
        log_info "备份文件保存在: $BACKUP_DIR"
    fi
}

# 安装依赖函数
install_dependencies() {
    log_info "开始安装依赖..."

    # 安装 Zimfw
    if [[ ! -d "$HOME/.zim" ]]; then
        log_info "安装 Zimfw..."
        curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
    else
        log_info "Zimfw 已安装，更新中..."
        zsh -c "source $HOME/.zim/zimfw.zsh && zimfw upgrade && zimfw update"
    fi

    # 安装 Starship
    if ! command -v starship &> /dev/null; then
        log_info "安装 Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        log_info "Starship 已安装"
    fi

    # 安装 Neovim 插件管理器 (LazyVim)
    if [[ -d "$HOME/.config/nvim" ]] && ! command -v nvim &> /dev/null; then
        log_warning "检测到 Neovim 配置但未安装 Neovim"
        log_info "请手动安装 Neovim: https://github.com/neovim/neovim/wiki/Installing-Neovim"
    fi

    log_success "依赖安装完成"
}

# 主程序
main() {
    if [[ "$DRY_RUN" == true ]]; then
        log_info "模拟运行模式，不会实际执行操作"
        echo "========================================"
    fi

    deploy

    if [[ "$DRY_RUN" == true ]]; then
        echo "========================================"
        log_info "模拟运行结束"
    fi
}

# 运行主程序
main