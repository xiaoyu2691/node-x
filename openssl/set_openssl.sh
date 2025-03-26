#!/bin/bash

# 检测操作系统类型
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif command -v lsb_release &> /dev/null; then
        lsb_release -i | cut -d: -f2 | sed -e 's/^[[:space:]]*//'
    elif [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release | cut -d' ' -f1
    else
        echo "unknown"
    fi
}

# 检查并安装依赖
install_dependencies() {
    local os=$(detect_os)
    echo "检测到操作系统: $os"

    case "$os" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y build-essential libssl-dev pkg-config curl
            ;;
        centos|rhel|fedora)
            sudo yum install -y gcc make openssl-devel pkgconfig curl
            ;;
        almalinux|rocky)
            sudo dnf install -y gcc make openssl-devel pkgconfig curl
            ;;
        alpine)
            sudo apk add --no-cache build-base openssl-dev pkgconfig curl
            ;;
        *)
            echo "不支持的操作系统，请手动安装依赖"
            exit 1
            ;;
    esac
}

# 检查 OpenSSL 是否安装
check_openssl() {
    command -v openssl &> /dev/null
}

# 检查 OpenSSL 开发库
check_openssl_dev() {
    local os=$(detect_os)
    
    case "$os" in
        ubuntu|debian)
            [ -f /usr/include/openssl/ssl.h ] && [ -f /usr/lib/x86_64-linux-gnu/libssl.so ]
            ;;
        centos|rhel|fedora|almalinux|rocky)
            [ -f /usr/include/openssl/ssl.h ] && [ -f /usr/lib64/libssl.so ]
            ;;
        alpine)
            [ -f /usr/include/openssl/ssl.h ] && [ -f /usr/lib/libssl.so ]
            ;;
        *)
            false
            ;;
    esac
}

# 获取 OpenSSL 库路径
get_openssl_paths() {
    local os=$(detect_os)
    
    case "$os" in
        ubuntu|debian)
            SSL_LIB_PATH=$(find /usr -name "libssl.so*" | grep x86_64-linux-gnu | head -n 1 | xargs dirname)
            SSL_INCLUDE_PATH=$(find /usr -name "openssl.h" | grep x86_64-linux-gnu | head -n 1 | xargs dirname)
            PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig"
            ;;
        centos|rhel|fedora|almalinux|rocky)
            SSL_LIB_PATH=$(find /usr -name "libssl.so*" | grep lib64 | head -n 1 | xargs dirname)
            SSL_INCLUDE_PATH=$(find /usr -name "openssl.h" | grep include | head -n 1 | xargs dirname)
            PKG_CONFIG_PATH="/usr/lib64/pkgconfig"
            ;;
        alpine)
            SSL_LIB_PATH=$(find /usr -name "libssl.so*" | head -n 1 | xargs dirname)
            SSL_INCLUDE_PATH=$(find /usr -name "openssl.h" | head -n 1 | xargs dirname)
            PKG_CONFIG_PATH="/usr/lib/pkgconfig"
            ;;
        *)
            echo "无法确定库路径"
            exit 1
            ;;
    esac
}

# 主函数
main() {
    # 检查并安装 OpenSSL
    if ! check_openssl; then
        echo "OpenSSL 未安装，开始安装..."
        install_dependencies
    fi

    # 检查开发库
    if ! check_openssl_dev; then
        echo "OpenSSL 开发库不完整，正在修复..."
        install_dependencies
    fi

    # 获取 OpenSSL 版本和路径
    OPENSSL_VERSION=$(openssl version | awk '{print $2}')
    echo "当前 OpenSSL 版本: $OPENSSL_VERSION"

    # 获取库路径
    get_openssl_paths

    # 配置环境变量
    export OPENSSL_LIB_DIR=$SSL_LIB_PATH
    export OPENSSL_INCLUDE_DIR=$SSL_INCLUDE_PATH
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH

    # 更新 ~/.bashrc
    sed -i '/# OpenSSL Configuration/d' ~/.bashrc
    sed -i '/OPENSSL_LIB_DIR/d' ~/.bashrc
    sed -i '/OPENSSL_INCLUDE_DIR/d' ~/.bashrc
    sed -i '/PKG_CONFIG_PATH/d' ~/.bashrc

    echo "# OpenSSL Configuration" >> ~/.bashrc
    echo "export OPENSSL_LIB_DIR=$SSL_LIB_PATH" >> ~/.bashrc
    echo "export OPENSSL_INCLUDE_DIR=$SSL_INCLUDE_PATH" >> ~/.bashrc
    echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> ~/.bashrc

    # 输出配置信息
    echo "OpenSSL 库路径: $SSL_LIB_PATH"
    echo "OpenSSL 头文件路径: $SSL_INCLUDE_PATH"
    echo "Pkg-config 路径: $PKG_CONFIG_PATH"

    echo "OpenSSL 配置完成，请运行 'source ~/.bashrc' 使配置生效"
}

# 执行主函数
main
