#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

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
function install_waku_node() {
	#克隆源文件
	git clone https://github.com/waku-org/nwaku-compose
	
	#切换到文件目录中
	cd /root/nwaku-composecd
  
  echo "开始注册成为RLN"
	#执行安装脚本
	./register_rln.sh
	echo "RLN注册成功并启动waku节点！！！"
  docker-compose up -d
}

#查看节点日志
function cat_logs() {
	docker-compose logs -f nwaku
}

#主菜单
function main_menu() {
	clear
	echo "=============================node-X节点一键部署========================================"
	echo "============================waku节点安装===================================="
	echo "请选择要执行的操作"
	echo "1、 安装CESS存储节点"
	echo "2、 设置配置并运行CESS节点"
	echo "3、 查看节点状态"
	echo "4、 查看节点日志"
	echo "5、 升级节点"
 	echo "6、 领取奖励"
	echo "7、 退出"
	read -p "请输入选项（1-7）：" OPTION

	case $OPTION in
	1) install_cess_node ;;
	2) set_config ;;
	3) cat_status ;;
 	4) cat_logs ;;
	5) upgrade_cess ;;
 	6) get_reward ;;
	7) cat_logs ;;
	*) echo "无效选项。" ;;
	esac
}

#显示主菜单
main_menu
