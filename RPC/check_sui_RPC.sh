#!/bin/bash

# 测试 Sui RPC 可用性（作为健康检查指令）
test_sui_rpc_health() {
    local rpc_url="$1"
    
    # 如果没有提供 RPC URL，使用默认值
    if [ -z "$rpc_url" ]; then
        rpc_url="http://localhost:9000"  # 默认使用本地测试网地址，可按需修改
    fi
    
    # 发送简单的 RPC 请求检查服务是否正常响应
    health_response=$(curl -s -X POST "$rpc_url" \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc": "2.0",
            "id": 1,
            "method": "sui_getLatestCheckpointSequenceNumber",
            "params": []
        }' --max-time 5)
    
    # 检查是否收到有效响应（包含result字段且不包含error字段）
    if echo "$health_response" | grep -q '"result"' && ! echo "$health_response" | grep -q '"error"'; then
        echo "true"
        echo "RPC服务正常运行"
        return 0
    else
        echo "false"
        echo "RPC服务无法访问或响应异常"
        return 1
    fi
}

# 执行健康检查
test_sui_rpc_health "$1"
