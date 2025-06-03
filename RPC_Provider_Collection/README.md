# 主要RPC供应商、订阅费用及RPC服务差异

以下是区块链领域主要RPC供应商的列表，涵盖其订阅费用及RPC服务的关键差异点（如支持的链、请求限制、特殊功能等）。由于数据限制，部分信息可能需进一步确认。

## 1. Ankr
- **官网**: [https://www.ankr.com](https://www.ankr.com)
- **订阅费用**:
  - **免费计划**: 每月3000万次请求，30请求/秒，23条链，10个地区，社区支持。
  - **高级计划**: 按需付费，每1亿信用点$10，支持1500请求/秒，30条链，40个地区，包含支持门户。
  - **企业计划**: 定制化定价，需联系Ankr获取报价。
- **RPC服务差异**:
  - **支持链**: 37+条链，包括以太坊、Polygon、BNB Chain、Solana、Arbitrum、Optimism等。[](https://onfinality.medium.com/comparing-top-rpc-providers-for-blockchain-development-227d196da04d)
  - **特殊功能**: 提供去中心化节点网络（40个数据中心，独立节点提供者），支持多链API、NFT API、查询API、代币API，低延迟连接。
  - **请求限制**: 免费计划30请求/秒，高级计划1500请求/秒。
  - **其他**: 提供Liquid Staking、游戏SDK，注重去中心化以提高抗中断能力。[](https://onfinality.medium.com/comparing-top-rpc-providers-for-blockchain-development-227d196da04d)[](https://liebrecapital.com.ar/bitcoin-rpc/)

## 2. Infura
- **官网**: [https://www.infura.io](https://www.infura.io)
- **订阅费用**:
  - **免费计划**: 每日10万次请求，25000次存档请求。
  - **开发者计划**: $50/月，每日20万次请求，10万次存档请求，包含直接支持。
  - **团队计划**: $225/月，每日100万次请求，100万次存档请求。
  - **增长计划**: $1000/月，每日500万次请求，500万次存档请求，可加购额外100万次请求（$200/月）。
  - **企业计划**: 定制化，需联系Infura。
    ![image](https://github.com/user-attachments/assets/0197a432-12c8-46ea-adbc-b4afd65fc687)

- **RPC服务差异**:
  - **支持链**: 10+条链，包括以太坊、Polygon、Optimism、Arbitrum、NEAR、StarkNet等。[](https://github.com/arddluma/awesome-list-rpc-nodes-providers/blob/main/README.md)
  - **特殊功能**: 提供IPFS网关、NFT API+SDK、免费存档数据访问，Web3.js和JSON-RPC实时事件流。
  - **请求限制**: 免费计划每日10万次，高级计划每日500万次。
  - **其他**: 以太坊生态首选，广泛用于Uniswap、MetaMask等项目，注重易用性和可靠性。[](https://slashdot.org/software/rpc-node/)[](https://blog.onfinality.io/comparing-top-rpc-providers-for-blockchain-development/)

## 3. Alchemy
- **官网**: [https://www.alchemy.com](https://www.alchemy.com)
- **订阅费用**:
  - **免费计划**: 每月3亿计算单元（Compute Units），适合测试。
  - **增长计划**: $49/月起，更多计算单元和高级功能。
  - **扩展计划**: $199/月，适合大型DApp。
  - **企业计划**: 定制化，需联系Alchemy。
- **RPC服务差异**:
  - **支持链**: 37条链，包括以太坊、Solana、Polygon、Arbitrum、Optimism等。[](https://drpc.org/blog/best-ethereum-rpc-providers/)
  - **特殊功能**: 提供跨链NFT API、Alchemy Build（无配置开发工具）、Alchemy Monitor（应用健康和性能监控），支持调试和跟踪API，无MEV保护。
  - **请求限制**: 最高300请求/秒，计算单元模型（55-1000单位/请求，视用例）。
  - **其他**: 以高性能和开发者工具著称，70%以太坊应用使用Alchemy Supernode。[](https://slashdot.org/software/rpc-node/)[](https://www.chainnodes.org/blog/alchemy-vs-infura-vs-quicknode-vs-chainnodes-ethereum-rpc-provider-pricing-comparison/)

## 4. Pocket Network
- **官网**: [https://www.pokt.network](https://www.pokt.network)
- **订阅费用**:
  - **免费计划**: 有限请求配额（未公开具体数量），需联系获取付费详情。
  - **付费计划**: 按POKT代币计费，价格随市场波动。
  - **企业计划**: 定制化，需联系Pocket Network。
- **RPC服务差异**:
  - **支持链**: 30+条链，包括以太坊、BNB Chain、Solana、Arbitrum、Optimism、Gnosis等。[](https://drpc.org/blog/10-best-rpc-node-providers/)
  - **特殊功能**: 去中心化RPC协议，17000+节点覆盖22个国家，支持MEV保护，无调试工具或团队协作功能。
  - **请求限制**: 未公开具体限制，强调去中心化网络的抗审查性。
  - **其他**: 通过POKT代币激励节点运行者，适合注重去中心化的开发者。[](https://slashdot.org/software/rpc-node/)[](https://liebrecapital.com.ar/bitcoin-rpc/)

## 5. QuickNode
- **官网**: [https://www.quicknode.com](https://www.quicknode.com)
- **订阅费用**:
  - **发现计划**: 免费，每月1000万API信用，25请求/秒，1个端点。
  - **构建计划**: $49/月，2000万API信用，100请求/秒，10个端点。
  - **扩展计划**: $299/月，1.2亿API信用，300请求/秒，20个端点。
  - **企业计划**: 定制化，需联系QuickNode。
- **RPC服务差异**:
  - **支持链**: 66条链，包括以太坊、Solana、Polygon、BNB Chain、Arbitrum、Optimism等。[](https://drpc.org/blog/best-ethereum-rpc-providers/)
  - **特殊功能**: 提供NFT API、调试和跟踪API、WebHooks、分析仪表板，全球节点网络优化低延迟，无MEV保护。
  - **请求限制**: 最高400请求/秒，API信用模型（1-500信用/请求）。
  - **其他**: 性能测试显示QuickNode全球平均响应时间86ms，领先于Ankr（164ms）和Alchemy（207ms）。[](https://blog.quicknode.com/justifying-quick-in-quicknode-response-time-comparison-of-various-blockchain-node-providers/)[](https://www.chainnodes.org/blog/alchemy-vs-infura-vs-quicknode-vs-chainnodes-ethereum-rpc-provider-pricing-comparison/)

## 6. Moralis
- **官网**: [https://moralis.io](https://moralis.io)
- **订阅费用**:
  - **免费计划**: 每月100万次API调用，适合初学者。
  - **专业计划**: $49/月，包含更多调用和功能。
  - **商业计划**: $199/月，适合中型项目。
  - **企业计划**: 定制化，需联系Moralis。
- **RPC服务差异**:
  - **支持链**: 24条链，包括以太坊、Polygon、BNB Chain、Arbitrum等。[](https://drpc.org/blog/best-ethereum-rpc-providers/)
  - **特殊功能**: 提供实时数据库同步、用户认证、NFT API，注重快速集成，无调试支持或MEV保护。
  - **请求限制**: 无具体请求/秒限制，订阅模型基于调用量。
  - **其他**: 更适合Web3开发平台而非高流量RPC骨干。[](https://www.nadcab.com/blog/rpc-node-in-blockchain)[](https://drpc.org/blog/best-ethereum-rpc-providers/)

## 7. Chainstack
- **官网**: [https://chainstack.com](https://chainstack.com)
- **订阅费用**:
  - **开发者计划**: 免费，每月300万次全节点请求。
  - **增长计划**: $40/月，2000万次弹性全节点请求。
  - **商业计划**: $290/月，1.4亿次弹性全节点请求。
  - **企业计划**: $825/月，4亿次弹性全节点请求，年度订阅享16%折扣。
- **RPC服务差异**:
  - **支持链**: 25+条链，包括以太坊、Polygon、BNB Chain、Solana、Arbitrum等。[](https://blog.onfinality.io/comparing-top-rpc-providers-for-blockchain-development/)
  - **特殊功能**: 提供平台API、NFT API、调试和跟踪API，多云支持，简化节点管理。
  - **请求限制**: 最高200请求/秒，基于请求单位计费。
  - **其他**: 提供托管和市场解决方案，欧洲地区响应时间78ms，接近QuickNode。[](https://blog.quicknode.com/justifying-quick-in-quicknode-response-time-comparison-of-various-blockchain-node-providers/)[](https://onfinality.medium.com/comparing-top-rpc-providers-for-blockchain-development-227d196da04d)

## 8. GetBlock
- **官网**: [https://getblock.io](https://getblock.io)
- **订阅费用**:
  - **免费计划**: 每日4万次请求，覆盖50+条链。
  - **付费计划**: $10起，无到期日，最高100万次请求。
  - **企业计划**: 定制化，需联系GetBlock。
- **RPC服务差异**:
  - **支持链**: 50+条链，包括以太坊、Solana、Polygon、BNB Chain、Optimism等。[](https://github.com/arddluma/awesome-list-rpc-nodes-providers/blob/main/README.md)
  - **特殊功能**: 支持JSON-RPC、REST、WebSocket API，提供专用节点配置器，适合高性能DApp，无限端点（免费计划独有）。
  - **请求限制**: 免费计划最高40请求/秒，付费计划依配置。
  - **其他**: 提供区块链分析工具和咨询服务，响应时间254ms（受攻击期间）。[](https://blog.quicknode.com/justifying-quick-in-quicknode-response-time-comparison-of-various-blockchain-node-providers/)[](https://getblock.io/blog/best-blockchain-prc-providers-for-2023-researching-cost-efficiency/)

## 9. Blockdaemon
- **官网**: [https://blockdaemon.com](https://blockdaemon.com)
- **订阅费用**:
  - **免费计划**: 1500万计算单元，25请求/秒，20+条链。
  - **增长计划**: 有限月调用量，200请求/秒，99% uptime SLA。
  - **企业计划**: 定制化，200+请求/秒，需联系Blockdaemon。
- **RPC服务差异**:
  - **支持链**: 50+条链，包括以太坊、Solana、Polygon、Cosmos、Polkadot等。[](https://www.alchemy.com/overviews/blockchain-node-providers)
  - **特殊功能**: 提供Nodes-as-a-Service，高可用性集群，Ubiquity API套件，注重企业级安全性和合规性，无MEV保护。
  - **请求限制**: 最高200请求/秒。
  - **其他**: 面向机构客户，提供 slashing 保险，响应时间未公开。[](https://liebrecapital.com.ar/bitcoin-rpc/)

## 10. NodeReal
- **官网**: [https://nodereal.io](https://nodereal.io)
- **订阅费用**:
  - **免费计划**: 3个API密钥，1亿计算单元/月，300计算单元/秒，$0。
  - **增长计划**: $39/月，15个API密钥，5亿计算单元/月，700计算单元/秒。
  - **团队计划**: $199/月，30个API密钥，20亿计算单元/月，1500计算单元/秒。
  - **商业计划**: $499/月，50个API密钥，50亿计算单元/月，3000计算单元/秒。
  - **企业计划**: 定制化，需联系NodeReal。
- **RPC服务差异**:
  - **支持链**: 29条链，包括BNB Chain、以太坊、Polygon、Aptos、Solana等。[](https://liebrecapital.com.ar/bitcoin-rpc/)
  - **特殊功能**: 支持HTTPS和WebSocket，平均响应时间99ms，98% API uptime，每日处理10亿+请求。
  - **请求限制**: 最高3000计算单元/秒（约3000请求/秒，视方法）。
  - **其他**: 专注于亚洲市场，BNB Chain生态表现突出。[](https://www.coingecko.com/learn/crypto-rpc-best-rpc-providers)

## 注意事项
- **定价动态性**: 供应商的定价可能因市场变化或代币价格波动（如Pocket Network的POKT）而调整。建议访问官网确认最新费用。
- **服务差异总结**:
  - **链支持**: GetBlock（50+）、Blockdaemon（50+）、QuickNode（66）支持最多链；Infura（10+）较少但专注以太坊生态。
  - **性能**: QuickNode响应时间最快（86ms），Chainstack在欧洲（78ms）表现优异。[](https://blog.quicknode.com/justifying-quick-in-quicknode-response-time-comparison-of-various-blockchain-node-providers/)
  - **去中心化**: Pocket Network和Ankr强调去中心化，Pocket Network通过DAO治理，Ankr通过独立节点提供者。
  - **开发者工具**: Alchemy和Moralis提供丰富开发工具（如NFT API、监控仪表板），适合快速开发；Infura和QuickNode注重性能和稳定性。
  - **企业级支持**: Blockdaemon和NodeReal面向机构客户，强调安全性和合规性。
- **获取最新信息**: 由于部分供应商（如Blockdaemon）未公开详细定价，需直接联系其销售团队。社区提供的免费节点（如以太坊公开端点）适合低负载场景，但可能不稳定。[](https://www.coingecko.com/learn/crypto-rpc-best-rpc-providers)

## 建议
- 根据项目需求选择供应商：
  - **初学者/测试**: Ankr、GetBlock、Moralis的免费计划配额较高。
  - **高性能DApp**: QuickNode、Alchemy、NodeReal提供低延迟和高请求限制。
  - **去中心化优先**: Pocket Network适合抗审查需求。
  - **企业级**: Blockdaemon和Infura提供高安全性和SLA。
- 访问官网（如[Ankr](https://www.ankr.com)、[Infura](https://www.infura.io)）或联系支持团队获取最新定价和定制方案。
- 若需特定链（如以太坊、Solana）或功能的深入对比，请提供更多细节，我可进一步分析！
