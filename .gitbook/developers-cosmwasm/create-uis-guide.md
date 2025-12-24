# 创建用户界面

{% hint style="info" %}
有关创建 UI 以及引导选项的更全面文档可以在 [dApps 文档](../developers/dapps/README.md) 中找到。
{% endhint %}

我们已经通过 Biya Chain CLI 与我们的合约进行了交互,但这对大多数 dApp 用户来说并不理想。Web UI 可以提供更好的体验!我们可以抽象掉复杂性,而不是通过 `biyachaind` 发送交易消息,为用户提供两个按钮——一个用于增加计数,一个用于重置计数。

![](https://docs.biyachain.network/img/Counter_website.png)

例如,请参阅 [计数器网站](https://biyachain-simple-cosmwasm-sc.netlify.app/)。使用 Vue 和 [Biya Chain TS SDK](https://github.com/biya-coin/biyachain-ts/tree/master/packages/sdk-ts) 开发前端的高级指南可以在 [网站仓库这里](https://github.com/biya-coin/biyachain-simple-sc-counter-ui/tree/master/nuxt) 找到。有关 React 实现,请参阅 [这里](https://github.com/biya-coin/biyachain-simple-sc-counter-ui/tree/master/next)。

现在,与合约交互就像点击按钮并使用 MetaMask 签名一样简单(确保账户设置为 Ethereum Goerli Testnet,否则您将收到链 ID 不匹配错误)。

![](https://docs.biyachain.network/img/metamask_select_testnet.png)

{% hint style="info" %}
您可能会注意到,在尝试重置计数时会收到"未授权"错误消息。这是预期的行为!回想一下 [重置的合约逻辑](./smart-contracts/your-first-smart-contract.md#reset),只有合约所有者才被允许重置计数。由于您没有实例化前端正在交互的确切合约,因此您没有重置计数所需的权限。
{% endhint %}
