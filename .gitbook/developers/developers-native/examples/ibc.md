# IBC

## 消息

## MsgTransfer

此消息用于通过 IBC（Cosmos 的区块链间通信协议）将代币从发送者在 Biya Chain 上的 Bank 模块发送到接收者在另一个 Cosmos 链上的 Bank 模块。请注意，对于大多数网络，Biya Chain 仅支持通过 IBC 进行主网转账。

IBC 中的应用程序到应用程序通信通过通道进行，这些通道在一条链上的应用程序模块与另一条链上的相应应用程序模块之间路由。有关 IBC 通道的更多信息，请访问 https://tutorials.cosmos.network/academy/3-ibc/3-channels.html。可以在[此处](https://github.com/biya-coin/biyachain-ts/blob/master/deprecated/token-metadata/src/ibc/canonicalChannelsToChainMap.ts)找到用于与 Biya Chain 之间进行主网转账的规范通道 ID 列表。还值得注意的是，每条链上的应用程序模块都有一个 portId 来指定每端的模块类型。例如，`transfer` 是指定 bank 模块之间 ICS-20 代币转移的 portId。

在此示例中，我们将 ATOM 从 Biya Chain 转移到 CosmosHub

```ts
import {
  TokenService,
  UiBankTransformer,
  cosmosChainTokenMetaMap,
} from "@biya-coin/sdk-ui-ts";
import {
  MsgTransfer,
  ChainGrpcBankApi,
  MsgBroadcasterWithPk,
  ChainRestTendermintApi,
  makeTimeoutTimestampInNs,
} from "@biya-coin/sdk-ts";
import { toChainFormat, toBigNumber } from "@biya-coin/utils";
import { ChainId, CosmosChainId } from "@biya-coin/ts-types";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
import { IbcToken, Token } from "@biya-coin/token-metadata";

const tokenService = new TokenService({
  chainId: ChainId.Mainnet,
  network: Network.Mainnet,
});

const destinationChainId = CosmosChainId["Cosmoshub"];
const biyachainChainId = CosmosChainId["Biya Chain"];

const endpointsForNetwork = getNetworkEndpoints(Network.Mainnet);
const bankService = new ChainGrpcBankApi(endpointsForNetwork.grpc);

// 获取 bank 模块中的 ibc 资产并格式化为代币
const { supply } = await bankService.fetchTotalSupply();
const uiSupply = UiBankTransformer.supplyToUiSupply(supply);
const ibcSupplyWithToken = (await tokenService.getIbcSupplyWithToken(
  uiSupply.ibcBankSupply
)) as IbcToken[];

/* 获取可在链之间转移的规范面值的元数据 */
const cosmosHubBaseDenom = "uatom";
const tokenMeta = cosmosChainTokenMetaMap[destinationChainId];
const atomToken = (
  Array.isArray(tokenMeta)
    ? tokenMeta.find((token) => token.denom === cosmosHubBaseDenom)
    : tokenMeta
) as Token;

/* 查找规范面值的 ibd 面值哈希 */
const biyachainToCosmosHubChannelId = "channel-1";
const atomDenomFromSupply = ibcSupplyWithToken.find(
  ({ channelId, baseDenom }) =>
    channelId === biyachainToCosmosHubChannelId && baseDenom === atomToken.denom
) as IbcToken;
const canonicalDenomHash = atomDenomFromSupply.denom;

/* 格式化转账金额 */
const amount = {
  denom: canonicalDenomHash,
  amount: toChainFormat(0.001, atomDenomFromSupply.decimals).toFixed(),
};

const biyachainAddress = "biya...";
const destinationAddress = "cosmos...";
const port = "transfer";
const timeoutTimestamp = makeTimeoutTimestampInNs();

/* 从源链获取最新区块 */
const tendermintRestApi = new ChainRestTendermintApi(endpointsForNetwork.rest);

/* 来自源链的区块详情 */
const latestBlock = await tendermintRestApi.fetchLatestBlock();
const latestHeight = latestBlock.header.height;
const timeoutHeight = toBigNumber(latestHeight).plus(
  30 // 默认区块超时高度
);

/* 以 proto 格式创建消息 */
const msg = MsgTransfer.fromJSON({
  port,
  memo: `从 ${biyachainChainId} 到 ${destinationChainId} 的 IBC 转账`,
  sender: biyachainAddress,
  receiver: destinationAddress,
  channelId: biyachainToCosmosHubChannelId,
  timeout: timeoutTimestamp,
  height: {
    revisionHeight: timeoutHeight.toNumber(),
    revisionNumber: parseInt(latestBlock.header.version.block, 10),
  },
  amount,
});

const privateKey = "0x...";

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
