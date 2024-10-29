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
## 服务器准备  
### 1、安装curl  
  ```bash
  sudo apt-get update && sudo apt-get upgrade -y
  ```
```bash
sudo apt install curl -y
```
### 2、安装Docker  
若安装出现问题，请访问 [Docker 官网](https://docs.docker.com/engine/install/)：

   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```
### 3、安装docker-compose  
若安装出现问题，请访问[Docker-compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)  
```bash
sudo apt-get update
```
```bash
sudo apt-get install docker-compose-plugin
```
## 安装Ocean-node  
### 1、创建项目文件夹  
```bash
mkdir ocean && cd ocean
```
### 2、下载脚本并执行  
```bash




