# Unichain 节点安装指南  

Unichain 是一个高效、低成本的以太坊 L2 解决方案，专注 DeFi 和多链流动性。其 1 秒出块时间将进一步缩短至 250 毫秒，提高市场效率并减少 MEV 损失。通过将执行移至 L2，Unichain 使交易成本降低约 95%，并支持多链无缝交易与流动性接入，实现跨链互操作性和更高去中心化。  

## 前置条件  
一个可用的RPC  
一个可用的Beacon  
## 运行配置条件如下：  
|  硬件   |  要求   |
|:----:|:----:|
|   CPU  |  2核   |
|   内存  |  4GB   |
|   磁盘  |  50GB   |


# 以下是Unichain节点部署步骤（以ubuntu服务器部署为例）：  
## 一、部署前准备   
**获取RPC**  
推荐一：使用public node,请访问[public node](https://ethereum-holesky-rpc.publicnode.com/?sepolia)  
推荐二：使用infura获取rpc，请访问[INFURA](https://www.infura.io/zh)    
![image](https://github.com/user-attachments/assets/88303fcc-a626-4d6b-a76f-1a243889274d)  
![image](https://github.com/user-attachments/assets/c1865b85-9e14-4e39-bbc6-387cadde3311)  
![image](https://github.com/user-attachments/assets/2db0c581-d422-4952-8a77-2cf1d9fc7cbb)  
![image](https://github.com/user-attachments/assets/30bc5d0a-0ece-4875-b7a0-829f89467f76)  
![image](https://github.com/user-attachments/assets/8fa35b01-4777-47ea-b363-74ef1d60bf33)  
![image](https://github.com/user-attachments/assets/b1176f4d-605d-43a8-9dea-7a13cca8f426)  
![image](https://github.com/user-attachments/assets/875b5b22-fe1d-4609-98a5-6a358231d473)  
![image](https://github.com/user-attachments/assets/a369b315-f957-4cf2-8d76-6971840b44cf)  
![image](https://github.com/user-attachments/assets/5fc7e0a6-06d9-445e-b909-22b237de3b6e)  
![image](https://github.com/user-attachments/assets/805e2ef6-3fc5-4e7d-892b-3e8bfbcb53a5)  
![image](https://github.com/user-attachments/assets/df584a5f-fce3-4a24-bd23-2ca8948a7077)  
**获取Beacon**  
使用public node获取，请访问[public node](https://ethereum-holesky-rpc.publicnode.com/?sepolia)  
![image](https://github.com/user-attachments/assets/b648220b-38ba-446d-8f61-029845d5e1a8)   

## 二、服务器准备  
### 1、安装docker  
   若安装出现问题，请访问 [Docker 官网](https://docs.docker.com/engine/install/)：
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```
## 三、安装节点  
### 1、克隆存储库  
```bash
git clone https://github.com/Uniswap/unichain-node.git
```
### 2、配置RPC以及Beacon 
```bash
cd unichain-nade
```
```bash
vim .env.sepolia
```
将你获取的RPC和Beacon替换“OP_NODE_L1_ETH_RPC=”后面的值以及“OP_NODE_L1_BEACON=”后面的值  
![image](https://github.com/user-attachments/assets/fe2ed6e1-090b-42ba-977a-f725973b7168)  
![6a2d5c95e75fc58c3f94674963d8c03](https://github.com/user-attachments/assets/ed1e538c-1b5e-48af-af7b-7bf65c898359)  
![9010a74ec157143c9cfab4390dc7988](https://github.com/user-attachments/assets/e96f69ed-7344-422e-ac95-1f9ee219150c)  

### 3、运行节点  
```bash
docker compose up -d
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/1bc71188-ffd2-4290-8f62-28eac586c30f)  

***Unichain测试网节点安装完成了！！！***  

### 4、检查节点运行状态  
```bash
curl -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
  -H "Content-Type: application/json" http://localhost:8545
```
![image](https://github.com/user-attachments/assets/10a6b451-09c3-46a2-bc20-0c904e3f95c9)  

### 5、停止节点运行  
```bash
docker compose down
```
### 6、升级节点  
```bash
docker compose down
```
```bash
git pull
```
```bash
docker compose up -d
```


