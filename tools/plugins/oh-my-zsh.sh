#!/bin/bash

# 引入 通用工具
source ./tools/utils.sh

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