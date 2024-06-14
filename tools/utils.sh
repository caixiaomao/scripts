# Script Name: utils.sh
# Description: 定义常用工具函数
# Date: 2024-06-14
# Version: 1.0

# common.sh

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