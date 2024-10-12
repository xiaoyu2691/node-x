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
安装pm2，如已安装  
## 安装Story节点
1、


