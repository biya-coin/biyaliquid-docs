# 代币工厂

TokenFactory 代币是原生集成到 Cosmos SDK 银行模块中的代币。它们的名称采用 `factory/{creatorAddress}/{subdenom}` 格式。因为代币按创建者地址命名空间化，这使得代币铸造无需许可，因为不需要解决名称冲突。

这种集成提供了跟踪和查询所有资产总供应量的支持，与 CW20 标准不同，后者需要直接查询智能合约。因此，建议使用 TokenFactory 标准。例如，Helix 或 Mito 等产品构建在 Biyachain 交易所模块上，该模块专门使用银行代币。TokenFactory 代币可以通过 biyachaind CLI 以及智能合约创建。通过 Wormhole 桥接到 Biyachain 的代币也是 TokenFactory 代币。

要了解有关在 Biyachain 上创建代币的更多信息，请参阅[代币发行](../../developers-defi/token-launch.md)。
要阅读有关 TokenFactory 标准的更多信息，请参阅[代币工厂模块](../../developers-native/biyachain/tokenfactory/)。
