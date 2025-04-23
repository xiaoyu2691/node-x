#!/bin/bash
# File: install_node.sh

LOG_DIR="/var/log/script_tv"
mkdir -p $LOG_DIR
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

main() {
  apt install curl jq -y
  PID=$(ps -u stv -o pid,cmd | grep -w "script_tv__script4__wallet" | awk '{print $1}')
  Name="Script_TV"

  if [ -n "$PID" ]; then
    echo "$Name is running: $PID"
    exit 1
  else
    echo "$Name is not running"
  fi
  # 原检测逻辑
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    case "$ID" in
      ubuntu)
        # Extract major version number
        UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
        
        # Check if version is 23 or higher
        if [ "$UBUNTU_VERSION" -ge 23 ]; then
          echo "Ubuntu version $VERSION_ID detected (OK)"
          run_ubuntu_install $1
        else
          echo "Error: Ubuntu必须大于等于23版本. 当前版本: $VERSION_ID" >&2
          exit 1
        fi
        ;;
      debian)
        run_debian_install $1
        ;;
      *)
        echo "Unsupported OS" >&2
        exit 1
        ;;
    esac
  else
    echo "OS detection failed" >&2
    exit 1
  fi
}

run_ubuntu_install() {
  local node_private_key=$1
  
  echo "starting install mongoDB..."
  if dpkg -l | grep -q mongodb-org; then
    echo "MongoDB 已安装，检查服务状态..."
    
    # 检查服务状态
    if systemctl is-active mongod &>/dev/null; then
        echo "MongoDB 服务正在运行，无需进一步操作。"
        exit 0
    else
        echo "MongoDB 服务未运行，尝试启动..."
        sudo systemctl start mongod
        
        # 检查启动是否成功
        if systemctl is-active mongod &>/dev/null; then
            echo "MongoDB 服务已成功启动。"
            exit 0
        else
            echo "MongoDB 服务启动失败，执行重新安装..."
        fi
    fi
  else
      echo "MongoDB 未安装，开始安装流程..."
  fi
  
  # 开始安装/重新安装流程
  echo "开始执行 MongoDB 安装/重装流程..."
  
  # 1. 停止 MongoDB 服务（如果正在运行）
  sudo systemctl stop mongod &>/dev/null || true
  
  # 2. 完全卸载现有的 MongoDB 及其依赖
  sudo apt-get purge mongodb mongodb-server mongodb-clients mongodb-server-core mongodb-database-tools mongodb-org* -y
  sudo apt-get autoremove -y
  
  # 3. 清理 MongoDB 数据目录和配置文件
  sudo rm -rf /var/lib/mongodb
  sudo rm -rf /var/log/mongodb
  sudo rm -rf /etc/mongodb.conf
  sudo rm -rf /etc/mongod.conf
  
  # 4. 安装必要的依赖
  sudo apt-get update
  sudo apt-get install -y gnupg curl wget apt-transport-https ca-certificates software-properties-common
  
  # 5. 导入 MongoDB 公钥
  curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
  
  # 6. 添加 MongoDB 源 (Ubuntu 24.04 使用 noble 代号)
  echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
  
  # 7. 更新软件包列表
  sudo apt-get update
  
  # 8. 安装 MongoDB
  sudo apt-get install -y mongodb-org
  
  # 9. 创建必要的数据目录（如果不存在）
  sudo mkdir -p /var/lib/mongodb
  sudo mkdir -p /var/log/mongodb
  sudo chown -R mongodb:mongodb /var/lib/mongodb
  sudo chown -R mongodb:mongodb /var/log/mongodb
  
  # 10. 启用并启动 MongoDB 服务
  sudo systemctl enable mongod
  sudo systemctl start mongod
  
  # 11. 验证 MongoDB 状态
  if systemctl is-active mongod &>/dev/null; then
      echo "MongoDB 安装成功并且服务已启动！"
      sudo systemctl status mongod
  else
      echo "MongoDB 安装可能出现问题，请检查日志文件 /var/log/mongodb/mongod.log"
      exit 1
  fi
  echo "Starting Ubuntu installation..."
  apt install curl -y
  apt install wget -y
  if [ -z "$node_private_key" ]; then
    curl -sSL https://download.script.tv/files/script_tv-node-mainnet_debian_11_x86_64__install.sh | bash
  else
      wget -q -O install.sh https://download.script.tv/files/script_tv-node-mainnet_debian_11_x86_64__install.sh && \
      chmod +x install.sh && \
      ./install.sh --node_key "$node_private_key"
  fi
}

run_debian_install() {
  local node_private_key=$1
  echo "starting install mongoDB..."
  # 检查是否已安装 MongoDB
  if dpkg -l | grep -q mongodb-org; then
      echo "MongoDB 已安装，检查服务状态..."
      
      # 检查服务状态
      if systemctl is-active mongod &>/dev/null; then
          echo "MongoDB 服务正在运行，无需进一步操作。"
          exit 0
      else
          echo "MongoDB 服务未运行，尝试启动..."
          sudo systemctl start mongod
          
          # 检查启动是否成功
          if systemctl is-active mongod &>/dev/null; then
              echo "MongoDB 服务已成功启动。"
              exit 0
          else
              echo "MongoDB 服务启动失败，执行重新安装..."
          fi
      fi
  else
      echo "MongoDB 未安装，开始安装流程..."
  fi
  
  # 开始安装/重新安装流程
  echo "开始执行 MongoDB 安装/重装流程..."
  
  # 1. 停止 MongoDB 服务（如果正在运行）
  sudo systemctl stop mongod &>/dev/null || true
  
  # 2. 完全卸载现有的 MongoDB 及其依赖
  sudo apt-get purge mongodb mongodb-server mongodb-clients mongodb-server-core mongodb-database-tools mongodb-org* -y
  sudo apt-get autoremove -y
  
  # 3. 清理 MongoDB 数据目录和配置文件
  sudo rm -rf /var/lib/mongodb
  sudo rm -rf /var/log/mongodb
  sudo rm -rf /etc/mongodb.conf
  sudo rm -rf /etc/mongod.conf
  
  # 4. 安装必要的依赖
  sudo apt-get update
  sudo apt-get install -y gnupg curl wget apt-transport-https ca-certificates software-properties-common
  
  # 5. 导入 MongoDB 公钥
  curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
  
  # 6. 添加 MongoDB 源（Debian 12 代号为 bookworm）
  echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
  
  # 7. 更新软件包列表
  sudo apt-get update
  
  # 8. 安装 MongoDB
  sudo apt-get install -y mongodb-org
  
  # 9. 创建必要的数据目录（如果不存在）
  sudo mkdir -p /var/lib/mongodb
  sudo mkdir -p /var/log/mongodb
  sudo chown -R mongodb:mongodb /var/lib/mongodb
  sudo chown -R mongodb:mongodb /var/log/mongodb
  
  # 10. 启用并启动 MongoDB 服务
  sudo systemctl enable mongod
  sudo systemctl start mongod
  
  # 11. 验证 MongoDB 状态
  if systemctl is-active mongod &>/dev/null; then
      echo "MongoDB 安装成功并且服务已启动！"
      sudo systemctl status mongod
  else
      echo "MongoDB 安装可能出现问题，请检查日志文件 /var/log/mongodb/mongod.log"
      exit 1
  fi
  echo "Starting Debian installation..."
  apt install curl -y
  apt install wget -y
  if [ -z "$node_private_key" ]; then
    curl -sSL https://download.script.tv/files/script_tv-node-mainnet_debian_11_x86_64__install.sh | bash
  else
      wget -q -O install.sh https://download.script.tv/files/script_tv-node-mainnet_debian_11_x86_64__install.sh && \
      chmod +x install.sh && \
      ./install.sh --node_key "$node_private_key"
  fi
}

# 执行主函数并记录日志
main 2>&1 | tee "${LOG_DIR}/install_${TIMESTAMP}.log"
