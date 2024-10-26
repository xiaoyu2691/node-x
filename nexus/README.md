# NEXUS zkVM证明挖矿部署教程  

## 前置条件：
ubuntu/macOS/windows设备

## 推荐运行配置如下：  
|  硬件   |   条件   |
|-----|------|
|  中央处理器   |   4核   |
|  内存   |   6GB   |
|  磁盘   |   100GB   |
  
# 以下是nexus zkVM证明挖矿部署参考教程步骤：  
## 服务器准备  
## 1、安装必要的依赖以及工具（若已安装，则跳过）  
**安装CMake**
检查包管理器，确保更新到最新。  

```bash
sudo apt update && sudo apt upgrade -y
```
安装CMake所需的依赖
```bash
sudo apt install -y build-essential
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
## 安装Nexus zkVM  
### 1、安装RISC-V 目标
```bash
rustup target add riscv32i-unknown-none-elf
```
### 2、安装 Nexus zkVM
```bash
cargo install --git https://github.com/nexus-xyz/nexus-zkvm cargo-nexus --tag 'v0.2.3'
```
### 3、验证安装  
```bash
cargo nexus --help
```
返回结果如下：  
![fb07e73e5a194672efad2771ab66c64](https://github.com/user-attachments/assets/52d5d9c8-5795-440f-8b6b-c4a58d7b1939)  
### 创建新的NEXUS宿主项目  
创建NEXUS宿主项目  
```bash
cargo nexus host nexus-host
```
*若出现依赖问题，请划到最后的错误处理。*  
返回结果如下：  
![image](https://github.com/user-attachments/assets/4ae4e816-e72f-48e7-af5b-e4902da6db9b)
切换到nexus-host文件夹下  
```bash
cd nexus-host
```
运行程序  
```bash
cargo run -r
```
请耐心等待，返回结果如下：  
![image](https://github.com/user-attachments/assets/e6d4167b-008d-45c7-9b4b-672b23859ab0)
## 配置证明器  
### 1、切换NOVA实现  

```bash
cargo nexus prove --impl=nova-par
```
```bash

```



