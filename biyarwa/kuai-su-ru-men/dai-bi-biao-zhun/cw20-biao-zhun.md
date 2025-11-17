# CW20 标准

CW20 代币标准提供了一个框架，用于无权限创建和管理可替代代币，其结构更接近于[ ERC20 标准](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)。如上所述，推荐使用 TokenFactory 标准，因为它与 Cosmos SDK 原生集成，但如果您出于某种原因希望使用 CW20 标准，您可以通过 [CW20 适配器](https://github.com/CosmWasm/cw-plus/blob/main/packages/cw20/README.md)将 CW20 代币转换为 TokenFactory 代币，反之亦然。有关 CW20 标准的更多信息，请参阅其正式规范 [这里](https://github.com/CosmWasm/cw-plus/blob/main/contracts/cw20/spec.md)。
