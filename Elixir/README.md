# Elixir测试网验证器部署指南    

Eliir是一个模块化的DPoS网络，旨在提供订单簿交易所的流动性，具有原生集成。其跨链和可组合性使去中心化交易所能够将Elixir协议集成到其核心基础设施中，释放零售流动性。EIxr与30多个领先的去中心化交易所具有原生集成。此外，E推出了完全抵押、产生收益的合成美元deusD，旨在成为去中心化交易所和中心化交易所之间订单簿流动性的首选抵押品。


## 前置条件:  
需要两个META账户：一个账户地址需要领水和质押，一个账户私钥，请访问[Elixir](https://testnet-3.elixir.xyz/)  
## 配置条件如下:  
| 硬件  | 要求  |
|-----|-----|
|  CPU   |   1核   |
|  内存   |   8GB   |
|   磁盘  |  100GB    |
|   带宽  |  100M/bit |

## 以下是Elixir测试网验证器部署步骤：  
### 一、服务器准备  
**1、安装Docker**  
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```
```bash
sh get-docker.sh
```
