#!/bin/bash

# ============================================
# Docker & NVIDIA Docker 自动化安装脚本
# 支持国内/国外服务器自动识别
# 支持NVIDIA GPU自动检测和驱动安装
# ============================================

# set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️ [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

# 全局变量
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
IS_DOMESTIC=false
HAS_NVIDIA=false
HAS_NVIDIA_DRIVER=false
NEED_REBOOT=false
PROXY_CONFIGURED=false
DRIVER_VERIFIED=false
DOCKER_INSTALLED=false
NVIDIA_TOOLKIT_INSTALLED=false

# ============================================
# 环境检测函数
# ============================================

# 检测系统信息
detect_system() {
    log_info "检测系统信息..."
    
    if [[ ! -f /etc/os-release ]]; then
        log_error "无法检测操作系统"
        exit 1
    fi
    
    source /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    CODENAME=${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null)}
    
    log_success "系统: $PRETTY_NAME"
    
    # 检测架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armhf" ;;
        *)
            log_error "不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    log_success "架构: $ARCH"
}

# 检测是否配置了代理
is_proxy_configured() {
    PROXY_CONFIGURED=false
    
    # 检查环境变量
    if [[ -n "$HTTP_PROXY" ]] || [[ -n "$HTTPS_PROXY" ]] || \
       [[ -n "$http_proxy" ]] || [[ -n "$https_proxy" ]] || \
       [[ -n "$ALL_PROXY" ]] || [[ -n "$all_proxy" ]]; then
        PROXY_CONFIGURED=true
    fi
    
    # 检查梯子软件进程
    if [[ "$PROXY_CONFIGURED" == "false" ]]; then
        local proxy_processes=("v2ray" "clash" "shadowsocks" "ssr" "xray" "trojan")
        for proc in "${proxy_processes[@]}"; do
            if pgrep -x "$proc" > /dev/null 2>&1; then
                PROXY_CONFIGURED=true
                break
            fi
        done
    fi
    
    # 检查Docker代理配置
    if [[ "$PROXY_CONFIGURED" == "false" ]] && [[ -f "/etc/systemd/system/docker.service.d/http-proxy.conf" ]]; then
        PROXY_CONFIGURED=true
    fi
    
    # 检查系统代理配置文件
    if [[ "$PROXY_CONFIGURED" == "false" ]] && [[ -f "$HOME/.bashrc" ]] && grep -q "proxy" "$HOME/.bashrc" 2>/dev/null; then
        PROXY_CONFIGURED=true
    fi
}

# 判断是否为国内服务器
function detect_location() {
    log_info "检测服务器地理位置..."
    
    is_proxy_configured
    
    if [[ "$PROXY_CONFIGURED" == "true" ]]; then
        log_warning "检测到代理配置，默认判定为国内服务器"
        IS_DOMESTIC=true
    else
        # 尝试获取IP地址
        local ip_address
        ip_address=$(curl -s --connect-timeout 5 http://ipinfo.io/ip 2>/dev/null || \
                     curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || \
                     curl -s --connect-timeout 5 https://ifconfig.me 2>/dev/null)
        
        if [[ -z "$ip_address" ]]; then
            log_warning "无法获取IP地址，默认判定为国内服务器"
            IS_DOMESTIC=true
        else
            log_info "检测到IP: $ip_address"
            
            # 获取地理位置
            local location
            location=$(curl -s --connect-timeout 5 "http://ip-api.com/json/${ip_address}" 2>/dev/null | jq -r '.country' 2>/dev/null)
            
            if [[ "$location" == "China" ]] || [[ "$location" == "CN" ]]; then
                log_success "检测为国内服务器 (IP: $ip_address)"
                IS_DOMESTIC=true
            elif [[ -n "$location" ]] && [[ "$location" != "null" ]]; then
                log_success "检测为国外服务器 (位置: $location, IP: $ip_address)"
                IS_DOMESTIC=false
            else
                log_warning "无法确定地理位置，默认判定为国内服务器"
                IS_DOMESTIC=true
            fi
        fi
    fi
}

# 检测显卡信息
function detect_gpu() {
    local nvidia_found=false
    
    # 方法1: 使用 lspci (最常用)
    if command -v lspci >/dev/null 2>&1; then
        local nvidia_gpus
        # 使用更宽松的匹配模式，包括 VGA、3D、Display 等
        nvidia_gpus=$(lspci 2>/dev/null | grep -iE 'nvidia.*(vga|3d|display)')
        
        if [[ -n "$nvidia_gpus" ]]; then
            nvidia_found=true
            HAS_NVIDIA=true
            log_success "检测到NVIDIA显卡 (lspci):"
            echo "$nvidia_gpus" | sed 's/^/  /'
        fi
    else
        log_warning "lspci命令不可用，尝试安装 pciutils"
        if sudo apt-get update >/dev/null 2>&1 && sudo apt-get install -y pciutils >/dev/null 2>&1; then
            log_success "pciutils 安装成功，重新检测"
            nvidia_gpus=$(lspci 2>/dev/null | grep -iE 'nvidia.*(vga|3d|display)')
            [[ -n "$nvidia_gpus" ]] && nvidia_found=true && HAS_NVIDIA=true
        fi
    fi
    
    # 方法2: 检查 /proc/driver/nvidia (如果驱动已安装)
    if [[ ! "$nvidia_found" = true ]] && [[ -d /proc/driver/nvidia ]]; then
        nvidia_found=true
        HAS_NVIDIA=true
        log_success "通过 /proc/driver/nvidia 检测到NVIDIA显卡"
    fi
    
    # 方法3: 检查 nvidia-smi (如果驱动已安装)
    if [[ ! "$nvidia_found" = true ]] && command -v nvidia-smi >/dev/null 2>&1; then
        if nvidia-smi >/dev/null 2>&1; then
            nvidia_found=true
            HAS_NVIDIA=true
            log_success "通过 nvidia-smi 检测到NVIDIA显卡"
        fi
    fi
    
    # 方法4: 检查系统设备文件
    if [[ ! "$nvidia_found" = true ]] && ls /dev/nvidia* >/dev/null 2>&1; then
        nvidia_found=true
        HAS_NVIDIA=true
        log_success "通过设备文件检测到NVIDIA显卡"
    fi
    
    # 方法5: 检查 lshw (备用方法)
    if [[ ! "$nvidia_found" = true ]] && command -v lshw >/dev/null 2>&1; then
        local nvidia_lshw
        nvidia_lshw=$(sudo lshw -C display 2>/dev/null | grep -i nvidia)
        if [[ -n "$nvidia_lshw" ]]; then
            nvidia_found=true
            HAS_NVIDIA=true
            log_success "通过 lshw 检测到NVIDIA显卡"
        fi
    fi
    
    # 如果没有找到NVIDIA显卡
    if [[ ! "$nvidia_found" = true ]]; then
        HAS_NVIDIA=false
        log_info "未检测到NVIDIA显卡"
    fi
    
    # 检测NVIDIA驱动和CUDA版本
    HAS_NVIDIA_DRIVER=false
    
    if command -v nvidia-smi >/dev/null 2>&1; then
        # 尝试运行 nvidia-smi
        if nvidia-smi >/dev/null 2>&1; then
            NVIDIA_DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d '[:space:]')
            CUDA_VERSION=$(nvidia-smi 2>/dev/null | grep -oP 'CUDA Version: \K[0-9.]+' | head -1)
            
            if [[ -n "$NVIDIA_DRIVER_VERSION" ]]; then
                log_success "NVIDIA驱动版本: $NVIDIA_DRIVER_VERSION"
                HAS_NVIDIA_DRIVER=true
                
                if [[ -n "$CUDA_VERSION" ]]; then
                    log_success "CUDA版本: $CUDA_VERSION"
                fi
                
                # 显示GPU详细信息
                log_info "GPU详细信息:"
                nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null | sed 's/^/  /'
            else
                log_warning "nvidia-smi可用但无法获取驱动版本"
            fi
        else
            log_warning "nvidia-smi命令存在但执行失败 (可能需要sudo权限或驱动未正确加载)"
        fi
    else
        log_info "未安装nvidia-smi (NVIDIA驱动未安装)"
    fi
    
    # 检查内核模块
    if lsmod 2>/dev/null | grep -q nvidia; then
        log_success "NVIDIA内核模块已加载"
        lsmod | grep nvidia | sed 's/^/  /'
    else
        log_info "NVIDIA内核模块未加载"
    fi
}

# ============================================
# 依赖安装函数
# ============================================

# 安装基础依赖
install_dependencies() {
    log_info "安装基础依赖包..."
    
    sudo apt-get update -qq
    
    local packages=(
        apt-transport-https
        ca-certificates
        curl
        gnupg
        lsb-release
        software-properties-common
        wget
        jq
        pciutils
    )
    
    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "需要安装: ${to_install[*]}"
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y "${to_install[@]}"
    else
        log_success "所有依赖包已安装"
    fi
}

# 配置国内镜像源
configure_domestic_mirrors() {
    log_info "配置阿里云APT镜像源..."
    
    # 备份原始sources.list
    if [[ -f /etc/apt/sources.list ]]; then
        sudo cp /etc/apt/sources.list "/etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)"
        log_success "已备份原始sources.list"
    fi
    
    case $OS in
        ubuntu)
            sudo tee /etc/apt/sources.list > /dev/null << EOF
# 阿里云Ubuntu镜像源
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
EOF
            ;;
        debian)
            sudo tee /etc/apt/sources.list > /dev/null << EOF
# 阿里云Debian镜像源
deb https://mirrors.aliyun.com/debian/ $CODENAME main non-free contrib
deb https://mirrors.aliyun.com/debian-security/ $CODENAME-security main
deb https://mirrors.aliyun.com/debian/ $CODENAME-updates main non-free contrib
deb https://mirrors.aliyun.com/debian/ $CODENAME-backports main non-free contrib
EOF
            ;;
        *)
            log_warning "未明确支持的系统: $OS，跳过镜像源配置"
            ;;
    esac
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        log_success "镜像源配置完成"
        sudo apt-get update -qq
    fi
}

# ============================================
# Docker 安装函数
# ============================================

# 检查Docker是否已安装
check_docker_installed() {
    if command -v docker >/dev/null 2>&1; then
        DOCKER_INSTALLED=true
    else
        DOCKER_INSTALLED=false
    fi
}

# 卸载旧版本Docker
remove_old_docker() {
    log_info "卸载旧版本Docker..."
    
    local old_packages=(
        docker
        docker-engine
        docker.io
        containerd
        runc
    )
    
    for pkg in "${old_packages[@]}"; do
        sudo apt-get remove -y "$pkg" 2>/dev/null || true
    done
    
    log_success "旧版本清理完成"
}

# 国内安装Docker
install_docker_domestic() {
    log_info "使用阿里云镜像安装Docker..."
    
    remove_old_docker
    
    # 添加Docker GPG密钥
    if [[ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]]; then
        curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | \
            sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    fi
    
    # 添加Docker仓库
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $CODENAME stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update -qq
    
    # 安装Docker
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    # 配置Docker镜像加速
    configure_docker_mirrors_domestic
    
    # 启动Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker安装完成: $(docker --version)"
    DOCKER_INSTALLED=true
}

# 国外安装Docker
install_docker_foreign() {
    log_info "使用官方脚本安装Docker..."
    
    # 使用官方安装脚本
    if [[ ! -f get-docker.sh ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
    fi
    
    sudo sh get-docker.sh
    
    # 配置镜像加速（可选）
    configure_docker_mirrors_foreign
    
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker安装完成: $(docker --version)"
    DOCKER_INSTALLED=true
}

# 配置Docker镜像加速（国内）
configure_docker_mirrors_domestic() {
    log_info "配置Docker镜像加速器..."
    
    sudo mkdir -p /etc/docker
    
    [[ -f /etc/docker/daemon.json ]] && \
        sudo cp /etc/docker/daemon.json "/etc/docker/daemon.json.backup.$(date +%Y%m%d_%H%M%S)"
    
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "registry-mirrors": [
        "https://docker.1panel.live",
        "https://docker.m.daocloud.io",
        "https://docker.1ms.run"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    log_success "Docker镜像加速配置完成"
}

# 配置Docker镜像加速（国外）
configure_docker_mirrors_foreign() {
    log_info "配置Docker日志轮转..."
    
    sudo mkdir -p /etc/docker
    
    [[ -f /etc/docker/daemon.json ]] && \
        sudo cp /etc/docker/daemon.json "/etc/docker/daemon.json.backup.$(date +%Y%m%d_%H%M%S)"
    
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

# ============================================
# NVIDIA 驱动和Docker支持安装
# ============================================

# 验证驱动版本一致性
verify_nvidia_driver() {
    DRIVER_VERIFIED=false
    
    local driver_version
    local nvml_version
    
    driver_version=$(cat /proc/driver/nvidia/version 2>/dev/null | grep -oP 'NVRM version:.*?Kernel Module\s+\K[0-9.]+' || echo "")
    nvml_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || echo "")
    
    if [[ -z "$driver_version" ]] || [[ -z "$nvml_version" ]]; then
        log_error "无法获取驱动版本信息"
    elif [[ "$driver_version" == "$nvml_version" ]]; then
        log_success "驱动版本验证通过: $driver_version"
        DRIVER_VERIFIED=true
    else
        log_error "驱动版本不匹配 - 内核: $driver_version, NVML: $nvml_version"
    fi
}

# 安装NVIDIA驱动
install_nvidia_driver() {
    log_info "安装NVIDIA驱动..."
    
    # 添加NVIDIA驱动PPA
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt-get update -qq
    
    # 自动安装推荐驱动
    log_info "自动检测并安装推荐驱动..."
    sudo ubuntu-drivers autoinstall
    
    # 加载NVIDIA内核模块
    sudo modprobe nvidia 2>/dev/null || true
    
    # 验证驱动
    verify_nvidia_driver
    
    if [[ "$DRIVER_VERIFIED" == "true" ]]; then
        log_success "NVIDIA驱动安装成功"
        HAS_NVIDIA_DRIVER=true
    else
        log_warning "驱动安装完成，但验证失败，可能需要重启"
        NEED_REBOOT=true
    fi
}

# 卸载不匹配的NVIDIA驱动
remove_nvidia_driver() {
    log_warning "卸载现有NVIDIA驱动..."
    
    # 终止可能占用apt的进程
    sudo killall apt apt-get dpkg 2>/dev/null || true
    sleep 2
    
    # 卸载NVIDIA相关包
    DEBIAN_FRONTEND=noninteractive sudo apt-get remove --purge -y '^nvidia-.*' '^libnvidia-.*' 2>/dev/null || true
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    
    log_success "驱动卸载完成"
}

# 检查并安装/修复NVIDIA驱动
ensure_nvidia_driver() {
    if [[ "$HAS_NVIDIA_DRIVER" == "true" ]]; then
        log_info "检查现有驱动一致性..."
        
        verify_nvidia_driver
        
        if [[ "$DRIVER_VERIFIED" == "true" ]]; then
            log_success "现有驱动验证通过"
        else
            log_warning "驱动版本不一致，需要重新安装"
            remove_nvidia_driver
            install_nvidia_driver
        fi
    else
        install_nvidia_driver
    fi
}

# 检查NVIDIA Container Toolkit是否已安装
check_nvidia_toolkit_installed() {
    if dpkg -l | grep -q nvidia-container-toolkit; then
        NVIDIA_TOOLKIT_INSTALLED=true
    else
        NVIDIA_TOOLKIT_INSTALLED=false
    fi
}

# 安装NVIDIA Container Toolkit（国内）
install_nvidia_toolkit_domestic() {
    log_info "安装NVIDIA Container Toolkit（国内镜像）..."
    
    check_nvidia_toolkit_installed
    
    if [[ "$NVIDIA_TOOLKIT_INSTALLED" == "true" ]]; then
        log_info "NVIDIA Container Toolkit已安装"
    else
        # 添加GPG密钥
        if [[ ! -f /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg ]]; then
            curl -fsSL https://mirrors.ustc.edu.cn/libnvidia-container/gpgkey | \
                sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        fi
        
        # 添加仓库
        echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://mirrors.ustc.edu.cn/libnvidia-container/stable/deb/$(dpkg --print-architecture) /" | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
        
        sudo apt-get update -qq
        
        # 安装
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
            nvidia-container-toolkit \
            nvidia-container-runtime
        
        # 配置Docker运行时
        sudo nvidia-ctk runtime configure --runtime=docker
        
        configure_docker_with_nvidia
        
        log_success "NVIDIA Container Toolkit安装完成"
        NVIDIA_TOOLKIT_INSTALLED=true
    fi
}

# 安装NVIDIA Container Toolkit（国外）
install_nvidia_toolkit_foreign() {
    log_info "安装NVIDIA Container Toolkit（官方源）..."
    
    check_nvidia_toolkit_installed
    
    if [[ "$NVIDIA_TOOLKIT_INSTALLED" == "true" ]]; then
        log_info "NVIDIA Container Toolkit已安装"
    else
        # 添加GPG密钥和仓库
        local distribution
        distribution=$(. /etc/os-release; echo "$ID$VERSION_ID")
        
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
            sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        
        curl -s -L "https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list" | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
        
        sudo apt-get update -qq
        
        # 安装
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
            nvidia-container-toolkit
        
        # 配置Docker运行时
        sudo nvidia-ctk runtime configure --runtime=docker
        
        configure_docker_with_nvidia
        
        log_success "NVIDIA Container Toolkit安装完成"
        NVIDIA_TOOLKIT_INSTALLED=true
    fi
}

# 配置Docker使用NVIDIA运行时
configure_docker_with_nvidia() {
    log_info "配置Docker NVIDIA运行时..."
    
    local daemon_config
    if [[ "$IS_DOMESTIC" == "true" ]]; then
        daemon_config=$(cat << 'EOF'
{
    "registry-mirrors": [
        "https://docker.1panel.live",
        "https://docker.m.daocloud.io",
        "https://docker.1ms.run"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
)
    else
        daemon_config=$(cat << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
)
    fi
    
    echo "$daemon_config" | sudo tee /etc/docker/daemon.json > /dev/null
    
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    # 验证Docker重启
    if ! sudo systemctl is-active --quiet docker; then
        log_error "Docker重启失败"
    else
        log_success "Docker NVIDIA运行时配置完成"
    fi
}

# ============================================
# 测试和验证函数
# ============================================

# 测试Docker安装
test_docker() {
    log_info "测试Docker安装..."
    
    if ! sudo systemctl is-active --quiet docker; then
        log_error "Docker服务未运行"
    elif sudo docker run --rm hello-world >/dev/null 2>&1; then
        log_success "Docker测试通过"
    else
        log_warning "Docker测试失败"
    fi
}

# 测试NVIDIA Docker
test_nvidia_docker() {
    log_info "测试NVIDIA Docker..."
    
    if sudo docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi >/dev/null 2>&1; then
        log_success "NVIDIA Docker测试通过"
    else
        log_warning "NVIDIA Docker测试失败，可能需要重启系统"
    fi
}

# ============================================
# 主安装流程
# ============================================

# 国内服务器完整安装流程
install_domestic() {
    log_info "========== 国内服务器安装流程 =========="
    
    detect_system
    install_dependencies
    configure_domestic_mirrors
    
    # 安装Docker
    check_docker_installed
    if [[ "$DOCKER_INSTALLED" == "false" ]]; then
        install_docker_domestic
    else
        log_info "Docker已安装，跳过安装"
    fi
    
    # 安装NVIDIA支持
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        ensure_nvidia_driver
        install_nvidia_toolkit_domestic
    else
        log_info "未检测到NVIDIA显卡，跳过NVIDIA支持安装"
    fi
}

# 国外服务器完整安装流程
install_foreign() {
    log_info "========== 国外服务器安装流程 =========="
    
    detect_system
    install_dependencies
    
    # 安装Docker
    check_docker_installed
    if [[ "$DOCKER_INSTALLED" == "false" ]]; then
        install_docker_foreign
    else
        log_info "Docker已安装，跳过安装"
    fi
    
    # 安装NVIDIA支持
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        ensure_nvidia_driver
        install_nvidia_toolkit_foreign
    else
        log_info "未检测到NVIDIA显卡，跳过NVIDIA支持安装"
    fi
}

# 显示最终信息
show_summary() {
    echo ""
    log_success "=========================================="
    log_success "         安装完成！"
    log_success "=========================================="
    echo ""
    log_info "系统信息:"
    log_info "  操作系统: ${PRETTY_NAME:-未知}"
    log_info "  架构: $ARCH"
    log_info "  Docker版本: $(docker --version 2>/dev/null || echo '未安装')"
    
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        echo ""
        log_info "NVIDIA信息:"
        if [[ "$HAS_NVIDIA_DRIVER" == "true" ]]; then
            log_info "  驱动版本: ${NVIDIA_DRIVER_VERSION:-未知}"
            log_info "  CUDA版本: ${CUDA_VERSION:-未知}"
        else
            log_warning "  驱动未安装或未激活"
        fi
    fi
    
    echo ""
    log_info "常用命令:"
    log_info "  查看Docker状态: systemctl status docker"
    log_info "  运行测试容器: docker run hello-world"
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        log_info "  测试GPU支持: docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi"
    fi
    
    if [[ "$NEED_REBOOT" == "true" ]]; then
        echo ""
        log_warning "=========================================="
        log_warning "  需要重启系统以完成NVIDIA驱动安装"
        log_warning "  请运行: sudo reboot"
        log_warning "  重启后可再次运行此脚本验证安装"
        log_warning "=========================================="
    fi
}

# ============================================
# 主函数
# ============================================

main() {
    log_info "=========================================="
    log_info "  Docker & NVIDIA Docker 自动安装脚本"
    log_info "=========================================="
    echo ""
    
    # 检查是否为root或有sudo权限
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        log_error "此脚本需要sudo权限，请使用 sudo 运行或以root用户运行"
        exit 1
    fi
    
    # 环境检测
    detect_location
    detect_gpu

    # 检查是否存在 NVIDIA GPU
if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
    # 服务器存在显卡
    HAS_GPU=true
else
    # 服务器不存在显卡
    HAS_GPU=false
fi

# 检查是否安装 Docker
if command -v docker &> /dev/null && systemctl is-active --quiet docker 2>/dev/null; then
    DOCKER_INSTALLED=true
else
    DOCKER_INSTALLED=false
fi

# 检查 Docker 是否能访问显卡（仅在有显卡且 Docker 已安装时检查）
if [ "$HAS_GPU" = true ] && [ "$DOCKER_INSTALLED" = true ]; then
    if docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        GPU_ACCESSIBLE=true
    else
        GPU_ACCESSIBLE=false
    fi
else
    GPU_ACCESSIBLE=false
fi

# 根据条件返回结果
if [ "$HAS_GPU" = true ]; then
    # 存在显卡的情况
    if [ "$DOCKER_INSTALLED" = false ] || [ "$GPU_ACCESSIBLE" = false ]; then
            # 根据位置选择安装策略
            if [[ "$IS_DOMESTIC" == "true" ]]; then
                install_domestic
            else
                install_foreign
            fi
    
            # 测试安装
            echo ""
            test_docker
    
            if [[ "$HAS_NVIDIA" == "true" ]] && [[ "$HAS_NVIDIA_DRIVER" == "true" ]]; then
                test_nvidia_docker
            fi
    else
        log_info "检查通过"
    fi
else
    # 不存在显卡的情况
    if [ "$DOCKER_INSTALLED" = false ]; then
            # 根据位置选择安装策略
            if [[ "$IS_DOMESTIC" == "true" ]]; then
                install_domestic
            else
                install_foreign
            fi
    
            # 测试安装
            echo ""
            test_docker
    
            if [[ "$HAS_NVIDIA" == "true" ]] && [[ "$HAS_NVIDIA_DRIVER" == "true" ]]; then
                test_nvidia_docker
            fi
    else
        log_info "检查通过"
    fi
fi

    # 显示摘要
    show_summary
}

# 执行主函数
main "$@"
