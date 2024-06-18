#!/bin/bash
export LANG=en_US.UTF-8

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

# 初始化变量
initVar() {
    INSTALL_CMD='apt -y install'
    REMOVE_CMD='apt -y remove'
    UPDATE_CMD="apt -y update"
}

# 检测 Linux 发行版并确定包管理器
checkSystem() {
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

    # 将 DISTRO 转换为小写
    DISTRO=$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]')
    echo_info "Linux 版本: $DISTRO-$VERSION"
    case "$DISTRO" in
        ubuntu|debian)
            UPDATE_CMD="apt -y update"
            INSTALL_CMD="apt -y install"
            ;;
        centos|redhat|fedora)
            UPDATE_CMD="yum -y update"
            INSTALL_CMD="yum -y install"
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
installBasicTools() {
  echo_info "安装基础依赖..."
  $INSTALL_CMD curl wget git vim zsh
  echo_success "基础依赖安装完成"
}

# 安装 Docker
installDocker() {
  echo_info "安装 docker..."
  echo_success "docker 安装完成"
}

# 安装并配置 Oh My Zsh
installOhMyZsh() {
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

# 显示选项菜单
showMenu() {
    echo_info "作者: caixiaomao"
    echo_info "版本: v1.0.0"
    echo_success "=============================================================="
    echo_info     "1.Oh My ZSH"
    echo_info     "2.Docker"
    echo_info     "3.其它"
    echo_info     "4.退出"
    echo_success "=============================================================="
    read -r -p "请选择:" selectInstallType
    case ${selectInstallType} in
    1)
        installOhMyZsh
        showMenu
        ;;
    2)
        installDocker
        showMenu
        ;;
    3)
        echo_success "其它测试"
        showMenu
        ;;
    4)
        exit 1
        ;;
    esac
}


# 初始化变量
initVar
checkSystem
installBasicTools
showMenu