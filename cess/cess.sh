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

#安装snap以及yq
function install_snap_and_yq() {
        # 判断是否安装了 Snap
        if ! command -v snap &> /dev/null 2>&1; then
                echo "Snap 未安装，正在安装 Snap..."
                sudo apt update
                sudo apt install snapd -y
        else
                 snap_version=$(snap --version | awk '{print $2}')
                echo "Snap 已安装，版本为：$snap_version"
        fi

        # 判断是否安装了 yq
        if ! command -v yq &> /dev/null 2>&1; then
                echo "yq 未安装，正在安装 yq..."
                sudo snap install yq
                yq_version=$(yq --version | awk '{print $2}')
                echo "yq 安装完成，版本为：$yq_version"
        else
                yq_version=$(yq --version | awk '{print $2}')
                echo "yq 已安装，版本为：$yq_version"
        fi
}

#检查系统是否安装防火墙，打开4001端口
function check_firewall() {
	if sudo ufw status | grep -q "status: active";then
		sudo ufw allow 4001
	else
		echo "未检测到防火墙，4001端口已打开"
	fi
}

#安装cess节点
function install_cess_node() {
	check_firewall
	#确保4001端口已打开
	
	echo "开始安装CESS节点"
	#下载cess安装包
	wget https://github.com/CESSProject/cess-nodeadm/archive/refs/tags/v0.5.8.tar.gz
	
	#解压压缩包
	tar -xvzf  v0.5.8.tar.gz
	
	#切换到安装包目录中
	cd /root/cess-nodeadm-0.5.8
	
	#执行安装脚本
	./install.sh
	echo "CESS节点安装成功！！！"
}

#停止并移除现有服务
function stop_service() {
	sudo cess stop
	sudo cess purge -Y
	echo "已移除现有服务"
}

#设置运行网络
function set_network() {
	sudo cess profile testnet
	echo "已将运行网络设置为测试网"
}

#设置配置并运行
function set_config() {
	#安装yq
	install_snap_and_yq
	stop_service
	set_network

	sudo cess  config set
	
	#启动cess节点
	sudo cess start
}

#升级节点
function upgrade_cess() {
	#停止节点
 	sudo cess miner exit
	sudo cess stop
	sudo cess down

	#升级节点
	wget https://github.com/CESSProject/cess-nodeadm/archive/vx.x.x.tar.gz
	tar -xvf vx.x.x.tar.gz
	cd cess-nodeadm-x.x.x
	sudo ./install.sh --skip-dep

	#运行节点
	sudo cess start
}

#领取奖励
function get_reward() {
	#领取奖励
 	sudo cess miner claim
}

#查看节点状态
function cat_status() {
	sudo cess miner stat
}

#查看节点日志
function cat_logs() {
	docker logs miner
}

#主菜单
function main_menu() {
	clear
	echo "node-X节点部署"
	echo "============================CESS_Storage节点安装===================================="
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
