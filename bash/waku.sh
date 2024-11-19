#!/bin/bash

 # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null; then
        echo "Docker 未安装，正在安装 Docker..."
        
        # 安装 Docker
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
 
        echo "Docker 安装完成！"
    else
        echo "Docker 已安装，跳过安装。"
    fi

  #检查是否安装docker-compose
     if ! command -v docker-compose &> /dev/null; then
        echo "Docker-compose 未安装，正在安装 Docker-compose..."
        
        # 安装 Docker-compose
  sudo apt-get update
	sudo apt-get install docker-compose-plugin
 
        echo "Docker-compose 安装完成！"
    else
        echo "Docker-compose 已安装，跳过安装。"
    fi

#注册RLN并启动waku节点
function install_node() {
	#克隆源文件
	git clone https://github.com/waku-org/nwaku-compose

    	# 配置文件路径
  local env_file="/root/nwaku-compose/.env"
  mkdir -p "$(dirname "$env_file")"

  # 写入配置文件
  cat <<EOF > "$env_file"
# RPC URL for accessing testnet via HTTP.
# e.g. https://sepolia.infura.io/v3/123aa110320f4aec179150fba1e1b1b1
RLN_RELAY_ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/"$KEY"

# Private key of testnet where you have sepolia ETH that would be staked into RLN contract.
# Note: make sure you don't use the '0x' prefix.
#       e.g. 0116196e9a8abed42dd1a22eb63fa2a5a17b0c27d716b87ded2c54f1bf192a0b
ETH_TESTNET_KEY="$PRIVATE_KEY"

# Password you would like to use to protect your RLN membership.
RLN_RELAY_CRED_PASSWORD="$PASSWORD"

# Advanced. Can be left empty in normal use cases.
NWAKU_IMAGE=
NODEKEY=
DOMAIN=
EXTRA_ARGS=
STORAGE_SIZE=
EOF

  	echo "开始注册成为RLN"
	#执行安装脚本
	./register_rln.sh
	echo "RLN注册成功并启动waku节点！！！"
 
  	docker-compose up -d
}

#卸载节点
function uninstall_node() {
	cd /root/nwaku-composecd
 	docker-compose down
  	cd
   	rm -rf nwaku-composecd
}

#备份
function backup {
    # 定义.env文件的路径，这里假设就在当前目录下创建，如果需要放在其他目录需修改路径
    env_file=".env"
    # 定义备份文件的存放目录，这里假设在当前目录下的backup文件夹中，若不存在会自动创建
    backup_dir="backup"
    # 获取当前时间戳，用于给备份文件命名
    timestamp=$(date +%Y%m%d%H%M%S)

    # 创建备份目录（如果不存在）
    mkdir -p $backup_dir

    # 备份private_key配置项
    backup_private_key
    # 备份password配置项
    backup_password
}

function backup_private_key {
    if grep -q "^private_key=" $env_file; then
        existing_private_key=$(grep "^private_key=" $env_file | cut -d '=' -f 2)
        backup_file="$backup_dir/private_key_backup_$timestamp.txt"
        echo "private_key=$existing_private_key" > $backup_file
        echo "已成功备份private_key到文件：$backup_file"
    fi
}

function backup_password {
    if grep -q "^password=" $env_file; then
        existing_password=$(grep "^password=" $env_file | cut -d '=' -f 2)
        backup_file_password="$backup_dir/password_backup_$timestamp.txt"
        echo "password=$existing_password" > $backup_file_password
        echo "已成功备份password到文件：$backup_file_password"
    fi
}

#查看节点日志
function cat_logs() {
	cd /root/nwaku-composecd
	docker-compose logs -f nwaku
}

#重启节点
function restart_node() {
	cd /root/nwaku-compose
 	docker-compose down
  	docker-compose up -d
}

# 自动安装与初始化函数
function autoinstall() {
    local PRIVATE_KEY=$1
    local KEY=$2
    local PASSWORD=$3
    
    echo -e "正在进行自动安装..."
    
    install_node
    sleep 15
    config_node "$KEY" "$PRIVATE_KEY" "$PASSWORD"
    echo -e "自动安装和配置已完成!"
}
#主菜单
function main_menu() {
	clear
	echo "=============================node-X节点一键部署========================================"
	echo "============================waku节点安装===================================="
	echo "请选择要执行的操作"
	echo "1、 安装waku节点"
	echo "2、 查看日志"
	echo "3、 备份信息"
	echo "4、 卸载节点"
 	echo "5、 重启节点"
	echo "6、 退出"
	read -p "请输入选项（1-6）：" OPTION

	case $OPTION in
	1) install_node ;;
	2) cat_logs ;;
	3) backup ;;
 	4) uninstall_node ;;
  	5) restart_node ;;
	6) exit 0 ;;
	*) echo "无效选项。" ;;
	esac
}
# 脚本入口，根据传入参数执行相应操作
if [ "$1" == "autoinstall" ]; then
    if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo -e "${RED}使用方法: ./cess.sh autoinstall <获取API KEY> <获取私钥> <获取密码>${NC}"
        exit 1
    else
        autoinstall "$2" "$3" "$4"
    fi
else
    # 调用主菜单
    main_menu
fi
