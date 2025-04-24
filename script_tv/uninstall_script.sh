#!/bin/bash

if id "stv" &>/dev/null; then
    echo "开始卸载..."
else
    echo "服务器未安装 script 或未成功安装 script。"
    exit 1
fi

nohup bash /usr/local/bin/script_tv__uninstall.sh > uninstall_script.log 2>&1 &
pid=$!
wait $pid
echo "卸载脚本执行完成！！！！！！"

sleep 5
sudo pkill -u stv
sudo deluser --remove-home stv
if id "stv" &>/dev/null; then
    echo "未成功删除stv账户"
else
    echo "卸载完成！！"
fi
