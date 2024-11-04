#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Linux.sh"

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    
    # 更新系统
    if ! sudo apt update -y && sudo apt upgrade -y; then
        echo "更新失败，请检查您的网络连接。"
        exit 1
    fi

    # 移除旧版本
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done

    # 安装必要的包
    if ! sudo apt-get install -y ca-certificates curl gnupg; then
        echo "安装必要包失败，请检查您的网络连接。"
        exit 1
    fi

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # 添加 Docker 的源
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 再次更新并安装 Docker
    if ! sudo apt update -y && sudo apt upgrade -y; then
        echo "更新失败，请检查您的网络连接。"
        exit 1
    fi

    if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
        echo "Docker 安装失败。"
        exit 1
    fi

    # 检查 Docker 版本
    echo "Docker 安装成功，版本为: $(docker --version)"
else
    echo "Docker 已安装，版本为: $(docker --version)"
fi

# 获取相对路径
relative_path=$(realpath --relative-to=/usr/share/zoneinfo /etc/localtime)
echo "相对路径为: $relative_path"

# 创建 chromium 目录并进入
mkdir -p $HOME/chromium
cd $HOME/chromium || { echo "进入 chromium 目录失败"; exit 1; }
echo "已进入 chromium 目录"

# 获取用户输入
read -p "请输入 CUSTOM_USER: " CUSTOM_USER
# 验证 CUSTOM_USER 输入
if [ -z "$CUSTOM_USER" ]; then
    echo "CUSTOM_USER 不能为空。"
    exit 1
fi

read -sp "请输入 PASSWORD: " PASSWORD
echo
# 验证 PASSWORD 输入
if [ -z "$PASSWORD" ]; then
    echo "PASSWORD 不能为空。"
    exit 1
fi

# 创建 docker-compose.yaml 文件
cat <<EOF > docker-compose.yaml
---
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - CHROME_CLI=https://www.google.com #optional
    volumes:
      - /root/chromium/config:/config
    ports:
      - 3010:3000   #可以根据需要更改为您喜欢的端口
      - 3011:3001   #可以根据需要更改为您喜欢的端口
    shm_size: "1gb"
    restart: unless-stopped
EOF

echo "docker-compose.yaml 文件已创建，内容已导入。"

# 启动 Docker Compose
if ! docker compose up -d; then
    echo "Docker Compose 启动失败。"
    exit 1
fi

# 获取服务器的 IP 地址
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "Docker Compose 已启动。"
echo "部署完成，请使用以下地址登录："
echo "您可以通过以下链接访问服务："
echo "http://$SERVER_IP:3010/"
echo "或"
echo "http://$SERVER_IP:3011/"
