#!/bin/bash

# 从环境变量读取参数，如果没有则使用默认值
EXECUTION_RPC="${EXECUTION_RPC:-http://localhost:8545}"
BEACON_RPC="${BEACON_RPC:-http://localhost:5052}"

# 检查Sepolia执行层RPC同步状态
check_execution_sync() {
    local rpc_url="$1"
    local result=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
        "$rpc_url" 2>/dev/null)
    
    if [[ $? -ne 0 ]] || [[ -z "$result" ]]; then
        return 2  # RPC连接失败
    fi
    
    local sync_status=$(echo "$result" | grep -o '"result":[^,}]*' | cut -d':' -f2)
    if [[ "$sync_status" == "false" ]]; then
        return 0  # 同步完成
    else
        return 1  # 正在同步
    fi
}

# 检查Sepolia信标链RPC同步状态
check_beacon_sync() {
    local beacon_url="$1"
    local result=$(curl -s "$beacon_url/eth/v1/node/syncing" 2>/dev/null)
    
    if [[ $? -ne 0 ]] || [[ -z "$result" ]]; then
        return 2  # RPC连接失败
    fi
    
    local is_syncing=$(echo "$result" | grep -o '"is_syncing":[^,}]*' | cut -d':' -f2)
    if [[ "$is_syncing" == "false" ]]; then
        return 0  # 同步完成
    else
        return 1  # 正在同步
    fi
}

# 主函数
main() {
    local execution_rpc="${1:-$EXECUTION_RPC}"
    local beacon_rpc="${2:-$BEACON_RPC}"
    
    # 检查执行层同步状态
    check_execution_sync "$execution_rpc"
    local exec_status=$?
    
    # 检查信标链同步状态
    check_beacon_sync "$beacon_rpc"
    local beacon_status=$?
    
    # 判断整体状态
    if [[ $exec_status -eq 2 ]] || [[ $beacon_status -eq 2 ]]; then
        echo "RPC部署异常"
    elif [[ $exec_status -eq 0 ]] && [[ $beacon_status -eq 0 ]]; then
        echo "RPC部署正常，执行层RPC: $execution_rpc，信标链RPC: $beacon_rpc"
    else
        echo "请耐心等待，节点正在同步中....."
    fi
}

# 运行主函数
main "$@"
