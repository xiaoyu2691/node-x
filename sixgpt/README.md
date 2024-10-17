# SIXGPT Miner搭建指南

SixGPT 是一个基于 Vana 网络构建的去中心化合成数据生成平台。我们赋予用户数据所有权，并使他们能够从中获利，从而增强用户的能力。
SixGPT Miner 是一个软件包，它允许用户将他们为维基百科问答任务生成的数据贡献给网络以获得奖励。未来，我们将支持其他任务，例如聊天机器人对话、图像字幕等。

## 本指南将逐步引导你完成 SIXGPT Miner 的搭建

### 服务器实测要求

| 资源   | 规格   |
|--------|--------|
| CPU    | ≥ 4    |
| 内存   | ≥ 4 GB  |

## SIXGPT Miner 的搭建步骤：

### 1. 服务器准备

1. **安装 Docker（已安装则跳过）**  
   若不知道服务器情况，则检查是否安装 Docker：  
   ```bash
   docker -v
   ```
   已安装则返回：  
   ![image](https://github.com/user-attachments/assets/d6c7aa3d-a5dc-4549-8241-5b39d1d93636)

   安装 Docker，若安装出现问题请访问 [Docker 官网](https://docs.docker.com/engine/install/)：  
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   ```
   ```bash
   sh get-docker.sh
   ```

### 2. 安装并启动 SIXGPT Miner

1. 克隆存储库：  
   ```bash
   git clone https://github.com/sixgpt/miner.git
   ```
2. 设置环境变量  
   
   在 `VANA_PRIVATE_KEY=` 后填入有 $VANA 的账户私钥：  
   ```bash
   export VANA_PRIVATE_KEY=
   ```
   设置网络为 Satori：  
   ```bash
   export VANA_NETWORK=satori
   ```
   切换到 `miner` 文件夹下：  
   ```bash
   cd miner
   ```
   启动矿工：  
   ```bash
   docker compose up -d
   ```
   返回结果如下：  
   ![image](https://github.com/user-attachments/assets/66ccdcfc-b709-456a-8774-9ab3ccfdebd4)

**SIXGPT Miner 安装已完成！**

### 查看 SIXGPT Miner 状况

1. 查看 Miner 日志：  
   ```bash
   docker logs miner-sixgpt3-1
   ```
   这是没有 $VANA 的账户状态：  
   ![image](https://github.com/user-attachments/assets/3797e0e9-341f-4201-b1df-bfa4d931962a)

   正常运行结果如下：  
   ![image](https://github.com/user-attachments/assets/7f7c2bee-22f0-40ae-96fa-0636ce3a41ed)
