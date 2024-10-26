# Unichain 节点安装指南  

Unichain 是一个高效、低成本的以太坊 L2 解决方案，专注 DeFi 和多链流动性。其 1 秒出块时间将进一步缩短至 250 毫秒，提高市场效率并减少 MEV 损失。通过将执行移至 L2，Unichain 使交易成本降低约 95%，并支持多链无缝交易与流动性接入，实现跨链互操作性和更高去中心化。  

## 前置条件  
一个META钱包（需要领水，也可以通过桥转到Unichain Testnet下）  
一个可用的RPC  
一个可用的Beacon  
## 运行配置条件如下：  
|  硬件   |  要求   |
|:----:|:----:|
|   内存  |     |
|   磁盘  |     |
|   带宽  |     |


# 以下是Unichain节点部署步骤（以ubuntu服务器部署为例）：  
## 一、部署前准备  
### 1、账户准备  
**领水**  
方法一：  
使用faucets page,请访问[水龙头](https://faucet.quicknode.com/unichain/sepolia)  
**前提条件是需要账户在ETH主网上拥有至少0.001ETH,且有交易记录。**  
![image](https://github.com/user-attachments/assets/921fc925-0838-4a8b-af8f-c73f8fe1db4a)  

方法二：  
通过桥将Sepolia转到Unichain Sepolia下  
**前提条件是你拥有SepoliaETH**   
![image](https://github.com/user-attachments/assets/7fb0918a-465a-4f1e-8c41-970670af5d29)   
**获取RPC**  
使用infura获取rpc,请访问[INFURA](https://www.infura.io/zh)  
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



## 二、服务器准备  
### 1、安装docker
