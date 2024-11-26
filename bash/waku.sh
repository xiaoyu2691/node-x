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

#配置.env文件
function env_node() {
	local RPC="$1"
	local PRIVATE_KEY="$2"
 	local PASSWORD="$3"

	#克隆源文件
	git clone https://github.com/waku-org/nwaku-compose

	# 配置文件路径
	local env_file="/root/nwaku-compose/.env"
	mkdir -p "$(dirname "$env_file")"

  # 写入配置文件
  cat <<EOF > "$env_file"
# RPC URL for accessing testnet via HTTP.
# e.g. https://sepolia.infura.io/v3/123aa110320f4aec179150fba1e1b1b1
RLN_RELAY_ETH_CLIENT_ADDRESS="$RPC"

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

	#生成配置并注册RLN
	cd nwaku-compose
	./register_rln.sh
 	sleep 20

# 检查指定文件夹下是否生成keystore.json文件
specific_text="Your membership has been registered on-chain."
# 检查Keystore.json是否存在
file_key_path="/root/nwaku-compose/keystore/keystore.json"
# 执行命令并获取返回结果，这里假设执行的命令是 "ls -l"，你需要替换为实际的命令
result=$(ls -l)
# 检查返回结果中是否存在特定内容
if [[ $result == *"$specific_text"* ]]; then
    echo "已经注册，直接跳过。"
    exit 0
fi

# 检查文件是否存在
if [! -f "$file_key_path" ]; then
    echo "注册失败：文件 $file_key_path 不存在。"
    exit 1
else
    echo "注册成功！！！"
    cd nwaku-compose
    docker-compose up -d
    sleep 10
    check_and_handle_port_error
fi
}

# 检查是否出现端口被占用错误并进行处理
function check_and_handle_port_error() {
    error_message="Error response from daemon: driver failed programming external connectivity on endpoint nwaku-compose-nwaku-1"
    if [[ $result == *"$error_message"* ]]; then
        echo "端口被占用"
	end
    else
        echo "运行成功！"
    fi
}

#设置端口
# function change_port() {
	# 容器名称
	# container_name="Container nwaku-compose-nwaku-1"

	# 检查8000端口是否被占用
	# is_8000_occupied=$(netstat -tln | grep -c :8000)
	# if [ $is_8000_occupied -gt 0 ]; then
    	# echo "8000端口已被占用，准备更换为8088端口。"
    	# new_port_8000=8088
	# lse
    	# new_port_8000=8000
	# fi

	# 检查80端口是否被占用
	# is_80_occupied=$(netstat -tln | grep -c :80)
	# if [ $is_80_occupied -gt 0 ]; then
	    # echo "80端口已被占用，准备更换为180端口。"
	    # new_port_80=180
	# else
	    # new_port_80=80
	# fi
	
	# 检查新端口8088是否被占用
	# is_8088_occupied=$(netstat -tln | grep -c :8088)
	# if [ $is_8088_occupied -gt 0 ]; then
	    # echo "8088端口已被占用，脚本中断。"
	    # exit 1
	# fi
	
	# 检查新端口180是否被占用
	# is_180_occupied=$(netstat -tln | grep -c :180)
	# if [ $is_180_occupied -gt 0 ]; then
	    # echo "180端口已被占用，脚本中断。"
	    # exit 1
	# fi
	
	# 停止容器
	# docker stop $container_name
	# 修改容器端口映射
	# docker container update --publish-rm 8000:8000 --publish-rm 80:80 \
	    # --publish-add $new_port_8000:$new_port_8000 --publish-add $new_port_80:$new_port_80 $container_name
	# echo "已根据端口占用情况成功更新容器 $container_name 的端口映射。"
 	# docker-compose up -d
# }

#卸载节点
function uninstall_node() {
	cd /root/nwaku-compose
 	docker-compose down
  	cd
   	rm -rf nwaku-compose
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
	cd /root/nwaku-compose
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
    local RPC=$1
    local PRIVATE_KEY=$2
    local PASSWORD=$3
    
    echo -e "正在进行自动安装..."

    env_node "$RPC" "$PRIVATE_KEY" "$PASSWORD"
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
case $1 in
    install)
        if [ "$1" == "autoinstall" ]; then
    if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo -e "${RED}使用方法: ./waku.sh autoinstall <获取RPC> <获取私钥> <获取密码>${NC}"
        exit 1
    else
        autoinstall "$2" "$3" "$4"
    fi
        ;;
    remove)
         uninstall_node
        ;;
    logs)
        cat_logs
        ;;
    restart)
        restart_node
        ;;
    *)
        echo "无效选项。"
        exit 1
        ;;
esac
