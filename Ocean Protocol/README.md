# Ocean节点部署指南  

Ocean 是一个去中心化的数据交换协议，为人工智能提供数据支持。其技术核心包括数据 NFT 和数据代币，用于去中心化的访问控制，以及“计算到数据”功能，实现隐私保护的数据买卖。此外，Ocean 拥有活跃的社区生态系统，聚集了众多开发者、数据科学家和 OCEAN 持有者，并通过社交媒体平台保持互动。  

# 前置条件
- 一个META钱包地址
## 存储服务器的推荐要求

| 资源          | 规格                             |
|---------------|----------------------------------|
| CPU           | ≥1                               |
| 内存          | ≥ 2 GB                           |
| 磁盘           | ≥4GB                             |

# 以下是Ocean节点的搭建步骤（以ubuntu服务器上部署为例）： 
## 一、服务器准备  
### 1、安装Docker  
若安装出现问题，请访问 [Docker 官网](https://docs.docker.com/engine/install/)：

   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```
### 2、安装docker-compose  
若安装出现问题，请访问[Docker-compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)  
```bash
sudo apt-get update
```
```bash
sudo apt-get install docker-compose-plugin
```
## 二、安装Ocean-node  
### 1、创建项目文件夹  
```bash
mkdir ocean && cd ocean
```
### 2、下载脚本并执行  
```bash
wget https://raw.githubusercontent.com/oceanprotocol/ocean-node/refs/heads/main/scripts/ocean-node-quickstart.sh && chmod +x ocean-node-quickstart.sh && ./ocean-node-quickstart.sh
```
### 3、配置docker-compose.yml文件  
根据自己的情况选择是否自动生成私钥，这里以生成私钥为例  
```bash
Do you have your private key for running the Ocean Node [ y/n ]:n 
Do you want me to create a private key for you [ y/n ]: y 
Generating Private Key, please wait...
Generated Private Key: 返回的私钥
Please provide the wallet address to be added as Ocean Node admin account: 输入一个钱包地址，作为管理账户的钱包地址
Provide the HTTP_API_PORT value or accept the default (press Enter) [8000]:一般都默认，直接回车
Provide the P2P_ipV4BindTcpPort or accept the default (press Enter) [9000]: 
Provide the P2P_ipV4BindWsPort or accept the default (press Enter) [9001]: 
Provide the P2P_ipV6BindTcpPort or accept the default (press Enter) [9002]: 
Provide the P2P_ipV6BindWsPort or accept the default (press Enter) [9003]: 
Provide the public IPv4 address or FQDN where this node will be accessible:填入服务器的public ipv4，通常为服务器ip
```
### 4、运行Ocean 节点  
```bash
docker-compose up -d
```
可能刚开始无法看到数据，你可以隔一天左右查看一下节点运行的状态，返回结果如下：  
![image](https://github.com/user-attachments/assets/7ccd89d4-e038-41b6-999d-bbd5f20702bc)  

## 三、检查节点运行状态  
### 1、查看节点日志  
```bash
docker logs ocean-node
```
返回结果如下
![image](https://github.com/user-attachments/assets/98ef3a13-0627-45bc-b338-816e3e30359e)  

### 2、查看节点一个周正常运行时间  
你可以访问[官方仪表盘](https://nodes.oceanprotocol.com/)，查看节点一个周的正常运行时间的百分比，当你的节点运行了快一个周的时候，你可以使用填入的或生成的私钥导出的钱包地址进行查询。  
![image](https://github.com/user-attachments/assets/79a65f0b-4c3b-46cb-bc27-3271c06a3446)  
![image](https://github.com/user-attachments/assets/0ab16866-054f-4a5d-9cdd-ed4d840e7453)    

### 3、查看节点运行的具体情况  
你可以在浏览器输入ip以及端口（默认为8000），查看节点具体的运行状态。  
```bash
http://<ip>:<端口>/dashboard
```
![image](https://github.com/user-attachments/assets/b23ff964-bad3-4fdc-8184-8274f8855d84)   

## 四、一键部署  






