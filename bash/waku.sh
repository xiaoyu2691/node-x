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
	
	#切换到文件目录中
	cd /root/nwaku-compose
  	#复制.env文件
   	cp .env.example .env

    	echo "配置.env文件"
     	env_file=".env"
	echo "请输入你的RPC(https://sepolia.infura.io/v3/<key>):"
 	read RLN_RELAY_ETH_CLIENT_ADDRESS
  	echo "请输入你的私钥（至少需要持有0.6 Sepolia ETH):"
   	read ETH_TESTNET_KEY
    	echo "请输入你的密码："
     	read RLN_RELAY_CRED_PASSWORD

 	echo "RLN_RELAY_ETH_CLIENT_ADDRESS=$RLN_RELAY_ETH_CLIENT_ADDRESS" > $env_file
	echo "ETH_TESTNET_KEY=$ETH_TESTNET_KEY" >> $env_file
 	echo "RLN_RELAY_CRED_PASSWORD=$RLN_RELAY_CRED_PASSWORD" >> $env_file
  	echo "NWAKU_IMAGE=" >> $env_file
	echo "NODEKEY=" >> $env_file
    	echo "DOMAIN=" >> $env_file
	echo "EXTRA_ARGS=" >> $env_file
      	echo "STORAGE_SIZE=" >> $env_file

  	echo ".env文件已配置完成,内容如下"
   	cat $env_file
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

#显示主菜单
main_menu
