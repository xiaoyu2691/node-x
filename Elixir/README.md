# Elixir测试网验证器部署指南    

Eliir是一个模块化的DPoS网络，旨在提供订单簿交易所的流动性，具有原生集成。其跨链和可组合性使去中心化交易所能够将Elixir协议集成到其核心基础设施中，释放零售流动性。EIxr与30多个领先的去中心化交易所具有原生集成。此外，E推出了完全抵押、产生收益的合成美元deusD，旨在成为去中心化交易所和中心化交易所之间订单簿流动性的首选抵押品。

## 前置条件  
至少需要一个META账户

## 配置条件如下  
| 硬件  | 要求  |
|:-----:|:-----:|
|  内存   |   8GB   |
|   磁盘  |  100GB    |
|   带宽  |  100M/bit |

## 以下是Elixir测试网验证器部署步骤(以ubuntu服务器部署为例)：  
### 一、部署前准备  
**1、账户准备**  
领水以及质押的操作,请访问[Elixir](https://testnet-3.elixir.xyz/)  
***（注：质押需要点击两次模拟质押）***  
![image](https://github.com/user-attachments/assets/ddb0ffba-f814-4097-99a0-53a398afbf89)  
### 二、服务器准备  
安装docker  
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```
```bash
sh get-docker.sh
```
### 三、验证者设置  
**1、下载验证器环境模板文件**  
```bash
wget https://files.elixir.finance/validator.env
```
```bash
vim validator.env
```
![image](https://github.com/user-attachments/assets/b8d44c09-2dfe-44f6-8323-854bde4eed59)  

**2、下载Docker的镜像**  
```bash
docker pull elixirprotocol/validator:v3
```

**3、运行验证者**  
```bash
docker run -d \
  --env-file validator.env \
  --name elixir \
  -p 17690:17690 \
  elixirprotocol/validator:v3
```
![image](https://github.com/user-attachments/assets/5d48ee26-c317-4804-8b58-a6e74014c6c6)  

***安装完成！！！***  

### 四、检查节点状态  
**1、检查节点日志**  
```bash
docker logs elixir
```
返回结果如下：  
![image](https://github.com/user-attachments/assets/60317578-d26a-4f66-86dc-a621bfdb4612)  

**2、通过仪表盘检查节点状态**  
通过[Elixir Network Testnet v3仪表盘](https://testnet-3.elixir.xyz/)，检查节点运行状态。    
![image](https://github.com/user-attachments/assets/92d6fa7d-65bb-4964-9bc4-f75a9d918a46)    
![image](https://github.com/user-attachments/assets/cbd77adc-9a30-428f-b55a-fb9d259ca406)  



### 五、升级验证者  
**1、升级节点**  
```bash
docker stop elixir
```
```bash
docker rm elixir
```
```bash
docker pull elixirprotocol/validator:v3
```
```bash
docker run -d \
  --env-file validator.env \
  --name elixir \
  -p 17690:17690 \
  elixirprotocol/validator:v3
```
