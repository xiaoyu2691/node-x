# HEMI network CLI PoP miner 部署指南  

Hemi 网络是模块化二层协议，由比特币和以太坊支持，具扩展性、安全性和互操作性。它不视两者为孤岛，核心是 hVM 整合比特币节点于以太坊虚拟机。结合 hBK，为开发者提供强大平台创建 hApps，开启可编程性等新水平。  

## 前置条件  
ubuntu设备/mac设备  
推特账号拥有10个追随者  
## 配置条件如下   

|  硬件  |   要求   |
|----|------|
|  cpu |   1核   |
|  内存  |   1GB   |
|  磁盘  |50GB   |  

##  以下是HEMI CLI POP miner参考教程步骤：   
### 一、服务器准备  
1、**安装git、make、Go v1.23+、docker、pm2(若已安装，则跳过)**  
检查包管理器，确保更新到最新。
```bash
sudo apt update && sudo apt upgrade -y
```
安装git和make  
```bash
sudo apt install git make -y
```
**安装go v1.23+**   
```bash
wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
```
```bash
export PATH=$PATH:/usr/local/go/bin
```
```bash
go version
```
**安装docker**  
若安装出现问题请访问[Docker官网](https://docs.docker.com/engine/install/)：  
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```
```bash
sh get-docker.sh
```
**安装pm2**  
```bash
sudo apt-get install -y npm
```
```bash
npm install pm2@latest -g
```
### 二、构建二进制文件   
1、克隆heminetwork存储库  
```bash
git clone https://github.com/hemilabs/heminetwork.git
```
```bash
cd heminetwork
```
2、设置并构建二进制文件  
```bash
make deps
```
```bash
make install
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/54c87c3b-8212-4db3-95b2-5c531dbd5346)

### 三、运行 localnet 网络及检查安装情况    
1、启动网络  
```bash
docker compose -f ./e2e/docker-compose.yml up --build
```
2、检查安装情况   
```bash
./popmd --help
```
正常安装完成，返回如下：  
![image](https://github.com/user-attachments/assets/ba587dbe-dcdb-405a-8505-42c162232b08)  

### 四、生成密钥   
1、**生成公钥**  
```bash
./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json
```
2、**导出密钥**  
```bash
cat ~/popm-address.json
```
**记得保存密钥**  
你需要加入hemi的DC，连接推特后加入faucet-commands频道使用生成的哈希领水，加入[hemiDC](https://discord.gg/hemixyz)  

![image](https://github.com/user-attachments/assets/ef47545d-ea4a-4502-b25f-ac22ab5a6e9b)  

### 五、运行矿机  
配置设置  
在“POPM_BTC_PRIVKEY=”后面填写你的私钥或生成的私钥
```bash
export POPM_BTC_PRIVKEY=
```
在“POPM_STATIC_FEE=”后输入你想支付的sat/vB费用（官方建议设置为50）。
```bash
export POPM_STATIC_FEE=
```
```bash
set POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public
```
启动挖矿并放入后台运行，你也可以安装其他工具进行启动。  
```bash
pm2 start popmd
```
### 六、监控挖矿状态  
1、检查挖矿状态  
查看日志信息  
```bash
cd /heminetwork/bin
```
```bash
cat nohup.out
```
部署好之后，可能不会立马挖到区块，等待半天再查看挖矿情况。  
![16533cd243f3e59d38f18629772b93e](https://github.com/user-attachments/assets/b46d579c-901d-4ba3-af7a-554d015f4990)  

2、仪表盘监控挖矿状态及tbtc消耗状态    
在仪表盘右上角输入返回的哈希值回车就能看到挖矿状态，请访问[仪表盘](https://mempool.space/testnet)。   
可以结合日志查看项目是否正常运行  
![image](https://github.com/user-attachments/assets/9ff6eef8-77a9-48b5-922b-1076f26bec2f)    

余额查看   
![image](https://github.com/user-attachments/assets/3c773005-27c3-4c71-a84c-8edb99ebfe18)  




