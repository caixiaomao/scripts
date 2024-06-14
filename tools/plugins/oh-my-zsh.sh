#!/bin/bash

# 引入 通用工具
source ../utils.sh

# 安装 Oh My Zsh
echo_info "开始安装 oh-my-zsh"
# 检测并执行合适的安装命令
if command -v curl &> /dev/null; then
  install_cmd="curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
elif command -v wget &> /dev/null; then
  install_cmd="wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
else
  echo_error "oh-my-zsh 安装失败: curl 或 wget 未安装"
  exit 1
fi
# 执行安装命令
sh -c "$install_cmd" && echo_success "oh-my-zsh 安装成功"

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