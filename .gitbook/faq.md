# FAQ

## 基础设施

问: 在维护私有节点时:

* 我们应该存储 2.5 Ti 的归档数据(事件提供者)吗?
* 我们可以跳过该部分并使索引器工作吗?

答: 事件提供者可以被修剪。可以使用公共事件提供者端点进行初始同步。然后使用本地部署,但仅从最新高度开始。因此,是的,可以跳过。

***

## EVM

问: Biya Chain 是否部署了 [`multicall3`](https://www.multicall3.com/) 智能合约?

答: 是的。

* Biya Chain 主网 `multicall3`: [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11?tab=contract)
* Biya Chain 测试网 `multicall3`: [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://testnet.blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11?tab=contract)

***
