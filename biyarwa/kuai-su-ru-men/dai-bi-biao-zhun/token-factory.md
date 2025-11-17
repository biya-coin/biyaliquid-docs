# Token Factory

TokenFactory 代币是原生集成到 Cosmos SDK 的银行模块中的代币。它们的命名格式为 `factory/{creatorAddress}/{subdenom}`。由于代币是按创建者地址命名空间进行命名的，这使得代币铸造无需权限，因为不需要解决名称冲突。

这种集成提供了对所有资产总供应量的跟踪和查询支持，不像 CW20 标准那样需要直接查询智能合约。因此，推荐使用 TokenFactory 标准。例如，像 Helix 或 Mito 这样的产品是基于 Biyachain 交换模块构建的，它们专门使用银行代币。TokenFactory 代币可以通过 biyachaind CLI 或智能合约创建。通过 Wormhole 桥接到 Biyachain 的代币也是 TokenFactory 代币。

要了解更多关于在 Biyachain 上创建代币的信息，请查看[这里](../../zhi-nan/fa-bu-dai-bi.md)。要阅读更多关于 TokenFactory 标准的信息，请查看[这里](../../kai-fa-zhe/mo-kuai/biyachain/dai-bi-gong-chang-tokenfactory.md)。
