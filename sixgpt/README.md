# SIXGPT Miner搭建指南

SIXGPT 是一个基于区块链的去中心化项目，旨在通过智能合约和人工智能技术实现数据处理和价值传递的自动化。其矿工节点（SIXGPT Miner）用于验证交易、生成区块，并为网络提供计算力。用户通过运行矿工节点，能参与网络治理、维护区块链安全，并获得相应的奖励。SIXGPT 还支持去中心化应用（dApps）的开发，促进无中介的智能服务和分布式经济的建设。

## 本指南将逐步引导你完成 SIXGPT Miner 的搭建

### 服务器实测要求

| 资源   | 规格   |
|--------|--------|
| CPU    | ≥ 4    |
| 内存   | ≥ 4 GB  |

## SIXGPT Miner 的搭建步骤：

### 1. 服务器准备

1. **安装 Docker（已安装则跳过）**  
   若不知道服务器情况，则检查是否安装 Docker：  
   ```bash
   docker -v
   ```
   已安装则返回：  
   ![image](https://github.com/user-attachments/assets/d6c7aa3d-a5dc-4549-8241-5b39d1d93636)

   安装 Docker，若安装出现问题请访问 [Docker 官网](https://docs.docker.com/engine/install/)：  
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```

### 2. 安装并启动 SIXGPT Miner

1. 克隆存储库：  
   ```bash
   git clone https://github.com/sixgpt/miner.git
   ```
2. 设置环境变量  
   切换到 `miner` 文件夹下：  
   ```bash
   cd miner
   ```
   在 `VANA_PRIVATE_KEY=` 后填入有 $VANA 的账户私钥：  
   ```bash
   export VANA_PRIVATE_KEY=
   ```
   设置网络为 Satori：  
   ```bash
   export VANA_NETWORK=satori
   ```
   启动矿工：  
   ```bash
   docker compose up -d
   ```
   返回结果如下：  
   ![image](https://github.com/user-attachments/assets/66ccdcfc-b709-456a-8774-9ab3ccfdebd4)

**SIXGPT Miner 安装已完成！**

### 查看 SIXGPT Miner 状况

1. 查看 Miner 日志：  
   ```bash
   docker compose logs miner
   ```
   这是没有 $VANA 的账户状态：  
   ![image](https://github.com/user-attachments/assets/3797e0e9-341f-4201-b1df-bfa4d931962a)

   正常运行结果如下：  
   ![image](https://github.com/user-attachments/assets/7f7c2bee-22f0-40ae-96fa-0636ce3a41ed)
