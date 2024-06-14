#!/bin/bash

# 引入 通用工具
source ../utils.sh

# 安装 Oh My Zsh
echo_info "安装 oh-my-zsh"
# 检测 curl 或 wget 是否存在，并选择合适的命令进行安装
if command -v curl > /dev/null; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo_success "oh-my-zsh 安装成功"
elif command -v wget > /dev/null; then
    sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo_success "oh-my-zsh 安装成功"
else
    echo_error "安装 oh-my-zsh 失败: curl 或 wget 未安装"
    exit 1
fi

# 安装 zsh-syntax-highlighting 插件
echo_info "安装 zsh-syntax-highlighting 插件"
# 检测 git 是否存在
if command -v git > /dev/null; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo_info "备份 zsh 配置"
  cp ~/.zshrc ~/.zshrc.bak
  echo_info "增加 zsh-syntax-highlighting 插件"
  sed -i '/^plugins=(/{s/)/ zsh-autosuggestions)/}' ~/.zshrc
else
    echo_error "安装 zsh-syntax-highlighting 插件失败：git 未安装或者修改配置失败"
    exit 1
fi

# 完成安装后输出
echo_success "zsh-syntax-highlighting 插件安装成功"