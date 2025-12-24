# 发行市场

{% hint style="info" %}
发行市场的前提条件是[发行代币](token-launch.md "mention")
{% endhint %}

在 Biya Chain 上发行交易对快速、简单，最重要的是无需许可！

以下教程假设该交易对以从以太坊桥接的 ERC-20 代币作为基础资产，与 BIYA 作为报价资产配对。

对于 Biya Chain 原生代币，跳过桥接部分，直接进入第 6 步。

1. 导航到 [Biya Chain Bridge](http://bridge.biyachain.network/) 开始使用 Peggy 桥将您选择的 ERC-20 代币从以太坊桥接到 Biya Chain 的过程。

![Biya Chain Bridge](<../../.gitbook/assets/Docs - Deposit Peggy.png>)

2. 点击下拉菜单，滚动到底部，点击高级工具旁边的"添加"，使用代币地址添加自定义 ERC-20 代币，您可能需要在 CoinGecko 等可信来源上验证该地址。

![添加自定义 ERC-20 代币](<../../.gitbook/assets/Docs - Deposit From.png>)

3. 复制并粘贴正确的合约地址，然后点击"添加"。

![添加智能合约地址](<../../.gitbook/assets/Docs - Add and Bridge ERC20.png>)

4. 现在输入您希望桥接的 ERC-20 代币的所需数量，点击"批准"，确认交易，然后点击"审查"，确认交易并等待。

![Launch trading Pair](https://docs.biyachain.network/assets/images/ltp4-f8f97c3328c04389962ac3deb9b137a9.png) ![Launch trading Pair](https://docs.biyachain.network/assets/images/ltp6-7812b6fe19b088c68b8d2a9bda8df05c.png) ![Launch trading Pair](https://docs.biyachain.network/assets/images/ltp7-d83a52c9fc794a2934ea8f2a5371595a.png) ![Launch trading Pair](https://docs.biyachain.network/assets/images/ltp8-da76aaaa5ee9f233ea47bbcb1f5b53bf.png)

5. 一旦批准支出和存款交易在以太坊区块链上得到确认，您将看到桥接交易的进度。一旦交易在 Biya Chain 上得到确认，您桥接的 ERC-20 代币将在您的 Biya Chain 钱包中可用。（注意，如果您在源链上使用 MetaMask，默认情况下，您桥接的代币将发送到与您的 MetaMask 关联的 biya 地址。这可以通过在第 4 步开始时点击接收者地址旁边的锁定图标来更改。）

![桥接完成](<../../.gitbook/assets/Docs - Transaction Submitted.png>)

6. 桥接交易完成后，您可以通过导航到 [Biya Chain Hub](https://prv.hub.biya.io/proposal/create/) 在 Biya Chain 上无需许可地列出代币。

![在 Biya Chain 上列出](<../../.gitbook/assets/Docs - New Proposal.png>)

7. 从第一个下拉菜单中选择"即时现货市场发行"，并指定一个代码。在此示例中，让我们使用 PEPE/BIYA。现在从下拉菜单中选择基础代币。但是，请注意，同一代码下可能存在多个代币。始终匹配正确的代币地址。在这种情况下，由于代币是使用 Peggy 桥桥接的，地址将是 peggy 后跟 ERC-20 合约地址。

![指定代码](<../../.gitbook/assets/Docs - Select Ticker.png>)

8. 现在选择正确的报价面额，在本例中为 biya。（注意，如果您希望将代币与 USDT 配对，请确保选择"正确的" USDT 地址，即 peggy 后跟 USDT 的 ERC-20 合约地址。）最后，指定最小价格变动单位和最小数量变动单位。因为 PEPE/BIYA 的交易价格只是一分钱的一小部分，所以相应地设置了最小变动单位。

![选择报价面额](<../../.gitbook/assets/Docs - Quote Denom.png>)
