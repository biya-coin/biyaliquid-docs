# 提供商预言机

{% hint style="info" %}
前提阅读 [Biya Chain 预言机模块](../../developers-native/biyachain/oracle/)
{% endhint %}

本节的目标是为用户提供有关如何在 Biya Chain 上启动和维护预言机提供商的指南。这些预言机可用于各种目的，如永续市场、到期期货市场、[二元期权市场](../../developers-native/biyachain/exchange/02_binary_options_markets.md)等。

首先，什么是预言机提供商？它是一种预言机**类型**，允许外部方将价格源中继到 Biya Chain 链。这些外部方称为提供商。提供商标识每个外部方，链上提供的所有价格源都存储在该特定提供商下。这允许在 Biya Chain 上创建自定义价格源，可以为在 Biya Chain 上启动的创意和高级市场提供支持。

开发者需要做的第一件事是在预言机提供商类型下注册他们的提供商。您可以通过提交 `GrantProviderPrivilegeProposal` 治理提案来实现。一旦提案通过，您的提供商将被注册，您就可以中继价格源。您可以在 CLI 环境中使用 `biyachaind`（`grant-provider-privilege-proposal [providerName] [relayers] --title [title] --description [desc] [flags]`）或使用我们的任何 SDK 创建消息并将其广播到链上。

{% hint style="info" %}
您可以在预言机模块提案部分看到如何提交此提案的示例
{% endhint %}

_注意：`GrantProviderPrivilegeProposal` 的 `relayers` 是将被列入白名单以向 Biya Chain 提交价格源的地址。_

提案通过后，`relayers` 可以使用 `MsgRelayProviderPrices` 在 Biya Chain 上的预言机提供商类型预言机的提供商命名空间内为基础/报价对提交价格。您可以在 CLI 环境中使用 `biyachaind`（`relay-provider-prices [providerName] [symbol:prices] [flags]`）或使用我们的任何 SDK 创建消息并将其广播到链上。

最后，您可以使用这些价格源创建您的衍生品市场。
