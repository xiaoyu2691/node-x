# Story Protocol验证者节点搭建指南

本指南将逐步引导你完成 Story 节点的搭建过程。你将学习如何：
- 安装并配置 Story 节点
- 部署并监控 Story 节点

## 前置条件
- Ubuntu 系统原生设备 / Ubuntu 虚拟机设备 / Mac 设备
- 一个 ETH 钱包地址

## 推荐运行配置如下：

| 硬件         | 要求       |
|--------------|------------|
| 中央处理器   | 4 核       |
| 内存         | 8 GB       |
| 磁盘         | 200 GB     |
| 带宽         | 10 兆比特/秒 |

以下是 Story 节点参考教程步骤：

## 服务器准备

### 1. 安装依赖以及必要工具

检查依赖库，并更新依赖：
```bash
apt update && apt upgrade -y
```
快速安装常用软件工具：
```bash
apt install curl wget jq make gcc nano -y
```
安装 Node.js 以及 npm，如已安装则跳过：
```bash
sudo apt install nodejs npm
```
安装 pm2，如已安装则跳过：
```bash
npm install pm2@latest -g
```

## 安装 Story 节点

### 1. 下载并解压客户端安装包
下载最新的执行客户端安装包，请访问 [最新版本](https://github.com/piplabs/story-geth/releases)：
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
```
下载 v0.9 的最新版本，共识客户端需要逐步更新版本，请访问 [最新版本](https://github.com/piplabs/story/releases)：
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.13-b4c7db1.tar.gz
```
解压已下载的安装包：
```bash
tar -xzf geth-linux-amd64-0.9.3-b224fdf.tar.gz
tar -xzf story-linux-amd64-0.9.13-b4c7db1.tar.gz
```

### 2. 设置默认数据文件夹及其客户端设置
设置默认数据文件夹：
```bash
export STORY_DATA_ROOT="~/.story/story"
export GETH_DATA_ROOT="~/.story/geth"
```
如果你是在 macOS 系统中部署，则需要去除下载文件的隔离属性，如果不是则跳过：
```bash
sudo xattr -rd com.apple.quarantine ./geth
sudo xattr -rd com.apple.quarantine ./story
```

### 3. 初始化客户端并运行
将 `/root/geth-linux-amd64-0.9.3-b224fdf/geth` 文件复制到本地的二进制文件夹下，并使用 pm2 运行并将进程命名为 story-geth，并设置同步：
```bash
cp /root/geth-linux-amd64-0.9.3-b224fdf/geth /usr/local/bin
pm2 start /usr/local/bin/geth --name story-geth -- --iliad --syncmode full
```
初始化共识客户端，使用 pm2 运行并将进程命名为 story-client，到这里节点就安装完成了：
```bash
cp /root/story-linux-amd64-0.9.13-b4c7db1/story /usr/local/bin
cd /usr/local/bin
./story init --network iliad
pm2 start /usr/local/bin/story --name story-client -- run
```
安装完成后返回  
![999d7d9b08e5688d956f3f1cc0eedcc](https://github.com/user-attachments/assets/644fb51a-1683-4d57-865c-d55b5cae5a41)  

## 检查节点状况
查看客户端的日志信息，检查节点状况：
```bash
pm2 logs story-geth
pm2 logs story-client
```
清除节点状态并重新启动节点：
```bash
pm2 stop story-geth && rm -rf ${GETH_DATA_ROOT} && pm2 start /usr/local/bin/geth --name story-geth -- --iliad --syncmode full
pm2 stop story-client && rm -rf ${STORY_DATA_ROOT} && /usr/local/bin/story init --network iliad && pm2 start /usr/local/bin/story --name story-client -- run
```

## 设置验证者

### 1. 检查 .env 文件
检查 .env 文件是否存在，如果存在则会显示出来：
```bash
ls .env | grep ".env"
```
若没有 .env 文件，则创建一个 .env 文件：
```bash
vim .env
```
请确认账户以获得 IP：
```bash
# ~/story/.env" > .env
PRIVATE_KEY=按 i 键输入你的私钥，然后按 Esc 键输入 “：wq” 保存并退出
```

### 2. 创建验证器以及质押操作
导出验证器密钥：
```bash
cd /usr/local/bin
./story validator export
```
创建验证器：
```bash
./story validator create --stake 输入你要质押的 IP 数并乘 1000000000000000000
```
若你想继续质押，则输入你的验证器公钥以及你要质押的 IP 数并乘 1000000000000000000；若你要帮他人质押，则输入他的验证器公钥以及他想要质押的 IP 数并乘 1000000000000000000：
```bash
./story validator stake --validator-pubkey 输入验证器公钥 --stake 输入你要质押的 IP 数并乘 1000000000000000000
```
若你想取消质押，则输入你的验证器公钥以及你要取消质押的 IP 数并乘 1000000000000000000；若你要帮他人取消质押，则输入他的验证器公钥以及他想要取消质押的 IP 数并乘 1000000000000000000：
```bash
./story validator unstake --validator-pubkey 输入验证器公钥 --unstake 输入你要取消质押的 IP 数并乘 1000000000000000000
```
如果你想更换提取奖励的地址，则进行上面的操作：
```bash
./story validator set-withdrawal-address --address 输入你提取奖励的新地址
```

## 共识层客户端版本的更新
### 1、检查区块高度  
检查 Story 节点状态，查看其区块高度，需要达到626,575高度才能升级到0.10.*版本，具体可访问[所需区块高度](https://medium.com/story-protocol/story-v0-10-0-available-for-coming-upgrade-e2f9cb10443b)
```bash
story status
```
### 2、版本升级  
当达到既定的区块高度，则可以开始进行升级操作。  
首先，停止共识层客户端
```bash
pm2 stop story-client
```
然后下载0.10.2版本（目前0.10版本中的最新版本），请访问[最新版本](https://github.com/piplabs/story/releases)  
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.2-f7b649d.tar.gz
```

