#!/bin/bash

# 定义以 stv 用户执行命令的函数（修复参数传递）
run_as_stv() {
    # 使用数组传递参数，确保参数完整性
    local cmd_args=("$@")
    sudo -u stv /bin/bash -i -c "cd \$HOME && $(printf "%q " "${cmd_args[@]}")"
}

# 执行 stv redeem 并捕获输出
echo "正在执行节点检查..."
# 获取 stv 用户所有进程 PID
PIDS=$(pgrep -u stv)
if [ -n “$pid” ]; then
echo "钱包信息："
run_as_stv stv -a status
else
echo "script is not running"
fi
