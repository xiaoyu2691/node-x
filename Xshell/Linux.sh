#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Linux.sh"

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    
    # 更新系统
    sudo apt update -y && sudo apt upgrade -y
    
    # 移除旧版本
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done

    # 安装必要的包
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # 添加 Docker 的源
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 再次更新并安装 Docker
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 检查 Docker 版本
    docker --version
else
    echo "Docker 已安装，版本为: $(docker --version)"
fi

# 获取相对路径
relative_path=$(realpath --relative-to=/usr/share/zoneinfo /etc/localtime)
echo "相对路径为: $relative_path"

# 创建 chromium 目录并进入
mkdir -p $HOME/chromium
cd $HOME/chromium
echo "已进入 chromium 目录"

# 创建 docker-compose.yaml 文件并启动的函数
function deploy_browser() {
    # 获取用户输入
    read -p "请输入 CUSTOM_USER: " CUSTOM_USER
    read -sp "请输入 PASSWORD: " PASSWORD
    echo

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
      - CHROME_CLI=https://x.com/nodex_xyz #optional
    volumes:
      - /root/chromium/config:/config
    ports:
      - 3010:3000   #Change 3010 to your favorite port if needed
      - 3011:3001   #Change 3011 to your favorite port if needed
    shm_size: "1gb"
    restart: unless-stopped
EOF

    echo "docker-compose.yaml 文件已创建，内容已导入。"
    docker compose up -d
    echo "Docker Compose 已启动。"
}

# 卸载 节点 的函数
function uninstall_docker() {
    echo "正在停止 Docker..."
    # 停止 Docker 容器
    cd /root/chromium
    docker compose down

    # 删除 文件 目录
    rm -rf /root/chromium
    echo "节点已卸载完成。"
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "node-X"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 部署浏览器"
        echo "2) 卸载节点"
        echo "3) 退出"
        
        read -p "请输入选项: " choice
        
        case $choice in
            1)
                deploy_browser
                ;;
            2)
                uninstall_docker
                ;;
            3)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效选项，请重试。"
                ;;
        esac

        read -p "按任意键继续..."
    done
}

# 调用主菜单
main_menu
