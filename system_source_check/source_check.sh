#!/bin/bash

commands=("sleep" "grep" "tail" "pgrep" "wget" "cat" "curl" "source" "chmod" "gawk" "sysstat")

# 检查并安装命令
for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd 未安装，正在尝试安装..."
        sudo apt update
        sudo apt install -y "$cmd"
    else
        echo "$cmd 已安装。"
    fi
done

# 设置默认值
# 默认值
cpu_threshold=0
ram_threshold=0
rom_threshold=0

# 处理参数
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --cpu) 
            cpu_threshold="$2"
            shift 2
            ;;
        --ram) 
            ram_threshold="$2"
            shift 2
            ;;
        --rom) 
            rom_threshold="$2"
            shift 2
            ;;
        *) 
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

# 打印系统资源检查报告
echo "======系统资源检查报告 $(date)======"

# 显示内存使用情况
echo -e "\n===内存使用情况==="
memory_info=$(free -h | awk 'NR==2 {print "已使用: "$3", 空闲: "$7}')
echo "$memory_info"
free_ram=$(free | awk 'NR==2 {print $7}') # 获取空闲内存大小

# 显示磁盘使用情况
echo -e "\n===磁盘使用情况==="
disk_info=$(df -h / | awk 'NR==2 {print "已使用: "$3", 空闲: "$4}')
echo "$disk_info"
free_rom=$(df / | awk 'NR==2 {print $4}' | sed 's/G//') # 获取空闲磁盘大小（单位为G）

# 检查空余磁盘是否为0
if [ "$free_rom" -le 0 ]; then
    echo "警告：磁盘空间不足，脚本退出"
    exit 1
fi

# 显示CPU利用率及数量
echo -e "\n===CPU利用率==="
cpu_info=$(mpstat 1 1 | grep "Average" | awk '{printf "CPU利用率: %.2f%%", 100 - $12}')
cpu_count=$(nproc)
idle_cpus=$(mpstat 1 1 | grep "Average" | awk '{print $12}')
idle_cpus_count=$(echo "$idle_cpus * $cpu_count / 100" | bc)
echo "${cpu_info}, CPU数量: $cpu_count, 空闲CPU数量: $idle_cpus_count"

# 判断资源是否满足要求
if [ "$idle_cpus_count" -lt "$cpu_threshold" ]; then
    echo "警告：空闲CPU数量不足"
fi

if [ "$free_ram" -lt "$ram_threshold" ]; then
    echo "警告：空闲RAM不足"
fi

if [ "$free_rom" -lt "$rom_threshold" ]; then
    echo "警告：空闲ROM不足"
fi
