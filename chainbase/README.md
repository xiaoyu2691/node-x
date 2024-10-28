# Chainbase AVS Operator 节点部署指南  

Chainbase是全球最大的区块链数据网络，采用创新双链架构，集成全链数据以构建统一生态系统。其双重权益模型支持高吞吐量和低延迟，增强网络安全性。Chainbase的目标是让数据更加开放、可访问，并广泛应用于钱包管理、安全监控、人工智能、社交互动、DeFi等领域，为开发者提供强大支持。  

# 前置条件

- linux环境的设备
- 需要注册操作者（一个推特、一个png格式的logo图片、一个github账号）  
## 存储服务器的推荐要求

| 资源          | 规格                             |
|---------------|----------------------------------|
| 操作环境  |     linux环境     |
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
![image](https://github.com/user-attachments/assets/24b85e44-265e-4871-8985-7bf83ad8dcea)  
![image](https://github.com/user-attachments/assets/ea71d5be-123a-48db-801d-9d0a80d78f29)  
![image](https://github.com/user-attachments/assets/ba638a96-34b5-4e2e-9721-5a53a47ed5bf)  
![2385c0382aa3de2fcd5c7355d7c6521](https://github.com/user-attachments/assets/07df2ed5-0531-47bc-acc7-f05a9a9b24ac)  
![84b28f3c1898c5d0c2b994eb89ad85e](https://github.com/user-attachments/assets/c2cb53b2-ecfa-4f8f-baa0-b5c209738b27)  
![image](https://github.com/user-attachments/assets/c1effe52-d09e-4567-be04-2bb395ecbdc0)  
![image](https://github.com/user-attachments/assets/267896e3-fb09-4f8f-ab42-185460d57cd6)  
![image](https://github.com/user-attachments/assets/b7e6fa63-9bbf-4996-8fea-fd63099892ea)  
![image](https://github.com/user-attachments/assets/d9ab9539-6d1e-4c2c-9a5e-bd3c029eecf0)  
![image](https://github.com/user-attachments/assets/b4ed5fb3-0029-4617-a3fd-ed1ec5c7e976)  
![image](https://github.com/user-attachments/assets/384d845b-7c00-45e1-9453-b93724d0c2cf)  
![image](https://github.com/user-attachments/assets/0488074d-b2a5-496b-9999-862f7b8143bc)  
再将下面的内容复制到metadata.json文件中,根据下面的内容填写自己的json文件。    
***注：logo图片的url,需要在https://github.com/xiaoyu2691/nodex/blob/main/logo.png前加入“raw.”，否则格式可能会出错***  
```bash
{
  "name": "node-x",
  "website": "https://node-x.xyz/",
  "description": "Node-X is a leading Web3 infrastructure platform specializing in node deployment, management, and monitoring, integrating AI optimization for decentralized ecosystems and supporting DePIN projects.",
  "logo": "https://raw.githubusercontent.com/xiaoyu2691/node-x/refs/heads/main/files/logo.png",
  "twitter": "https://x.com/nodex_xyz"
}
```
![image](https://github.com/user-attachments/assets/3584b27a-a6c3-4bc1-b93f-d78da718355a)  
![image](https://github.com/user-attachments/assets/99c7069b-4909-46c9-98b4-cea5e49e525a)  
### 领水  
选择holesky ETH，输入下面生成的操作者钱包地址，点击获取，请访问[holesky领水](https://cloud.google.com/application/web3/faucet/ethereum/holesky)    
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
```bash
eigenlayer operator keys create --key-type ecdsa "wallet_name"
```

```bash
eigenlayer operator keys create --key-type bls "wallet_name"
```
