# 创建 UIs

{% hint style="info" %}
关于创建用户界面以及引导选项的更全面文档可以在[ TypeScript 文档](https://docs.ts.injective.network/building-dapps/dapps-examples)中找到。
{% endhint %}

我们通过 Biyachain CLI 与合约进行了交互，但对于大多数 dApp 用户来说，这并不是理想的方式。一个 Web UI 可以提供更好的体验！我们可以抽象掉复杂性，提供两个按钮—一个用于增加计数，一个用于重置计数，而不是通过 biyachaind 发送交易消息。

![](https://docs.injective.network/img/Counter_website.png)

例如，请查看[计数器网站](https://injective-simple-cosmwasm-sc.netlify.app/)。关于使用 Vue 和 [Biyachain TS SDK](https://github.com/InjectiveLabs/injective-ts/tree/master/packages/sdk-ts) 开发前端的高级指南可以在该网站的[仓库](https://github.com/InjectiveLabs/injective-simple-sc-counter-ui/tree/master/nuxt)中找到。对于 React 实现，请查看[这里](https://github.com/InjectiveLabs/injective-simple-sc-counter-ui/tree/master/next)。\
现在，与合约的交互变得和点击按钮、使用 MetaMask 签名一样简单（确保账户设置为 Ethereum Goerli Testnet，否则会收到链 ID 不匹配的错误）。

![](https://docs.injective.network/img/metamask_select_testnet.png)

{% hint style="info" %}
你可能会注意到，在尝试重置计数时，出现了“Unauthorized”（未经授权）错误消息。这是预期的行为！回顾[合约逻辑](https://docs.injective.network/develop/guides/injective-101/your-first-contract#reset)，对于重置操作，只有合约拥有者才被允许重置计数。由于你没有实例化前端交互的确切合约，因此你没有重置计数所需的权限。
{% endhint %}
