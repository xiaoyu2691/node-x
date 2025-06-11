#!/bin/bash

commands=("sleep" "grep" "tail" "pgrep" "wget" "cat" "curl" "source" "chmod" "gawk" "sysstat")

# 检查并安装命令
for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "\e[33m$cmd 未安装，正在尝试安装...\e[0m"
        sudo apt update
        sudo apt install -y "$cmd"
    fi
done

# 设置默认值
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
            echo -e "\e[31m未知参数: $1\e[0m"
            exit 1
            ;;
    esac
done

# 打印系统资源检查报告
echo -e "\n\e[34m======系统资源检查报告 $(date)======\e[0m"

# 显示CPU利用率及数量
echo -e "\n\e[36m===CPU利用率===\e[0m"
cpu_info=$(mpstat 1 1 | grep "Average" | awk '{printf "CPU利用率: %.2f%%", 100 - $12}')
cpu_count=$(nproc)
idle_cpus=$(mpstat 1 1 | grep "Average" | awk '{print $12}')
idle_cpus_count=$(echo "$idle_cpus * $cpu_count / 100" | bc)
echo -e "\e[37m${cpu_info}, CPU数量: $cpu_count, 空闲CPU数量: $idle_cpus_count\e[0m"
# 检查空闲CPU数量
if [ "$idle_cpus_count" -lt "$cpu_threshold" ]; then
    if [ "$idle_cpus_count" -eq 0 ]; then
        echo -e "\e[31m警告：CPU资源已经占用完全，没有空闲资源，目前资源为 $cpu_threshold\e[0m"
        exit 1
    else
        echo -e "\e[31m警告：空闲CPU数量不足，节点可能安装失败，请注意系统资源分配！\e[0m"
    fi
else
    echo "当前空闲CPU:$idle_cpus_count"
fi

# 显示内存使用情况
echo -e "\n\e[36m===内存使用情况===\e[0m"
memory_info=$(free -h | awk 'NR==2 {print "已使用: "$3", 空闲: "$7}')
echo -e "\e[37m$memory_info\e[0m"
free_ram=$(free | awk 'NR==2 {print $7}') # 获取空闲内存大小（单位为KiB）
free_ram_gb=$(echo "scale=2; $free_ram / 1024 / 1024" | bc) # 转换为GB
# 检查空闲内存是否小于阈值
if [ "$(echo "$free_ram_gb < $ram_threshold" | bc)" -eq 1 ]; then
    if [ "$(echo "$free_ram_gb == 0" | bc)" -eq 1 ]; then
        echo -e "\e[31m警告：内存资源已经占用完全，没有空闲资源，目前资源为 $ram_threshold GB\e[0m"
        exit 1
    else
        echo -e "\e[31m警告：空闲RAM不足，节点可能会部署失败，请注意资源分配！\e[0m"
    fi
fi

# 显示磁盘使用情况
# 显示磁盘使用情况
echo -e "\n\e[36m===磁盘使用情况===\e[0m"
disk_info=$(df -h / | awk 'NR==2 {print "已使用: "$3", 空闲: "$4}')
echo -e "\e[37m$disk_info\e[0m"
free_rom=$(df / | awk 'NR==2 {print $4}' | sed 's/G//') # 获取空闲磁盘大小（单位为G）
free_rom_kb=$(df / | awk 'NR==2 {print $4}') # 获取空闲磁盘大小（单位为KiB）
free_rom_gb=$(echo "scale=2; $free_rom_kb / 1024 / 1024" | bc) # 转换为GB

# 检查空余磁盘是否小于阈值
if [ "$(echo "$free_rom_gb < $rom_threshold" | bc)" -eq 1 ]; then
    if [ "$(echo "$free_rom_gb == 0" | bc)" -eq 1 ]; then
        echo -e "\e[31m警告：磁盘空间已经占用完全，没有空闲资源，目前资源为 $rom_threshold G\e[0m"
    else
        echo -e "\e[31m警告：服务器磁盘空间不足，部署该节点最低磁盘为 $rom_threshold G\e[0m"
    fi
    exit 1
fi

