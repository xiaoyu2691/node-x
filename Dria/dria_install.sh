#!/bin/bash

DRIACONF="/config/dria.conf"

function get_arg() {
       PRIV_KEY=""
       OPENAI_API_KEY=""
       GEMINI_API_KEY=""
       SERPER_API_KEY=""
       JINA_API_KEY=""
       DKN_MODELS=""
	   
	   shift
       for arg in "$@"; do
           case $arg in
 	       --PRIV_KEY=*)
                   PRIV_KEY="${arg#*=}"
                   ;;
               --OPENAI_API_KEY=*)
                   OPENAI_API_KEY="${arg#*=}"
                   ;;
               --GEMINI_API_KEY=*)
                   GEMINI_API_KEY="${arg#*=}"
                   ;;
               --SERPER_API_KEY=*)
                   SERPER_API_KEY="${arg#*=}"
                   ;;
               --JINA_API_KEY=*)
                   JINA_API_KEY="${arg#*=}"
                   ;;
	       --DKN_MODELS=*)
                   DKN_MODELS="${arg#*=}"
                   ;;
               *)
                   echo "Unknown parameter: $arg"
                   exit 1
                   ;;
           esac
      done

}

#加载变量文件，或接收传参
function check_arg_env() {
if [ -f "$DRIACONF" ]; then
    source "$DRIACONF"
else
    get_arg "$@" 
fi

echo "PRIV_KEY: $PRIV_KEY"
echo "OPENAI_API_KEY: $OPENAI_API_KEY"
echo "GEMINI_API_KEY: $GEMINI_API_KEY"
echo "SERPER_API_KEY: $SERPER_API_KEY"
echo "JINA_API_KEY: $JINA_API_KEY"
echo "DKN_MODELS: $DKN_MODELS"


if [[ ! -n "$PRIV_KEY" || ! -n "$DKN_MODELS" || ! -n "$JINA_API_KEY" || ! -n "$SERPER_API_KEY" ]]; then
    echo "Lack of private key and training model name" &&
    exit 1
fi

if [[ ! -f docker-compose.yml || ! -f Dockerfile || ! -f env.source ]];then 
	echo "Lack docker file" &&
	exit 1
fi
}

#生成节点配置文件
function gen_dria_env() {

    #mod .env file
	[ ! -f env ] && cp env.source env
	
    DKN_PRI_KEY=$(echo "$PRIV_KEY" | sed 's/^0x//')
    sed -i "s/DKN_WALLET_SECRET_KEY=/DKN_WALLET_SECRET_KEY=$DKN_PRI_KEY/" env

    if [[ -n "$OPENAI_API_KEY" ]]; then
        sed -i "s/OPENAI_API_KEY=/OPENAI_API_KEY=$OPENAI_API_KEY/" env
    fi

    if [[ -n "$GEMINI_API_KEY" ]]; then
        sed -i "s/GEMINI_API_KEY=/GEMINI_API_KEY=$GEMINI_API_KEY/" env
    fi

    sed -i "s/SERPER_API_KEY=/SERPER_API_KEY=$SERPER_API_KEY/" env
    sed -i "s/JINA_API_KEY=/JINA_API_KEY=$JINA_API_KEY/" env

    sed -i "s#DKN_BOOTSTRAP_NODES=#DKN_BOOTSTRAP_NODES=/ip4/44.206.245.139/tcp/4001/p2p/16Uiu2HAm4q3LZU2TeeejKK4fff6KZdddq8Kcccyae4bbbF7uqaaa#" env
    sed -i "s/DKN_MODELS=/DKN_MODELS=$DKN_MODELS/" env
	
	mkdir -p dria_conf && cp env dria_conf
}

#安装配置节点
function install_node() {
	
	check_arg_env "$@"  
	gen_dria_env "$@"
	
	if [ -f dria_conf/env ];then
		echo "dkn compute lanuch evn file is OK"
	else
		echo "no dkn compute lanuch evn file"
		exit 1
	fi
	
	docker-compose build
	if ! docker image list |grep dria-dkn-compute;then
		echo "dria image create failed" &&
		exit 1
	fi
	
	docker-compose up -d
	sleep 10
	status=$(docker inspect -f '{{.State.Status}}' "dkn-compute-container")
        case "$status" in
             running) echo "Container dkn-compute-container is running." && exit 0;;
		   *) echo "dkn-compute-container start failed" && exit 1 ;;
        esac
}

# 查看节点日志
function check_node_log() {
    docker logs dkn-compute-container --tail=200
}

function remove_node() {
	docker kill dkn-compute-container
	docker rm dkn-compute-container
	docker image rm dria-dkn-compute
	rm -rf env 
	rm -rf dria_conf
	echo "dria node remove success" &&
	exit 0
}


function main_menu() {
    clear
    echo "========================= Dria ai 节点安装 ======================================="
    echo "脚本必要参数：PRIV_KEY        eth钱包私钥作为 DKN_WALLET 密文"    
    echo "脚本必要参数：DKN_MODELS      训练模型名称作为启动参数"				        
    echo "脚本必要参数：SERPER_API_KEY  用于节点高效运行"			
    echo "脚本必要参数: JINA_API_KEY    用于节点高效运行"		
    echo "脚本可选参数：OPENAI_API_KEY  可运行基于openai和gemini的模型"
    echo "脚本可选参数：GEMINI_API_KEY  可运行基于openai和gemini的模型"
    echo ""
    echo "======================= Supported model names ===================================="
    echo "NousTheta	Mode_Name: finalend/hermes-3-llama-3.1:8b-q8_0"
    echo "Phi3Medium	Mode_Name: phi3:14b-medium-4k-instruct-q4_1"
    echo "Phi3_5Mini	Mode_Name: phi3.5:3.8b"
    echo "Llama3_1_8B	Mode_Name: llama3.1:latest"
    echo "Phi3Medium128k	Mode_Name: phi3:14b-medium-128k-instruct-q4_1"
    echo ""
}


case $1 in 
  	install)
	   main_menu
	   install_node "$@"
	   ;;
        remove)
	   remove_node
	   ;;
        log)
       	   check_node_log
	   ;;
    	  *) 
	   echo "参数error"
	   ;;
esac
