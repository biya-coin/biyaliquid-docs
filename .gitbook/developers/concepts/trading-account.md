# 交易账户

子账户或交易账户是一个概念，允许您将原生 Biya Chain 银行模块中的资金（可用于质押、拍卖竞标、参与治理、创建市场等）分离到一个隔离的交易账户中，您可以从该账户执行交易。一个 Biya Chain 地址可以拥有无限数量的交易账户。它们的表示方式是 `${ethereumAddress}${subaccountNonce}`，其中 `ethereumAddress` 是 `bech32` Biya Chain 地址的 `hex` 版本，`subaccountNonce` 是以 12 字节表示的 nonce。nonce 为 1 的交易账户示例为 `0xc7dca7c15c364865f77a4fb67ab11dc95502e6fe000000000000000000000001`。

从 v1.10.0 链升级开始，银行余额和默认交易账户（nonce = 0）将合并，当执行源自默认交易账户的交易时，将直接使用银行资金。
