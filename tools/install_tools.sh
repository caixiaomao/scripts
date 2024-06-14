#!/bin/bash

# 引入 通用工具
source ./tools/utils.sh

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
detect_linux