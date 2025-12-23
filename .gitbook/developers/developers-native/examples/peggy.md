# Peggy

`peggy` 模块是 biyachain <> 以太坊桥的核心，存入的资金将被锁定在以太坊 [peggy 合约](https://etherscan.io/address/0xF955C57f9EA9Dc8781965FEaE0b6A2acE2BAD6f3#code)上并在 Biya Chain 链上铸造。同样，提取资金将在 biyachain 链上销毁并在以太坊 peggy 合约上解锁。

## 消息

### MsgSendToEth

此消息用于通过 [peggy 合约](https://etherscan.io/address/0xF955C57f9EA9Dc8781965FEaE0b6A2acE2BAD6f3#code)从 Biya Chain 链提取资金，在此过程中，资金将在 biyachain 链上销毁，并从 peggy 合约分发到以太坊地址。

请注意，此交易将收取 10 美元的桥接费用，以支付以太坊 gas 费用，这是在标准 BIYA 交易费用之上的。

```ts
import { ChainId } from '@biya-coin/ts-types'
import { toBigNumber, toChainFormat } from '@biya-coin/utils'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { TokenPrice, MsgSendToEth, TokenStaticFactory, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
// 参考 https://github.com/biya-coin/biyachain-lists
import { tokens } from '../data/tokens.json'

export const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[])

const tokenPriceMap = new TokenPrice(Network.Mainnet)
const tokenService = new TokenService({
  chainId: ChainId.Mainnet,
  network: Network.Mainnet,
})

const ETH_BRIDGE_FEE_IN_USD = 10
const endpointsForNetwork = getNetworkEndpoints(Network.Mainnet)

const tokenSymbol = 'BIYA'
const tokenMeta = tokenStaticFactory.toToken(tokenSymbol)

const amount = 1
const biyachainAddress = 'biya1...'
const destinationAddress = '0x...' // 以太坊地址
const tokenDenom = `peggy${tokenMeta.erc20.address}`

if (!tokenMeta) {
  return
}

const tokenUsdPrice = tokenPriceMap[tokenMeta.coinGeckoId]
const amountToFixed = toChainFormat(amount, tokenMeta.decimals).toFixed()
const bridgeFeeInToken = toBigNumber(ETH_BRIDGE_FEE_IN_USD).dividedBy(tokenUsdPrice).toFixed()

const msg = MsgSendToEth.fromJSON({
  biyachainAddress,
  address: destinationAddress,
  amount: {
    denom: tokenDenom,
    amount: amountToFixed,
  },
  bridgeFee: {
    denom: tokenDenom,
    amount: bridgeFeeInToken,
  },
})

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet,
}).broadcast({
  msgs: msg,
})
```
