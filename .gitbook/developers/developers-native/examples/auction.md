# Auction

`auction` 模块是链上`回购和销毁`机制的核心，每周收集 60% 的交易费用并拍卖给出价最高的 BIYA 竞标者，出价最高的竞标者提交的 BIYA 将在此过程中被销毁。

## MsgBid

此消息用于对每周举行的[拍卖](https://hub.biyachain.network/auction/)提交出价，允许成员使用 BIYA 竞标该周 Biya Chain 收集的交易费用篮子（60%）。

```ts
import {
  MsgBid,
  ChainGrpcAuctionApi,
  MsgBroadcasterWithPk,
} from '@biya-coin/sdk-ts'
import { ChainId } from '@biya-coin/ts-types'
import { toChainFormat } from '@biya-coin/utils'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpointsForNetwork = getNetworkEndpoints(Network.Mainnet)
const auctionApi = new ChainGrpcAuctionApi(endpointsForNetwork.grpc)

const biyachainAddress = 'biya1...'
/* 格式化出价金额，注意出价金额必须高于当前最高出价 */
const amount = {
  denom: 'biya',
  amount: toChainForma(1).toFixed(),
}

const latestAuctionModuleState = await auctionApi.fetchModuleState()
const latestRound = latestAuctionModuleState.auctionRound

/* 以 proto 格式创建消息 */
const msg = MsgBid.fromJSON({
  amount,
  biyachainAddress,
  round: latestRound,
})

const privateKey = '0x...'

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  network: Network.Mainnet,
  privateKey,
}).broadcast({
  msgs: msg,
})

console.log(txHash)
```

## 通过 MsgExternalTransfer 销毁拍卖存款

如果您想增加销毁拍卖的池规模，您可以直接将资金发送到拍卖子账户。

注意事项：

- 您需要将资金发送到池的子账户 `0x1111111111111111111111111111111111111111111111111111111111111111`。
- 请注意，您发送的任何资金都将反映在下一次拍卖中，而不是当前拍卖中。
- 您不能从默认的 subaccountId 转账，因为该余额现在与 bank 模块中的 Biya Chain 地址相关联。因此，为了使 `MsgExternalTransfer` 工作，您需要从非默认的 subaccountId 转账。

如何找到您将要转账的 subaccountId：

- 您可以通过[账户投资组合 api](../query-indexer/portfolio.md) 查询您现有的 subaccountIds。

如何使用当前与 bank 模块中 Biya Chain 地址关联的资金：

- 如果您有现有的非默认子账户，您需要执行 [MsgDeposit](exchange.md#msgdeposit) 到您现有的非默认 subaccountIds 之一，并使用该 subaccountId 作为下面的 `srcSubaccountId`。
- 如果您没有现有的非默认子账户，您可以对新的默认 subaccountId 执行 [MsgDeposit](exchange.md#msgdeposit)，这将通过从 `sdk-ts` 导入 `getSubaccountId` 并将 [MsgDeposit](exchange.md#msgdeposit) 中的 `subaccountId` 字段设置为 `getSubaccountId(biyachainAddress, 1)` 来完成。

有关更多信息，请查看[销毁拍卖池文档](https://docs.biyachain.network/developers/modules/biyachain/auction)。

```ts
import {
  DenomClient,
  MsgExternalTransfer,
  MsgBroadcasterWithPk,
} from '@biya-coin/sdk-ts'
import { toChainFormat } from '@biya-coin/utils'
import { Network } from '@biya-coin/networks'

const denomClient = new DenomClient(Network.Mainnet)

const biyachainAddress = 'biya1...'
const srcSubaccountId = '0x...'
const POOL_SUBACCOUNT_ID = `0x1111111111111111111111111111111111111111111111111111111111111111`
const USDT_TOKEN_SYMBOL = 'USDT'
const tokenMeta = denomClient.getTokenMetaDataBySymbol(USDT_TOKEN_SYMBOL)
const tokenDenom = `peggy${tokenMeta.erc20.address}`

/* 格式化要添加到销毁拍卖池的金额 */
const amount = {
  denom: tokenDenom,
  amount: toChainFormat(1, tokenMeta.decimals).toFixed(),
}

/* 以 proto 格式创建消息 */
const msg = MsgExternalTransfer.fromJSON({
  amount,
  srcSubaccountId,
  biyachainAddress,
  dstSubaccountId: POOL_SUBACCOUNT_ID,
})

const privateKey = '0x...'

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  network: Network.Mainnet,
  privateKey,
}).broadcast({
  msgs: msg,
})

console.log(txHash)
```
