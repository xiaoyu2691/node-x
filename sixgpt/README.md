# SIXGPT Miner搭建指南  

SIXGPT 是一个基于区块链的去中心化项目，旨在通过智能合约和人工智能技术实现数据处理和价值传递的自动化。其矿工节点（SIXGPT Miner）用于验证交易、生成区块，并为网络提供计算力。用户通过运行矿工节点，能参与网络治理、维护区块链安全，并获得相应的奖励。SIXGPT 还支持去中心化应用（dApps）的开发，促进了无中介的智能服务和分布式经济的建设。  

## 本指南将逐步引导你完成SIXGPT Miner的搭建。

### 服务器实测要求

| 资源         | 规格                             |
|--------------|----------------------------------|
| CPU          | ≥ 4                              |
| 内存         | ≥ 4 GB                           |

## SIXGPT Miner的搭建步骤：

### 1. 服务器准备

1. **安装 Docker（已安装则跳过）**  
检查是否安装 Docker：  
```bash
docker -v
```
安装 Docker：  
```bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
```bash
sudo apt update -y
```
```bash
sudo apt install -y docker-ce
```
启动 Docker 服务：  
```bash
sudo systemctl start docker
```
```bash
sudo systemctl enable docker
```

### 2. 安装并启动 SIXGPT Miner

1. 克隆存储库：  
```bash
git clone https://github.com/sixgpt/miner.git
```
2. 设置环境变量  
切换到 miner 文件夹下：  
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

**SIXGPT 安装已完成！**  

### 查看 SIXGPT Miner 状况

1. 查看 Miner 日志：  
```bash
docker logs miner-ollama-1
```
这是没有 $VANA 的账户状态：  
![image](https://github.com/user-attachments/assets/c4e58c82-3848-4207-8cfc-c188b55fdebf)  
正常运行结果如下：  
![31e33b761f2702676c4ab002070d1e1](https://github.com/user-attachments/assets/7f7c2bee-22f0-40ae-96fa-0636ce3a41ed)  

