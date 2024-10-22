# HEMI Network CLI PoP Miner 部署指南

Hemi 网络是模块化二层协议，由比特币和以太坊支持，具备扩展性、安全性和互操作性。它不将这两者视为孤岛，核心是 hVM 整合比特币节点于以太坊虚拟机。结合 hBK，为开发者提供强大的平台创建 hApps，开启可编程性的新水平。

## 前置条件

- Ubuntu 或 macOS 或 windows 设备
- 推特账号拥有 10 个追随者

## 配置条件如下

| 硬件  | 要求   |
|-------|--------|
| CPU   | 1 核   |
| 内存  | 1 GB   |
| 磁盘  | 50 GB  |

## HEMI CLI PoP Miner 参考教程步骤

### 一、服务器准备

1. **安装 git、make、Go v1.23+、Docker、pm2（若已安装，则跳过）**  
   检查包管理器，确保更新到最新：
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   安装 git 和 make：
   ```bash
   sudo apt install git make -y
   ```

   **安装 Go v1.23+**：
   ```bash
   wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
   ```
   ```bash
   export PATH=$PATH:/usr/local/go/bin
   ```
   ```bash
   go version
   ```

   **安装 Docker**  
   若安装出现问题，请访问 [Docker 官网](https://docs.docker.com/engine/install/)：
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```

   **安装 pm2**：
   ```bash
   sudo apt-get install -y npm
   ```
   ```bash
   npm install pm2@latest -g
   ```

### 二、构建二进制文件

1. 克隆 heminetwork 存储库：
   ```bash
   git clone https://github.com/hemilabs/heminetwork.git
   ```
   ```bash
   cd heminetwork
   ```

2. 设置并构建二进制文件：
   ```bash
   make deps
   ```
   ```bash
   make install
   ```
   返回结果如下：  
   ![image](https://github.com/user-attachments/assets/54c87c3b-8212-4db3-95b2-5c531dbd5346)

### 三、运行 localnet 网络及检查安装情况

1. 启动网络：
   ```bash
   docker compose -f ./e2e/docker-compose.yml up --build
   ```

2. 检查安装情况：
   ```bash
   ./popmd --help
   ```
   正常安装完成，返回如下：  
   ![image](https://github.com/user-attachments/assets/ba587dbe-dcdb-405a-8505-42c162232b08)

### 四、生成密钥

1. **生成公钥**：
   ```bash
   ./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json
   ```

2. **导出密钥**：
   ```bash
   cat ~/popm-address.json
   ```
   **记得保存密钥**  
  ![image](https://github.com/user-attachments/assets/a1cc71f7-bae2-4d55-85c7-0c14ce253d75)

你需要加入 Hemi 的 Discord，连接推特后加入 faucet-commands 频道使用生成的哈希领取水，加入 [hemiDC](https://discord.gg/hemixyz)。  

   ![image](https://github.com/user-attachments/assets/5d2e4226-b13c-4d1a-88a2-2a94c2e2d8dd)  
   ![image](https://github.com/user-attachments/assets/9a63abe5-29e2-4b2d-9299-ee9dc4412984)  
   ![image](https://github.com/user-attachments/assets/55cd4869-35b7-4b55-8ec9-bb0f5e583f1f)  
   ![image](https://github.com/user-attachments/assets/a630304e-d4f1-4843-8307-b5038ce02259)  
   ![image](https://github.com/user-attachments/assets/63566486-8207-41d7-a7cc-91d22ebaad0c)  
   ![image](https://github.com/user-attachments/assets/3998b4da-2612-465f-b6e4-2c52787aa14b)  
   ![image](https://github.com/user-attachments/assets/6b7695bc-e3d1-489d-9e8a-a0835eb263fb)  
   ![image](https://github.com/user-attachments/assets/9e17dc0d-b01a-43cb-9dca-a0c738255599)  
   ![image](https://github.com/user-attachments/assets/3fc01e74-e434-4a79-a1e1-3a4691d55022)  
   ![image](https://github.com/user-attachments/assets/83a8ab99-ac8a-491d-a081-8d84b19c61cb)

### 五、运行矿机

1. **配置设置**  
   在 “POPM_BTC_PRIVKEY=” 后面填写你的私钥或生成的私钥：
   ```bash
   export POPM_BTC_PRIVKEY=
   ```
   在 “POPM_STATIC_FEE=” 后输入你想支付的 sat/vB 费用（官方建议设置为 50）：
   ```bash
   export POPM_STATIC_FEE=
   ```
   ```bash
   set POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public
   ```
   启动挖矿并放入后台运行，你也可以安装其他工具进行启动：
   ```bash
   pm2 start popmd
   ```

### 六、监控挖矿状态

1. 检查挖矿状态  
   查看日志信息：
   ```bash
   pm2 logs popmd
   ```
   部署好之后，可能不会立刻挖到区块，等待半天再查看挖矿情况。  
   ![16533cd243f3e59d38f18629772b93e](https://github.com/user-attachments/assets/b46d579c-901d-4ba3-af7a-554d015f4990)

2. 仪表盘监控挖矿状态及 tBTC 消耗状态  
   在仪表盘右上角输入返回的哈希值 (**pubkey_hash**) 就能看到挖矿状态，请访问 [仪表盘](https://mempool.space/testnet)。  
   可以结合日志查看项目是否正常运行  
   余额查看（**注：请将余额保持在 0.1 以上**）  
   ![image](https://github.com/user-attachments/assets/9ff6eef8-77a9-48b5-922b-1076f26bec2f)  
   ![image](https://github.com/user-attachments/assets/3c773005-27c3-4c71-a84c-8edb99ebfe18)  

输入公钥（**public_key**）查看运行情况，请访问 [仪表盘](https://testnet.popstats.hemi.network/)  
![image](https://github.com/user-attachments/assets/a108a13d-329c-4236-8bcb-9da2528adfeb)  
