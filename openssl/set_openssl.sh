#!/bin/bash

# 颜色输出定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测操作系统和包管理器
detect_os() {
    local OS
    local PACKAGE_MANAGER

    # 检测常见的Linux发行版
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
    else
        OS=$(uname -s)
    fi

    # 转换为小写
    OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')

    # 选择包管理器
    case "$OS" in
        ubuntu|debian)
            PACKAGE_MANAGER="apt-get"
            ;;
        centos|rhel|fedora)
            PACKAGE_MANAGER="yum"
            ;;
        opensuse*|suse)
            PACKAGE_MANAGER="zypper"
            ;;
        arch|manjaro)
            PACKAGE_MANAGER="pacman"
            ;;
        alpine)
            PACKAGE_MANAGER="apk"
            ;;
        *)
            log_error "不支持的操作系统: $OS"
            return 1
            ;;
    esac

    echo "$OS $PACKAGE_MANAGER"
}

# 更全面的 OpenSSL 检查函数
check_openssl_complete() {
    # 检查 OpenSSL 命令是否可用
    if ! command -v openssl &> /dev/null; then
        return 1
    fi

    # 全面的库文件和头文件路径
    local lib_paths=(
        "/usr/lib/x86_64-linux-gnu/libssl.so"
        "/usr/lib64/libssl.so"
        "/usr/lib/libssl.so"
        "/usr/local/lib/libssl.so"
        "/opt/local/lib/libssl.so"
        "/usr/lib/x86_64-linux-musl/libssl.so"
    )

    local include_paths=(
        "/usr/include/openssl/ssl.h"
        "/usr/local/include/openssl/ssl.h"
        "/opt/local/include/openssl/ssl.h"
        "/usr/include/x86_64-linux-gnu/openssl/ssl.h"
        "/usr/include/linux/openssl/ssl.h"
    )

    local lib_found=false
    local include_found=false

    # 检查库文件
    for path in "${lib_paths[@]}"; do
        if [ -f "$path" ]; then
            lib_found=true
            break
        fi
    done

    # 检查头文件
    for path in "${include_paths[@]}"; do
        if [ -f "$path" ]; then
            include_found=true
            break
        fi
    done

    # 同时检查库文件和头文件
    if [ "$lib_found" = true ] && [ "$include_found" = true ]; then
        return 0
    else
        return 1
    fi
}

# 安装 OpenSSL 的系统特定函数
install_openssl() {
    local OS_INFO
    OS_INFO=$(detect_os)
    
    if [ $? -ne 0 ]; then
        log_error "无法识别操作系统，无法自动安装 OpenSSL"
        return 1
    fi

    read -r OS PACKAGE_MANAGER <<< "$OS_INFO"

    log_info "检测到操作系统: $OS，使用包管理器: $PACKAGE_MANAGER"

    # 使用 sudo 提权
    local SUDO
    SUDO=$(command -v sudo)

    # 不同系统的 OpenSSL 安装命令
    case "$PACKAGE_MANAGER" in
        apt-get)
            $SUDO apt-get update
            $SUDO apt-get install -y openssl libssl-dev
            ;;
        yum)
            $SUDO yum install -y openssl openssl-devel
            ;;
        zypper)
            $SUDO zypper install -y openssl libopenssl-devel
            ;;
        pacman)
            $SUDO pacman -Sy --noconfirm openssl
            ;;
        apk)
            $SUDO apk add openssl openssl-dev
            ;;
        *)
            log_error "不支持的包管理器: $PACKAGE_MANAGER"
            return 1
            ;;
    esac

    # 验证安装
    if [ $? -eq 0 ]; then
        log_info "OpenSSL 安装成功"
    else
        log_error "OpenSSL 安装失败"
        return 1
    fi
}

# 主函数
main() {
    # 检查是否为 root 或有 sudo 权限
    if [ "$EUID" -ne 0 ]; then
        log_warning "建议以 root 权限或使用 sudo 运行此脚本"
    fi

    # 检查 OpenSSL 是否已经完整安装
    if check_openssl_complete; then
        log_info "OpenSSL 已经正确安装，无需重复配置。"
        log_info "OpenSSL 版本: $(openssl version)"
        exit 0
    fi

    # 尝试安装 OpenSSL
    if install_openssl; then
        # 再次验证安装
        if check_openssl_complete; then
            log_info "OpenSSL 安装验证成功！"
            log_info "OpenSSL 版本: $(openssl version)"
            exit 0
        else
            log_error "OpenSSL 安装后验证失败"
            exit 1
        fi
    else
        log_error "OpenSSL 安装失败"
        exit 1
    fi
}

# 执行主函数
main
