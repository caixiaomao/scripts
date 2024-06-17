#!/bin/bash

# 定义颜色
RED='\033[0;31m'     # 错误消息颜色
GREEN='\033[0;32m'   # 成功消息颜色
YELLOW='\033[1;33m'  # 警告消息颜色
BLUE='\033[0;34m'    # 信息消息颜色
NC='\033[0m'         # 重置颜色

# 普通信息消息
echo_info() {
    echo -e "${BLUE}$1${NC}"
}
# 成功消息
echo_success() {
    echo -e "${GREEN}$1${NC}"
}
# 警告消息
echo_warning() {
    echo -e "${YELLOW}$1${NC}"
}
# 错误消息
echo_error() {
    echo -e "${RED}$1${NC}"
}

# 检测 Linux 发行版并确定包管理器
detect_linux() {
    if command -v lsb_release &> /dev/null; then
        DISTRO=$(lsb_release -si)
        VERSION=$(lsb_release -sr)
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/debian_version ]; then
        DISTRO="Debian"
        VERSION=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        DISTRO="RedHat"
        VERSION=$(cat /etc/redhat-release | sed 's/.*release \([0-9]*\).*/\1/')
    fi

    echo_info "Linux 版本: $DISTRO-$VERSION"
    case "$DISTRO" in
        Ubuntu|Debian)
            PKG_MANAGER="apt"
            UPDATE_CMD="sudo $PKG_MANAGER update -y"
            INSTALL_CMD="sudo $PKG_MANAGER install -y"
            ;;
        CentOS|RedHat|Fedora)
            PKG_MANAGER="yum"
            UPDATE_CMD="sudo $PKG_MANAGER update -y"
            INSTALL_CMD="sudo $PKG_MANAGER install -y"
            ;;
        *)
            echo_error "不支持的 Linux 版本: $DISTRO-$VERSION"
            exit 1
            ;;
    esac

    # 更新包索引
    echo_info "更新包索引..."
    $UPDATE_CMD
    echo_success "更新包索引完成"
}

# 定义安装函数
install_git() {
  echo "正在安装 Git..."
  # Git 安装代码
}

install_zsh() {
  echo "正在安装 Zsh..."
  # Zsh 安装代码
}

install_vim() {
  echo "正在安装 Vim..."
  # Vim 安装代码
}

install_ohmyzsh() {
  # 安装 Oh My Zsh
  echo_info "安装 oh-my-zsh"
  # 检查 zsh 版本
  zsh_version=$(zsh --version | grep -oP '\d+\.\d+\.\d+')
  if (( $(echo "$zsh_version < 5.0.8" | bc -l) )); then
      echo_error "zsh 版本必须大于等于 5.0.8，当前版本: $zsh_version"
      exit 1
  fi
  # 检测并执行合适的安装命令
  if command -v curl &> /dev/null; then
    sh -c "$(curl -fsSL https://install.ohmyz.sh)" && echo_success "oh-my-zsh 安装成功"
  elif command -v wget &> /dev/null; then
    sh -c "$(wget -O- https://install.ohmyz.sh)" && echo_success "oh-my-zsh 安装成功"
  else
    echo_error "oh-my-zsh 安装失败: curl 或 wget 未安装"
    exit 1
  fi

  # 安装 oh-my-zsh 插件
  echo_info "安装 oh-my-zsh 插件"
  if command -v git &> /dev/null; then
    echo_info "备份 zsh 配置"
    cp ~/.zshrc ~/.zshrc.bak
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo_info "修改 oh-my-zsh 插件配置"
    sed -i -e 's/plugins=(.*)/plugins=(\1 z git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
  else
      echo_error "oh-my-zsh 插件安装失败：git 未安装"
      exit 1
  fi

  # 完成安装后输出
  echo_info "重载 oh-my-zsh 配置"
  source ~/.zshrc
  echo_success "oh-my-zsh 及插件安装配置完成"
}

# 定义选项和对应的安装函数
tools=(
  "Git:install_git"
  "Vim:install_vim"
  "Oh My Zsh:install_ohmyzsh"
  "Quit::"
)

# 显示选项菜单
show_menu() {
  echo_info "请选择要安装的工具 (多个用逗号分隔):"
  for i in "${!tools[@]}"; do
    tool=${tools[$i]%%:*}
    echo "$((i+1))) $tool"
  done
  read -p "输入选项: " choices
}

# 解析用户选择并执行相应操作
parse_choice() {
  IFS=',' read -ra selected <<< "$choices"
  for choice in "${selected[@]}"; do
    index=$((choice-1))
    if [[ "$index" -ge 0 && "$index" -lt "${#tools[@]}" ]]; then
      tool=${tools[$index]%%:*}
      install_func=${tools[$index]#*:}

      case "$tool" in
        Quit)
          echo_info "退出安装."
          exit 0
          ;;
        *)
          if [ -n "$install_func" ]; then
            $install_func
          else
            echo_error "无效选项: $choice"
          fi
          ;;
      esac
    else
      echo_error "无效选项: $choice"
    fi
  done
}

# 主程序
while true; do
  show_menu
  parse_choice
done