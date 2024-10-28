# Chainbase AVS Operator 节点部署指南  

Chainbase是全球最大的区块链数据网络，采用创新双链架构，集成全链数据以构建统一生态系统。其双重权益模型支持高吞吐量和低延迟，增强网络安全性。Chainbase的目标是让数据更加开放、可访问，并广泛应用于钱包管理、安全监控、人工智能、社交互动、DeFi等领域，为开发者提供强大支持。  

# 前置条件

- linux环境的设备
- 需要注册操作者（推特网址、一个png格式的logo图片、一个github账号）  
## 存储服务器的推荐要求

| 资源          | 规格                             |
|---------------|----------------------------------|
| 操作环境  |     linux环境                        |
| CPU 核心数    | ≥2                               |
| 内存          | ≥ 8 GB                           |
| 带宽          | ≥ 5 Mbps                        |
| 磁盘           | ≥50GB                             |

# 以下是Chainbase AVS Operator节点的搭建步骤（以ubuntu服务器上部署为例）：  
## 部署前准备  
### 1、github上创建Metadata.json文件  
首先需要创建github账号，若已经创建了账号则直接登录即可    
![image](https://github.com/user-attachments/assets/fb32cb03-619e-4c67-af4a-4b83804218cb)  

![image](https://github.com/user-attachments/assets/40e23168-771a-4314-abe8-8cc9a581371b) 

![image](https://github.com/user-attachments/assets/faa72302-6b8a-4939-a245-3afdee2923b9)  

![image](https://github.com/user-attachments/assets/dd403604-000b-4194-8c43-9ac3e788cd65)  

![image](https://github.com/user-attachments/assets/13ed15c3-29df-4de0-ab6b-bcbd44be798a)  

![image](https://github.com/user-attachments/assets/26b180d4-dfa2-45ed-b7ee-1a39857bff7c)  

![image](https://github.com/user-attachments/assets/699f3d54-2ddc-426c-b9d8-69513f8b4ab6)  

![image](https://github.com/user-attachments/assets/d5e47d3e-c23f-408c-aeb8-6c1fa63b2324)  

![image](https://github.com/user-attachments/assets/22b1e3a6-8e0b-485d-a5b9-8a7eae4553b0)  

![image](https://github.com/user-attachments/assets/26ff1c89-09ca-43e0-894c-299dc7c22b6b)

![image](https://github.com/user-attachments/assets/5d1ed1be-b5fc-482d-aab6-fb985a772eaa)  

![image](https://github.com/user-attachments/assets/453e61b6-787c-4485-ade7-551558331369)  

![image](https://github.com/user-attachments/assets/ea71d5be-123a-48db-801d-9d0a80d78f29)  

![image](https://github.com/user-attachments/assets/a80aaaac-18f4-4f97-8389-348f40f611e8)  

![8d131ecd018b5e1607a675a82780c46](https://github.com/user-attachments/assets/100a0c11-b2e6-4686-8334-6232f18db2b1)  

![84b28f3c1898c5d0c2b994eb89ad85e](https://github.com/user-attachments/assets/c2cb53b2-ecfa-4f8f-baa0-b5c209738b27)  

![d36b7932237888f0b4e8a17a8cf1239](https://github.com/user-attachments/assets/d7743b8f-8ea8-41d1-ae85-a82b0d2ca709)

![image](https://github.com/user-attachments/assets/267896e3-fb09-4f8f-ab42-185460d57cd6)  

![image](https://github.com/user-attachments/assets/9ed5c85a-90cd-4189-a76c-c2772cd55357)  

![7177708a2d598e10574db3f75e57915](https://github.com/user-attachments/assets/c3ce6b63-2641-4c99-8ba1-90132312111f)  
 
![image](https://github.com/user-attachments/assets/b4ed5fb3-0029-4617-a3fd-ed1ec5c7e976)  
![image](https://github.com/user-attachments/assets/384d845b-7c00-45e1-9453-b93724d0c2cf)  
![image](https://github.com/user-attachments/assets/0488074d-b2a5-496b-9999-862f7b8143bc)  
将下面的内容复制到metadata.json文件中,以下面的内容为例子填写自己的json文件。    
***注：logo图片的url,需要以https://raw.githubusercontent.com/为开头，否则格式可能会出错***  
```bash
{
  "name": "node-x",
  "website": "https://node-x.xyz/",
  "description": "Node-X is a leading Web3 infrastructure platform specializing in node deployment, management, and monitoring, integrating AI optimization for decentralized ecosystems and supporting DePIN projects.",
  "logo": "https://raw.githubusercontent.com/nodex/node-x/refs/heads/main/files/logo.png",
  "twitter": "https://x.com/nodex_xyz"
}
```
![image](https://github.com/user-attachments/assets/3584b27a-a6c3-4bc1-b93f-d78da718355a)  
![image](https://github.com/user-attachments/assets/99c7069b-4909-46c9-98b4-cea5e49e525a)  
### 领水  
将下方生成的私钥导入META钱包中，向其中转入0.001ETH，选择holesky ETH，输入下面生成的操作者钱包地址，点击获取holesky ETH或将其他钱包中的holesky ETH转到该账户，请访问[holesky领水](https://cloud.google.com/application/web3/faucet/ethereum/holesky)    
![image](https://github.com/user-attachments/assets/3101a242-36fa-4247-bb0c-770f7187774d)  

## 服务器准备(若已安装，则跳过)    
### 1、安装docker     
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
### 3、安装go  
```bash
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```
## 注册操作者  
### 1、安装eigenlayer  
```bash
curl -sSfL https://raw.githubusercontent.com/layr-labs/eigenlayer-cli/master/scripts/install.sh | sh -s
export PATH=$PATH:~/bin
eigenlayer --version
```
### 2、克隆chainbase存储库  
```bash
git clone https://github.com/chainbase-labs/chainbase-avs-setup
cd chainbase-avs-setup/holesky
```
### 3、创建ECDSA和BLS  
**将ECDSA和BLS设置为相同的密码**
```bash
eigenlayer operator keys create --key-type ecdsa "wallet_name"
```
![image](https://github.com/user-attachments/assets/7979883f-c845-45fc-8f3f-6e6703418202)  
```bash
eigenlayer operator keys create --key-type bls "wallet_name"
```
![image](https://github.com/user-attachments/assets/2d684825-3c44-4ac3-8802-cfd9863c79e5)  
### 4、配置operator.yaml  
**配置operator**  
```bash
eigenlayer operator config create
```
RPC
```bash
https://ethereum-holesky-rpc.publicnode.com
```
以下方截图为例  
![image](https://github.com/user-attachments/assets/4f406554-d9e2-4893-9994-2c67ed1d2f76)  

```bash
vim operator.yaml
```
![53558848abde5821995f4c619964f1f](https://github.com/user-attachments/assets/9f09696d-9e29-4013-bc4e-88530abdb85f)  

### 5、注册操作者  
```bash
eigenlayer operator register operator.yaml
```
返回结果如下  
![image](https://github.com/user-attachments/assets/c439d81d-a523-4365-839a-64725d29c30e)  

## 注册AVS运营商并运行节点    
### 1、创建.env文件  
```bash
vim .env
```
**其中是需要你输入你设置的一些信息**
```bash
USER_HOME=$HOME
EIGENLAYER_HOME=${USER_HOME}/.eigenlayer
CHAINBASE_AVS_HOME=${EIGENLAYER_HOME}/chainbase/holesky
NODE_LOG_PATH_HOST=${CHAINBASE_AVS_HOME}/logs

NODE_ECDSA_KEY_FILE_HOST=${EIGENLAYER_HOME}/operator_keys/你设置的wallet_name.ecdsa.key.json
NODE_ECDSA_KEY_PASSWORD=你创建ECDSA时设置的密码

NODE_ECDSA_KEY_FILE_PATH=${NODE_ECDSA_KEY_FILE_HOST}
NODE_BLS_KEY_FILE_PATH=${EIGENLAYER_HOME}/operator_keys/你设置的wallet_name.bls.key.json
OPERATOR_ECDSA_KEY_PASSWORD=${NODE_ECDSA_KEY_PASSWORD}
OPERATOR_BLS_KEY_PASSWORD=${NODE_ECDSA_KEY_PASSWORD}
# You can run `eigenlayer operator keys list` to check your opertor address.
OPERATOR_ADDRESS=你生成的钱包地址
# Ip address and port of the Node gRPC server.Like 8.219.81.93:8011
# Ensure your server’s public IP is internet-accessible.
# Verify that port 8011 is open and properly configured in your firewall settings.
NODE_SOCKET=你的服务器的ip:8011
# Your Operator name you want to be identified by, it helps us route alerts and metrics to your notification channels easily
OPERATOR_NAME=你设置的wallet_name
```
```bash
source .env && mkdir -pv ${EIGENLAYER_HOME} ${CHAINBASE_AVS_HOME} ${NODE_LOG_PATH_HOST}
```
### 2、修改chainbase-avs.sh  
```bash
vim chainbase-avs.sh
```
根据图片修改脚本   
![image](https://github.com/user-attachments/assets/5c252aa5-3940-4e51-8281-5cefa337cee7)  
```bash
-e OPERATOR_BLS_KEY_PASSWORD=$NODE_ECDSA_KEY_PASSWORD -e OPERATOR_ECDSA_KEY_PASSWORD=$NODE_ECDSA_KEY_PASSWORD
```
按“i”键进行修改，修改完成后，按“esc”键并输入“：wq”保存退出。  

### 3、注册AVS运营商  
```bash
./chainbase-avs.sh register
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/826dbf37-a4f8-4594-82a7-83e21e1d63c5)  
### 4、运行节点  
```bash
./chainbase-avs.sh run
```
返回结果如下：  
![623d103947fb12570b1be3025df6f8a](https://github.com/user-attachments/assets/ffd17499-dc3e-4e88-a358-7c825c929164)  

## 监控节点状态  
### 1、通过端口3010查看节点状态  
在浏览器中输入
```bash
你的服务器的ip地址:3010
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/a216d2e4-fcb0-4d6d-bd4f-2d5c607bf9be)  


## 一键部署  
