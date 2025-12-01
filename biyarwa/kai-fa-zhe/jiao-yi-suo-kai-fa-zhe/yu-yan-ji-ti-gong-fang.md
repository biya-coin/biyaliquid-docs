# 预言机提供方

{% hint style="info" %}
前置阅读 [Biyachain Oracle 模块](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/modules/injective/oracle/~/overview)
{% endhint %}

本节旨在为用户提供指南，帮助他们在 Biyachain 上启动和维护预言机提供方（Oracle Provider）。这些预言机可用于多种用途，例如永续合约市场、到期期货市场、[二元期权市场](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/modules/injective/exchange/02_binary_options_markets/~/overview)等。

什么是预言机提供方？预言机提供方是一种预言机类型，允许外部参与者向 Biyachain 链传输价格数据。这些外部参与者被称为提供方（Providers）。提供方用于标识每个外部参与者，并且所有提供的价格数据都存储在该特定提供方名下。这一机制使 Biyachain 能够创建自定义价格数据，从而支持 Biyachain 上创新且高级的市场。

开发者需要首先在 Oracle Provider 类型下注册自己的提供方。这可以通过提交 `GrantProviderPrivilegeProposal` 治理提案来完成。一旦提案通过，提供方即被注册，随后可以向链上传输价格数据。可以在 CLI 环境中使用 `biyachaind` 命令行工具执行 (`grant-provider-privilege-proposal [providerName] [relayers] --title [title] --description [desc] [flags]`) 或者，也可以使用 Biyachain 提供的 SDK 之一来构造消息并将其广播至链上。

{% hint style="info" %}
您可以在 **Oracle 模块提案** 部分查看提交此提案的示例。
{% endhint %}

_Note:_ **GrantProviderPrivilegeProposal** 的 **relayers** 指定了被列入白名单的地址，这些地址将被授权向 Biyachain 提交价格数据。

一旦提案通过，**relayers** 便可使用 `MsgRelayProviderPrices` 在其 **Oracle Provider Type** 的 **provider namespace** 内，为指定的 **base/quote** 交易对提交价格数据。

可以通过 CLI 环境使用 `biyachaind` 进行操作：

```shell
biyachaind relay-provider-prices [providerName] [symbol:prices] [flags]
```

也可以使用 Biyachain 提供的 SDK 来构造消息并广播至链上。

最终，这些价格数据可用于创建 **衍生品市场（Derivative Markets）**。
