# Story Protocol 验证者节点搭建指南  

互联网为创意作品提供了前所未有的传播和混合方式，但现有的知识产权（IP）体系却无法有效支持这一转变。Story Protocol 旨在创建一个开放且无摩擦的 IP 基础设施，允许创作者追踪其作品的起源和发展，同时实现灵活的许可系统。这一协议通过区块链技术确保 IP 的透明性和真实性，促进创作者与社区的互动。随着人工智能和新创作模式的兴起，Story Protocol 能够帮助创作者在网络化环境中获取价值，推动创意产业的未来发展。通过构建一个新的生态系统，IP 可以变得流动，促进资本形成和共同创作。

本指南将逐步引导你完成 Story 节点的搭建过程。你将学习如何：
- 安装并配置 Story 节点
- 部署并监控 Story 节点

## 前置条件
- Ubuntu 系统原生设备 / Ubuntu 虚拟机设备 / Mac 设备
- 一个 ETH 钱包私钥

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
安装 Node.js，如已安装则跳过：
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
```
安装npm，如已安装则跳过：  
```bash
sudo apt-get install -y npm
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

  **节点安装完成！！！**

## 检查节点状况
### 1. 查看节点状态
查看节点状态  
```bash
story status
```
返回结果，可能刚开始会显示错误，需要等一会儿：  
![image](https://github.com/user-attachments/assets/e67d37a9-c220-4bb7-be9f-33dfacb68db6)

若出现错误，情况如下：  
![4be4e2b46eb277694ed07ead358baac](https://github.com/user-attachments/assets/0d820836-66bb-41db-a2f3-a337ad29be14)  
可以尝试  
```bash
rm -rf ${STORY_DATA_ROOT}/data/* && \
echo '{"height": "0", "round": 0, "step": 0}' > ${STORY_DATA_ROOT}/data/priv_validator_state.json
pm2 restart story-client
```
查看客户端的日志信息，检查节点状况：
```bash
pm2 logs
```
返回结果，刚安装完成需要等会儿才有区块完成：  
![398479ece825eee2a5752fbe78456d1](https://github.com/user-attachments/assets/65b6cc25-fb89-4ac4-82d9-11a13a238884)  

如果需要清除节点状态并重新启动节点，则输入以下命令：
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
如下图所示  
![image](https://github.com/user-attachments/assets/99615161-9196-4fbc-97d2-3ee3f48ac07e) 

### 2. 创建验证器以及质押操作  
***请先确保story节点是同步运行的！！***  
导出验证器密钥：  
**记得保存密钥**  

```bash
story validator export
```

创建验证器，创建成功后会有一个网址返回，请保存下来以便于查看质押情况。  
**记得保存网址**  
下面是质押1IP的命令，若想质押更多则将“1”改为你想质押的IP数，以下的全部质押都以1IP为例。  

```bash
story validator create --stake 1000000000000000000
```

若你想继续质押，则输入你的验证器公钥以及你要质押的 IP 数并乘 1000000000000000000；若你要帮他人质押，则输入他的验证器公钥以及他想要质押的 IP 数并乘 1000000000000000000： 

```bash
story validator stake --validator-pubkey 输入验证器公钥 --stake 1000000000000000000
```

若你想取消质押，则输入你的验证器公钥以及你要取消质押的 IP 数并乘 1000000000000000000；若你要帮他人取消质押，则输入他的验证器公钥以及他想要取消质押的 IP 数并乘 1000000000000000000：

```bash
story validator unstake --validator-pubkey 输入验证器公钥 --unstake 1000000000000000000
```

如果你想更换提取奖励的地址，则进行上面的操作：  
请确保该账户已经进行质押  

```bash
story validator set-withdrawal-address --withdrawal-address 输入你提取奖励的新地址
```

## 共识层客户端版本的更新
### 1. 检查区块高度  
检查 Story 节点状态，查看其区块高度，需要达到 626,575 高度才能升级到 0.10.* 版本，需要达到1325860高度才能升级到0.11.*版本。  
具体可访问[升级到0.10.*所需区块高度](https://medium.com/story-protocol/story-v0-10-0-available-for-coming-upgrade-e2f9cb10443b)  
具体可访问[升级到0.11.*所需区块高度](https://medium.com/story-protocol/story-v0-10-0-node-upgrade-guide-42e2fbcfcb9a)  
```bash
story status
```
区块高度如图所示  
![image](https://github.com/user-attachments/assets/1d5e163e-381c-4e27-92d6-887f421c7044)  

### 2. 版本升级（0.9.13——>0.10.2）   
当达到既定的区块高度（626575），则可以开始进行升级操作。  
首先，停止共识层客户端  
```bash
pm2 stop story-client
```
然后下载并解压 0.10.2 版本（目前 0.10 版本中的最新版本），请访问 [最新版本](https://github.com/piplabs/story/releases)  
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.2-f7b649d.tar.gz && tar -xzf story-linux-amd64-0.10.2-f7b649d.tar.gz
```
同时将 story-linux-amd64-0.10.2-f7b649d 文件夹下的 story 文件复制到 /usr/local/bin 文件夹下
```bash
cp /root/story-linux-amd64-0.10.2-f7b649d/story /usr/local/bin
```
然后启动客户端  
```bash
pm2 start story-client
```
最后访问日志信息，查看是否正常同步运行  
```bash
pm2 logs story-client
```

### 3. 版本升级（0.10.2——>0.11.0） 
当达到既定的区块高度（1325860），则可以开始进行升级操作。  
首先，停止共识层客户端  
```bash
pm2 stop story-client
```
然后下载 0.11.0 版本（目前 0.11 版本中的最新版本），请访问 [最新版本](https://github.com/piplabs/story/releases)  
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.11.0-aac4bfe.tar.gz &&  tar -xzf story-linux-amd64-0.11.0-aac4bfe.tar.gz
```
同时将 story-linux-amd64-0.11.0-aac4bfe 文件夹下的 story 文件复制到 /usr/local/bin 文件夹下  
```bash
cp /root/story-linux-amd64-0.11.0-aac4bfe/story /usr/local/bin
```
然后启动客户端  
```bash
pm2 start story-client
```
最后访问日志信息，查看是否正常同步运行  
```bash
pm2 logs story-client
```

## 质押状态  
### 通过验证器返回的网址查看质押情况   
将质押的钱包地址输入并返回，就能够在下方查看你的质押情况，下图仅供参考：  
![image](https://github.com/user-attachments/assets/65c2773d-33e5-4000-8b75-14f1ce109ba1)  

---
