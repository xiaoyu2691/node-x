# Story Protocol验证者节点搭建指南



本指南将逐步引导你完成Story 节点的搭建过程。你将学习如何:  
安装并配置story节点  
部署并监控Story节点  
  
前置条件:Ubuntu系统原生设备 /ubuntu虚拟机设备/Mac设备,一个ETH钱包地址

推荐运行配置如下:  

4核CPU +8G 运行内存+200G 硬盘+10m网络  

以下是Story节点参考教程步骤：  

## 服务器准备
1、安装依赖以及必要工具

```bash
apt update && apt upgrade -y
```
检查依赖库，并更新依赖  

```bash
apt install curl wget jp make gcc nano -y
```
快速安装常用软件工具  
```bash
sudo apt install nodejs npm
```
安装nodejs以及npm,如已安装则跳过  

```bash
npm install pm2@latest -g
```
安装pm2，如已安装则跳过    
## 安装Story节点  
  
### 1、下载并解压客户端安装包  
```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
```
下载的最新的执行客户端安装包，请访问[最新版本](https://github.com/piplabs/story-geth/releases)  

```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.13-b4c7db1.tar.gz
```
下载的v0.9的最新版本，共识客户端需要逐步的更新版本，请访问[最新版本](https://github.com/piplabs/story/releases)  

```bash
tar -xzf geth-linux-amd64-0.9.3-b224fdf.tar.gz
tar -xzf story-linux-amd64-0.9.13-b4c7db1.tar.gz
```
解压已下载的安装包  

### 2、设置默认数据文件夹及其客户端设置  
```bash
echo "Story数据根: ${STORY_DATA_ROOT}"
echo "Geth数据根: ${GETH_DATA_ROOT}"
```
设置默认数据文件夹  

```bash
sudo xattr -rd com.apple.quarantine ./geth
sudo xattr -rd com.apple.quarantine ./story
```
如果你是在macOS系统中部署，则需要去除下载文件的隔离属性，如果不是则跳过  

### 3、初始化客户端并运行   
```bash
cp /root/geth-linux-amd64-0.9.3-b224fdf/geth /usr/local/bin
pm2 start /usr/local/bin/geth --name story-geth -- --iliad --syncmode full
```
将/root/geth-linux-amd64-0.9.3-b224fdf/geth文件复制到本地的二进制文件夹下，并使用pm2运行并将进程命名为story-geth，并设置同步。  

```bash
cp /root/story-linux-amd64-0.9.13-b4c7db1/story /usr/local/bin
/usr/local/bin/story init --network iliad
pm2 start /usr/local/bin/story --name story-client -- run
```
初始化共识客户端，使用pm2运行并将进程命名为story-client，到这儿节点就安装完成了。  
## 检查节点状况  
```bash
pm2 logs story-geth
pm2 logs story-client
```
查看客户端的日志信息，检查节点状况  

```bash
pm2 stop story-geth && rm -rf ${GETH_DATA_ROOT} && pm2 start /usr/local/bin/geth --name story-geth -- --iliad --syncmode full
pm2 stop story-client && rm -rf ${STORY_DATA_ROOT} && /usr/local/bin/story init --network iliad && pm2 start /usr/local/bin/story --name story-client -- run
```
清除节点状态并重新启动节点  

## 设置验证者  
### 1、检查.env文件  
```bash
ls .env | grep ".env"
```
检查.env文件是否存在，如果存在则会显示出来  
```bash
vim .env
```
若没有.env文件，则创建一个.env文件
```bash
# ~/story/.env" > .env
PRIVATE_KEY=按i键输入你的私钥，然后按Esc键输入“：wq”保存并退出
```
请确认账户以获得ip资金  
### 2、 创建验证器以及质押操作
```bash
cd /usr/local/bin
./story validator export
```
导出验证器密钥  

```bash
./story validator create --stake 输入你要质押的ip数并乘1000000000000000000
```
创建验证器  

```bash
./story validator stake --validator-pubkey 输入验证器公钥 --stake 输入你要质押的ip数并乘1000000000000000000
```
若你想继续质押，则输入你的验证器公钥以及你要质押的ip数并乘1000000000000000000，若你要帮他人质押则输入他的验证器公钥以及他想要质押的ip数并乘1000000000000000000  
```bash
./story validator unstake --validator-pubkey 输入验证器公钥 --unstake 输入你要取消质押的ip数并乘1000000000000000000
```
若你想取消质押，则输入你的验证器公钥以及你要取消质押的ip数并乘1000000000000000000，若你要帮他人取消质押则输入他的验证器公钥以及他想要取消质押的ip数并乘1000000000000000000   
```bash
./story validator set-withdrawal-address --address 输入你提取奖励的新地址
```
如果你想更换提取奖励的地址，则进行上面的操作。  
## 共识层客户端版本的更新  
```bash
story status
```
检查story节点状态，查看其区块
