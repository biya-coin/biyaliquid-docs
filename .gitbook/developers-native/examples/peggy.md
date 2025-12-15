# Peggy

The `peggy` module is the heart of the biyachain <> ethereum bridge, where deposited funds will be locked on the ethereum [peggy contract](https://etherscan.io/address/0xF955C57f9EA9Dc8781965FEaE0b6A2acE2BAD6f3#code) and minted on the Biyachain chain. Similarly withdrawal funds will be burned on the biyachain chain and unlocked on the ethereum peggy contract.

## Messages

### MsgSendToEth

This message is used to withdraw funds from the Biyachain Chain via the [peggy contract](https://etherscan.io/address/0xF955C57f9EA9Dc8781965FEaE0b6A2acE2BAD6f3#code), in the process funds will be burned on the biyachain chain and distributed to the ethereum address from the peggy contract.

Note that a $10 USD bridge fee will be charged for this transaction to cover for the ethereum gas fee on top of the standard BIYA transaction fee.

```ts
import { ChainId } from '@biya-coin/ts-types'
import { toBigNumber, toChainFormat } from '@biya-coin/utils'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { TokenPrice, MsgSendToEth, TokenStaticFactory, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
// refer to https://github.com/biya-coin/biyachain-lists
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
const destinationAddress = '0x...' // ethereum address
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
