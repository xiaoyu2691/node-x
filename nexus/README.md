# NEXUS CLI证明器节点部署教程  

## 前置条件：
ubuntu/macOS/windows设备

## 推荐运行配置如下：  
|  硬件   |   条件   |
|-----|------|
|  中央处理器   |   4核   |
|  内存   |   6GB   |
|  磁盘   |   100GB   |
  
# 以下是nexus Cli证明器节点部署参考教程步骤：  
## 服务器准备  
## 1、安装必要的依赖以及工具（若已安装，则跳过）  
**安装CMake**
检查包管理器，确保更新到最新。  

```bash
sudo apt update && sudo apt upgrade -y
```
安装CMake所需的依赖
```bash
sudo apt install build-essential pkg-config libssl-dev git-all
```
下载CMake最新的版本，最新版本请访问[CMake官方](https://cmake.org/)  
```bash
wget https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-linux-x86_64.sh
```
给予其执行权限  
```bash
chmod +x cmake-3.24.2-linux-x86_64.sh
```
安装CMake  
```bash
sudo ./cmake-3.24.2-linux-x86_64.sh --skip-license --prefix=/usr/local
```
验证安装  
```bash
cmake --version
```
返回结果，如下：  
![image](https://github.com/user-attachments/assets/fccdb178-ae4c-4b78-9bde-9c37438092c3)  

**安装RUST**
检查包管理器，确保更新到最新。
```bash
sudo apt update && sudo apt upgrade -y
```
安装Rust所需依赖  
```bash
sudo apt install -y curl
```
使用Rust安装工具（rustup）  
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
配置环境变量  
```bash
source $HOME/.cargo/env
```
验证安装  
```bash
rustc --version
```
## 运行Nexus CLI证明器节点  
```bash
curl https://cli.nexus.xyz/ | sh
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/7689f3d2-06e4-46e4-87b1-b55bc3e2373f)   

