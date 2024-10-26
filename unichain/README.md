# Unichain 节点安装指南  

Unichain 是一个高效、低成本的以太坊 L2 解决方案，专注 DeFi 和多链流动性。其 1 秒出块时间将进一步缩短至 250 毫秒，提高市场效率并减少 MEV 损失。通过将执行移至 L2，Unichain 使交易成本降低约 95%，并支持多链无缝交易与流动性接入，实现跨链互操作性和更高去中心化。  

## 前置条件  
一个META钱包（需要领水，也可以通过桥转到Unichain Testnet下）  

## 运行配置条件如下：  
|  硬件   |  要求   |
|:----:|:----:|
|   内存  |     |
|   磁盘  |     |
|   带宽  |     |


# 以下是Unichain节点部署步骤（以ubuntu服务器部署为例）：  
## 一、部署前准备  
### 1、账户准备  
领水方法一：  
使用faucets page,请访问[水龙头](https://faucet.quicknode.com/unichain/sepolia)  
**前提条件是需要账户在ETH主网上拥有至少0.001ETH,且有交易记录。**  
![image](https://github.com/user-attachments/assets/921fc925-0838-4a8b-af8f-c73f8fe1db4a)  

方法二：  
通过桥将Sepolia转到Unichain Sepolia下  
**前提条件是你拥有SepoliaETH**   
![image](https://github.com/user-attachments/assets/7fb0918a-465a-4f1e-8c41-970670af5d29)   

## 二、服务器准备  
### 1、安装docker
