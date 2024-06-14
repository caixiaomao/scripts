#!/bin/bash

# 检测 Linux 发行版并确定包管理器
detect_pkg_manager() {
    if [ -f /etc/debian_version ]; then
        PKG_MANAGER="apt-get"
        UPDATE_CMD="$PKG_MANAGER update"
        INSTALL_CMD="$PKG_MANAGER install -y"
    elif [ -f /etc/redhat-release ]; then
        PKG_MANAGER="yum"
        UPDATE_CMD="$PKG_MANAGER makecache"
        INSTALL_CMD="$PKG_MANAGER install -y"
    else
        echo "Unsupported distribution. Exiting."
        exit 1
    fi

    # 更新包索引
    $UPDATE_CMD
}

# 检查和安装依赖
check_dependencies() {
    local dependencies=$1
    for dep in $dependencies; do
        if [ "$dep" == "zsh" ]; then
            zsh_version=$(zsh --version | grep -oP '\d+\.\d+')
            if (( $(echo "$zsh_version < 5.9" | bc -l) )); then
                echo "Zsh version must be greater than 5.9. Current version: $zsh_version"
                $INSTALL_CMD zsh
            fi
        fi
    done
}

# 安装指定的工具
install_tool() {
    local tool_name=$1
    local install_script=$2
    local dependencies=$(yq e ".tools[] | select(.name == \"$tool_name\").dependencies // empty" tools.yaml)

    if [ ! -z "$dependencies" ]; then
        check_dependencies "$dependencies"
    fi

    if [ ! -z "$install_script" ]; then
        echo "Installing $tool_name using a custom script..."
        bash $install_script
    else
        echo "Installing $tool_name using package manager..."
        $INSTALL_CMD $tool_name
    fi

    if [ $? -eq 0 ]; then
        echo "$tool_name installed successfully."
    else
        echo "Failed to install $tool_name."
    fi
}

# 解析 YAML 并安装工具
install_tools() {
    detect_pkg_manager
    local bulk_install_list=""

    yq e '.tools[]' tools.yaml | while read -r entry; do
        local name=$(echo "$entry" | yq e '.name' -)
        local script=$(echo "$entry" | yq e '.script // empty' -)

        if [ -z "$script" ]; then
            # Accumulate names for bulk installation
            bulk_install_list+="$name "
        else
            # Install tools with custom scripts immediately
            install_tool "$name" "$script"
        fi
    done

    # Now, install all collected tools without custom scripts in one go
    if [ ! -z "$bulk_install_list" ]; then
        echo "Installing multiple tools at once: $bulk_install_list"
        $INSTALL_CMD $bulk_install_list
    fi
}

# 主函数
install_tools