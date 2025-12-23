# 钱包连接

Biya Chain 支持以太坊和 Cosmos 原生钱包。您可以使用 Metamask、Ledger、Keplr、Leap 等流行钱包在 Biya Chain 上签署交易。

### 钱包策略

推荐的开箱即用支持所有这些钱包的方法是使用我们构建的 [WalletStrategy](strategy.md) 抽象。这种方法将使您的 dApp 用户能够连接并与不同的钱包交互。

将其与 [MsgBroadcaster](../transactions/msgbroadcaster.md) 抽象结合使用，允许您使用一个函数调用签署交易。这就是 Helix、Hub、Explorer 等所有产品正在使用的方法，我们强烈建议在您的 dApp 中使用这种方法。

如果您仍然想原生使用某个钱包（不使用 WalletStrategy 类），我们将在本文档中提供如何通过 Metamask 和 Keplr 连接到基于 Biya Chain 构建的 dApp 的示例。

### Metamask

Metamask 是一个以太坊原生钱包，可用于连接并与您在 Biya Chain 上构建的 dApp 交互。

* **从 Metamask 获取 Biya Chain 地址**

<pre class="language-typescript"><code class="lang-typescript"><strong>
</strong><strong>import { getBiyachainAddress } from '@biya-coin/sdk-ts'
</strong>
<strong>const getEthereum = () => {
</strong>  if (!window.ethereum) {
    throw new Error('未安装 Metamask 扩展')
  }
  
  return window.ethereum
}
<strong>
</strong><strong>const ethereum = getEthereum()
</strong><strong>const addresses = await ethereum.request({
</strong>  method: 'eth_requestAccounts',
}) /** 这些是 evm 地址 */

const biyachainAddresses = addresses.map(getBiyachainAddress)
console.log(biyachainAddresses)
</code></pre>

* **使用 Metamask 签署交易**

有关如何在 Biya Chain 上使用 Metamask 准备 + 签署 + 广播交易的示例，请参见[此处](../transactions/ethereum.md)。

### Keplr

Keplr 是一个 Cosmos 原生钱包，可用于连接并与您在 Biya Chain 上构建的 dApp 交互。

* **从 Keplr 获取 Biya Chain 地址**

<pre class="language-typescript"><code class="lang-typescript"><strong>
</strong><strong>import { getBiyachainAddress } from '@biya-coin/sdk-ts'
</strong><strong>import { ChainId } from '@biya-coin/ts-types'
</strong>
<strong>const getKeplr = () => {
</strong>  if (!window.keplr) {
    throw new Error('未安装 Keplr 扩展')
  }
  
  return window.keplr
}
<strong>
</strong><strong>(async() => {
</strong>  const keplr = getKeplr()
<strong>  const chainId = ChainId.Mainnet
</strong><strong>  await keplr.enable(chainId)
</strong><strong>  const biyachainAddresses = await keplr.getOfflineSigner(chainId).getAccounts()
</strong><strong>
</strong><strong>  console.log(biyachainAddresses)
</strong>})()
</code></pre>

* **使用 Keplr 签署交易**

有关如何在 Biya Chain 上使用 Keplr 准备 + 签署 + 广播交易的示例，请参见 [Cosmos 交易](../transactions/cosmos.md)。
