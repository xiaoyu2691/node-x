### CESS_Storage 存储节点搭建指南

本指南将逐步引导你完成 CESS_Storage 存储节点的搭建。

### 前置条件

- Ubuntu 系统原生设备或 Ubuntu 虚拟机设备
- 至少两个 CESS 钱包地址（[创建钱包参考](https://doc.cess.network/user/cess-account)）

### 存储服务器的推荐要求

| 资源          | 规格                             |
|---------------|----------------------------------|
| 推荐操作系统  | Linux 64 位 Intel / AMD          |
| CPU 核心数    | ≥4                               |
| 内存          | ≥ 8 GB                           |
| 带宽          | ≥ 20 Mbps                        |
| 公网 IP       | 必需的                           |
| Linux 内核版本 | 5.11 或更高版本                  |

以下是 CESS_Storage 存储节点的搭建步骤：

### 1. 服务器准备

1. **安装 Docker**（如果已安装则可跳过）

   [Docker 安装参考](https://docs.docker.com/engine/install/)

2. **防火墙配置**

   以下命令以 root 权限执行。如果出现 "permission denied" 错误，请切换到 root 权限，或者在命令开头添加 `sudo`。

   默认情况下，节点客户端程序 cess-miner 使用端口 4001 来监听传入连接。如果操作系统默认对该端口设置了防火墙，则需要启用对该端口的访问：

   ```bash
   sudo ufw allow 4001
   ```

3. **可选：安装附加驱动器**

   仅当在服务器上安装另一个磁盘或存储设备时才需要此步骤。  
   [参考指南](https://doc.cess.network/cess-miners/storage-miner/running)

### 2. 安装 CESS 客户端

1. **下载并解压安装包**

   ```bash
   wget https://github.com/CESSProject/cess-nodeadm/archive/refs/tags/v0.5.8.tar.gz && tar -xvzf v0.5.8.tar.gz
   ```

   下载最新的安装包并解压，最新版本请查看 [CESS GitHub Releases](https://github.com/CESSProject/cess-nodeadm/tags)。

   ```bash
   cd cess-nodeadm-0.5.8
   ```

2. **安装客户端**

   运行安装脚本：

   ```bash
   ./install.sh
   ```

   如果安装失败，请参考 [故障排除指南](https://doc.cess.network/cess-miners/storage-miner/troubleshooting)。

### 3. 配置 CESS 客户端

1. **设置运行网络**

   ```bash
   sudo cess profile testnet
   ```

2. **设置配置**

   ```bash
   sudo cess config set
   ```

   配置设置步骤如下：

   ```bash
   Enter cess node mode from 'authority/storage/watcher': storage
   Enter cess storage listener port (current: 15001, press enter to skip): （直接回车）
   Enter cess rpc ws-url: wss://testnet-rpc.cess.network/ws/
   Enter cess storage earnings account: （输入以 cX 开头的 CESS 钱包地址）
   Enter cess storage signature account phrase: （输入签名账户的助记词）
   Enter cess storage disk path: /opt/cess/storage/disk
   Enter cess storage space, by GB unit: （输入为 CESS 分配的空间）
   Enter the number of CPU cores used for mining: （输入为 CESS 分配的 CPU 核心数）
   Enter the staker's payment account if you have another: （如果与签名账户一致，直接回车）
   ```

   获取测试代币：[领水](https://cess.network/faucet.html)  
   质押：[质押](https://cess.network/light-wallet/)  
   RPC 地址查看：[RPC 地址](https://scan.cess.network/rpc)

### 4. 启动 CESS 存储节点

```bash
sudo cess start
```

启动成功后如图所示：

![启动成功](https://github.com/user-attachments/assets/6a7b6297-b99d-4955-8af3-da8cf2954c6e)

### 5. 状态检查

1. **在链上检查存储节点状态**

   访问 [Polkadot JS](https://polkadot.js.org/apps/#/accounts)，连接质押的 CESS 钱包。

2. **查看存储节点状态**

   ```bash
   sudo cess miner stat
   ```

3. **查看存储节点日志**

   ```bash
   docker logs miner
   ```

   返回日志信息如图所示：

   ![日志信息](https://github.com/user-attachments/assets/c365000b-3680-4ac3-9c6c-bec38d75e18c)

### 6. 其他操作

其他更新操作及奖励查看：[参考指南](https://doc.cess.network/cess-miners/storage-miner/running)
