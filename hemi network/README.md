# HEMI network CLI PoP miner 部署指南  

Hemi 网络是模块化二层协议，由比特币和以太坊支持，具扩展性、安全性和互操作性。它不视两者为孤岛，核心是 hVM 整合比特币节点于以太坊虚拟机。结合 hBK，为开发者提供强大平台创建 hApps，开启可编程性等新水平。  

## 前置条件  
ubuntu设备/mac设备  
## 推荐配置如下   

|  硬件  |   要求   |
|----|------|
|  ＣＰＵ  |   ４核   |
|    |      |
|    ｜　　　｜

##  以下是HEMI CLI POP miner参考教程步骤：   
### 一、服务器准备  
1、**安装git、make和Go v1.23+(若已安装，则跳过)**  
检查包管理器，确保更新到最新。
```bash
sudo apt update && sudo apt upgrade -y
```
安装git  
```bash
sudo apt install git
```
安装make  

