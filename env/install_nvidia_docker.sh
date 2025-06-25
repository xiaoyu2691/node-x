#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 更新系统包
update_system() {
    log_info "更新系统包..."
    
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        wget \
        unzip
    
    log_success "系统包更新完成"
}

configure_apt_sources() {
    log_info "配置阿里云APT镜像源..."
    
    # 备份原始sources.list
    if [[ -f /etc/apt/sources.list ]]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)
        log_success "已备份原始sources.list"
    fi
    
    # 根据系统版本配置镜像源
    case $OS in
        ubuntu)
            case $CODENAME in
                jammy|focal|bionic|xenial)
                    cat > /etc/apt/sources.list << UBUNTUEOF
# 阿里云Ubuntu镜像源
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-proposed main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse

# deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
UBUNTUEOF
                    ;;
                *)
                    log_warning "未明确支持的Ubuntu版本: $CODENAME，使用默认配置"
                    ;;
            esac
            ;;
        debian)
            cat > /etc/apt/sources.list << DEBIANEOF
# 阿里云Debian镜像源
deb https://mirrors.aliyun.com/debian/ $CODENAME main non-free contrib
deb https://mirrors.aliyun.com/debian-security/ $CODENAME-security main
deb https://mirrors.aliyun.com/debian/ $CODENAME-updates main non-free contrib
deb https://mirrors.aliyun.com/debian/ $CODENAME-backports main non-free contrib
DEBIANEOF
            ;;
        *)
            log_warning "未明确支持的系统: $OS，跳过镜像源配置"
            return
            ;;
    esac
    
    log_success "已配置阿里云APT镜像源"
}

detect_system() {
    log_info "检测系统信息..."
    
    # 检测操作系统
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        CODENAME=$VERSION_CODENAME
    else
        log_error "无法检测操作系统"
        exit 1
    fi
    
    log_success "检测到系统: $PRETTY_NAME"
    
    # 检测架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armhf"
            ;;
        *)
            log_error "不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    log_success "检测到架构: $ARCH"
}

# 检测显卡信息
detect_gpu() {
    log_info "检测显卡信息..."
    
    # 检测NVIDIA显卡
    if command -v lspci >/dev/null 2>&1; then
        NVIDIA_GPUS=$(lspci | grep -i nvidia | grep -i vga)
        if [[ -n "$NVIDIA_GPUS" ]]; then
            HAS_NVIDIA=true
            log_success "检测到NVIDIA显卡:"
            echo "$NVIDIA_GPUS" | while read line; do
                echo "  $line"
            done
            
            # 获取显卡型号
            GPU_MODEL=$(echo "$NVIDIA_GPUS" | head -1 | sed 's/.*NVIDIA Corporation //' | sed 's/ \[.*\]//')
            log_info "主显卡型号: $GPU_MODEL"
        else
            HAS_NVIDIA=false
            log_info "未检测到NVIDIA显卡"
        fi
    else
        log_warning "lspci命令不可用，无法检测显卡"
        HAS_NVIDIA=false
    fi
    
    # 检测当前NVIDIA驱动
    if command -v nvidia-smi >/dev/null 2>&1; then
        NVIDIA_DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        CUDA_VERSION=$(nvidia-smi --query-gpu=cuda_version --format=csv,noheader,nounits | head -1)
        log_success "检测到NVIDIA驱动版本: $NVIDIA_DRIVER_VERSION"
        log_success "检测到CUDA版本: $CUDA_VERSION"
        HAS_NVIDIA_DRIVER=true
    else
        log_info "未检测到NVIDIA驱动"
        HAS_NVIDIA_DRIVER=false
    fi
}

# 安装NVIDIA容器支持
install_nvidia_docker() {
    if [[ "$HAS_NVIDIA" != "true" ]]; then
        log_info "未检测到NVIDIA显卡，跳过NVIDIA Docker安装"
        return
    fi
    
    log_info "安装NVIDIA容器支持..."
    
    # 安装NVIDIA驱动（如果未安装）
    if [[ "$HAS_NVIDIA_DRIVER" != "true" ]]; then
        log_info "安装NVIDIA驱动..."
        
        # 添加NVIDIA驱动PPA
        add-apt-repository -y ppa:graphics-drivers/ppa
        apt-get update
        
        # 自动检测推荐驱动
        RECOMMENDED_DRIVER=$(ubuntu-drivers devices | grep recommended | awk '{print $3}' | head -1)
        if [[ -n "$RECOMMENDED_DRIVER" ]]; then
            log_info "安装推荐驱动: $RECOMMENDED_DRIVER"
            apt-get install -y "$RECOMMENDED_DRIVER"
        else
            log_info "安装最新稳定版驱动"
            apt-get install -y nvidia-driver-535
        fi
        
        log_warning "NVIDIA驱动安装完成，需要重启系统后才能继续安装NVIDIA Docker"
        log_warning "请运行: sudo reboot"
        log_warning "重启后重新运行此脚本继续安装NVIDIA Docker组件"
        return
    fi
    
    # 添加NVIDIA Container Toolkit仓库
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    apt-get update
    
    # 安装NVIDIA Container Toolkit
    apt-get install -y nvidia-container-toolkit nvidia-container-runtime
    
    # 配置Docker使用NVIDIA运行时
    nvidia-ctk runtime configure --runtime=docker
    
    # 更新Docker配置
    if [[ -f /etc/docker/daemon.json ]]; then
        # 备份现有配置
        cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
        
        # 使用jq更新配置（如果没有jq则手动处理）
        if command -v jq >/dev/null 2>&1; then
            jq '. + {"default-runtime": "nvidia", "runtimes": {"nvidia": {"path": "nvidia-container-runtime", "runtimeArgs": []}}}' /etc/docker/daemon.json > /tmp/daemon.json
            mv /tmp/daemon.json /etc/docker/daemon.json
        else
            # 手动更新配置
            cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": [
        "https://registry.cn-hangzhou.aliyuncs.com",
        "https://mirror.ccs.tencentyun.com",
        "https://reg-mirror.qiniu.com"
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
        fi
    fi
    
    # 重启Docker服务
    systemctl restart docker
    
    # 安装CUDA Toolkit（可选）
    install_cuda=$2
    if [[ $install_cuda =~ ^[Yy]$ ]]; then
        log_info "安装CUDA Toolkit..."
        
        # 检测合适的CUDA版本
        if [[ -n "$CUDA_VERSION" ]]; then
            CUDA_MAJOR=$(echo $CUDA_VERSION | cut -d. -f1)
            CUDA_MINOR=$(echo $CUDA_VERSION | cut -d. -f2)
            log_info "根据驱动版本安装CUDA $CUDA_MAJOR.$CUDA_MINOR"
            
            case $CUDA_MAJOR in
                12)
                    apt-get install -y cuda-toolkit-12-0
                    ;;
                11)
                    apt-get install -y cuda-toolkit-11-8
                    ;;
                *)
                    apt-get install -y cuda-toolkit
                    ;;
            esac
        else
            apt-get install -y cuda-toolkit
        fi
        
        # 配置环境变量
        echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /etc/environment
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /etc/environment
        
        log_success "CUDA Toolkit安装完成"
    fi
    
    log_success "NVIDIA Docker支持安装完成"
}

# 测试安装
test_installation() {
    log_info "测试Docker安装..."
    
    # 测试Docker
    if docker run --rm hello-world >/dev/null 2>&1; then
        log_success "Docker测试通过"
    else
        log_error "Docker测试失败"
    fi
    
    # 测试NVIDIA Docker（如果安装了）
    if [[ "$HAS_NVIDIA" == "true" && "$HAS_NVIDIA_DRIVER" == "true" ]]; then
        log_info "测试NVIDIA Docker..."
        if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi >/dev/null 2>&1; then
            log_success "NVIDIA Docker测试通过"
        else
            log_warning "NVIDIA Docker测试失败，可能需要重启系统"
        fi
    fi
}

# 显示安装完成信息
show_completion_info() {
    log_success "Docker安装脚本执行完成！"
    echo ""
    echo "安装信息:"
    echo "=========================================="
    echo "操作系统: $PRETTY_NAME"
    echo "架构: $ARCH"
    echo "Docker版本: $(docker --version)"
    
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        echo "显卡支持: 已启用NVIDIA支持"
        if [[ "$HAS_NVIDIA_DRIVER" == "true" ]]; then
            echo "NVIDIA驱动: $NVIDIA_DRIVER_VERSION"
            echo "CUDA版本: $CUDA_VERSION"
        fi
    else
        echo "显卡支持: 无NVIDIA显卡"
    fi
    
    echo "=========================================="
    echo ""
    echo "使用说明:"
    echo "1. 运行Docker容器: docker run hello-world"
    if [[ "$HAS_NVIDIA" == "true" ]]; then
        echo "2. 运行GPU容器: docker run --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi"
    fi
    echo "3. 查看Docker状态: systemctl status docker"
    echo "4. 查看Docker日志: journalctl -u docker"
    echo ""
    
    if [[ "$HAS_NVIDIA" == "true" && "$HAS_NVIDIA_DRIVER" != "true" ]]; then
        log_warning "检测到NVIDIA显卡但未安装驱动，已安装驱动但需要重启系统"
        log_warning "请运行 'sudo reboot' 重启后重新运行脚本完成NVIDIA支持安装"
    fi
}

# 国内服务器安装docker
function domestic_docker_install() {
  log_info "开始安装docker......."
  
  log_info "使用aliyu镜像源进行安装"
  detect_system
  update_system
  configure_apt_sources
  detect_gpu
  
  apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
  # 添加Docker GPG密钥
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
  # 添加Docker仓库
  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
  apt-get update

  # 安装Docker
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  # 启动Docker服务
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo systemctl status docker

  # 配置Docker使用阿里云镜像加速器
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << JEOF
{
    "registry-mirrors": [
    "https://docker.1panel.live/",
    "https://docker.1ms.run/",
    "https://dytt.online",
	  "https://lispy.org",
	  "docker.xiaogenban1993.com",
	  "https://docker-0.unsee.tech",
	  "666860.xyz",
	  "https://docker.m.daocloud.io"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    }
}
JEOF
    
    # 重启Docker服务
    systemctl restart docker
    
    log_success "Docker安装完成"
    docker --version

    log_info "开始安装nvidia docker"
    install_nvidia_docker
    test_installation
    show_completion_info
}


# 国外服务器安装docker
function foreign_docker_install() {
  log_info "检查系统信息及升级部分系统包"
  update_system
  detect_system

  
  log_info "开始安装docker......."
  # 检查是否安装docker
  if ! command -v docker &> /dev/null; then
      log_info "Docker 未安装，正在安装 Docker..."
      
      # 安装 Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
  
      log_success "Docker 安装完成！"
  else
      log_info "Docker 已安装，跳过安装。"
  fi

  log_info "开始安装nvidia docker"
  install_nvidia_docker
  test_installation
  show_completion_info
}

sudo apt update
sudo apt install -y curl jq

# 获取本地IP地址
IP_ADDRESS=$(curl -s http://ipinfo.io/ip)
# 获取IP地址的地理位置
LOCATION=$(curl -s "http://ip-api.com/json/$IP_ADDRESS" | jq -r '.country')

if [ "$LOCATION" == "China" ]; then
    domestic_docker_install
else
    foreign_docker_install
fi
