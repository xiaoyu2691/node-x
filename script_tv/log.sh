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

# 初始化监控指标
TOTAL_CPU=0
TOTAL_RSS=0  # 内存占用（单位：KB）

# 获取 CPU 核心数
CPU_CORES=$(nproc)

# 遍历每个 PID 获取资源使用
for PID in $PIDS; do
  # 获取 CPU 使用率（百分比）和内存占用（KB）
  CPU_USAGE=$(ps -p $PID -o %cpu --no-headers | awk '{print $1}')
  RSS_KB=$(ps -p $PID -o rss --no-headers | awk '{print $1}')

  # 累加统计值
  TOTAL_CPU=$(echo "$TOTAL_CPU + $CPU_USAGE" | bc)
  TOTAL_RSS=$(echo "$TOTAL_RSS + $RSS_KB" | bc)
done

# 计算相对于单个 CPU 的占用率（最高为 100%）
RELATIVE_CPU=$(echo "scale=2; $TOTAL_CPU / $CPU_CORES" | bc)
# 如果超过 100%，则限制为 100%
if (( $(echo "$RELATIVE_CPU > 100" | bc -l) )); then
  RELATIVE_CPU=100.00
fi

# 获取系统总内存（KB）
TOTAL_SYS_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
# 将系统总内存从 KB 转换为 GB
TOTAL_SYS_MEM_GB=$(echo "scale=2; ${TOTAL_SYS_MEM_KB:-0} / 1024 / 1024" | bc)

# 将内存从 KB 转换为 GB（保留两位小数）
TOTAL_MEM_GB=$(echo "scale=2; ${TOTAL_RSS:-0} / 1048576" | bc)

# 计算内存占比（百分比，保留两位小数）
MEM_PERCENT=$(echo "scale=2; ${TOTAL_RSS:-0} * 100 / ${TOTAL_SYS_MEM_KB:-1}" | bc)

# 生成监控报告
MONITOR_REPORT=$(cat <<EOF
================ stv 进程资源监控 ================
[CPU] 总占用率: ${RELATIVE_CPU:-0}% (相对于单个 CPU，最高 100%)
[CPU] 原始占用率: ${TOTAL_CPU:-0}% (所有核心总和)
[CPU] 系统核心数: ${CPU_CORES}
[MEM] 总内存占用: ${TOTAL_MEM_GB:-0} GB
[MEM] 系统总内存: ${TOTAL_SYS_MEM_GB:-0} GB
[MEM] 内存占比: ${MEM_PERCENT:-0}%
=================================================
EOF
)

# 输出监控报告
echo "$MONITOR_REPORT"
redeem_output=$(run_as_stv stv redeem 2>&1)
exit_code=$?

# 调试信息（可选）
#echo "----- 调试信息 -----"
#echo "命令退出码: $exit_code"
#echo "原始输出:"
#echo "$redeem_output"
#echo "-------------------"

# 根据输出处理逻辑
if echo "$redeem_output" | grep -q "Node address has already been awarded"; then
    echo "✅ 节点已绑定，正在获取状态..."
    echo "========================================"
    echo "[网络状态]"
    run_as_stv stv -a status
    echo "----------------------------------------"
    echo "[节点状态]"
    run_as_stv stv node_status -a
    run_as_stv stv stv keysp

elif echo "$redeem_output" | grep -q "https://redeem-mainnet.script.tv/?ssid="; then
    echo "🔗 未绑定节点，请操作："
    echo "$redeem_output"
    echo "========================================"
    echo "操作指引："
    echo "1. 打开上方链接 > 使用授权钱包登录"
    echo "2. 完成绑定后等待 1 分钟"
    echo "3. 重新运行本脚本检查状态"

else
    echo "❌ 严重错误，请检查以下问题：" >&2
    echo "$redeem_output" >&2
    echo "========================================" >&2
    cat ~/stv_install.log | grep -E 'Warning|E'
    echo "常见问题排查：" >&2
    echo "1. 确认 stv 用户已正确安装 CLI 工具"
    echo "2. 检查网络连接是否正常"
    echo "3. 手动验证命令是否可执行："
    echo "   sudo -u stv stv redeem"
    exit 1
fi
