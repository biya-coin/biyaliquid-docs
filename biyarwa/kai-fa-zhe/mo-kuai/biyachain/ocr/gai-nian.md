# 概念

OCR 模块用于由验证成员将 Chainlink 的 OCR（Off-Chain Report）信息存储到链上。

链下报告由 N 个节点（Oracles）组成，这些节点从外部来源收集数据。报告在 Oracles 之间以 P2P 方式交换，以获取签名批准。OCR 模块在链上识别一部分节点（Transmitters），这些节点必须将报告提交至模块，第一个成功提交至链上的 Transmitter 可额外获得奖励以覆盖 Gas 费用，其他 Transmitters 不会获得额外奖励。所有参与该轮的 Oracles 都会获得报酬。OCR 模块存储报告中的中位值。

## OCR 术语

协议定期将 Oracle 报告发送到 OCR 模块。报告协议由三个组件组成：Pacemaker、报告生成和传输。

**Pacemaker**\
Pacemaker 驱动报告生成过程，该过程以纪元（Epoch）为单位进行。每个纪元都有一个指定的领导者，Pacemaker 会将启动报告生成协议的任务交给该领导者。如果领导者未能及时生成有效报告，Pacemaker 会中止当前的报告生成并启动一个新的纪元。

**报告生成**\
在给定的纪元中，报告生成协议进入多个回合，在这些回合中收集观测数据，并在满足条件（如心跳和偏差）时生成已签名的 Oracle 报告。回合由领导节点控制，领导节点控制回合的频率，收集观测数据并生成报告。

**传输**\
传输协议随后将生成的报告传输到 OCR 模块。

## 链下 OCR 集成

* 提供与 Biyachain 进行通信的手段，使用 sdk-go。
* 从模块中读取数据，例如已批准的 Oracle 列表。
* 将报告提交为 Msg（实现 ContractTransmitter）。
* 实现 OffchainConfigDigester。
* 实现 OnchainKeyring，用于生成将在目标链模块上有效的签名。
* 实现 ContractConfigTracker，用于跟踪链模块配置的变化（政府批准）。

**备注**：

* 报告按 Epoch-Round 格式进行时间戳标记。
* OCR 模块验证报告中 Oracle 的签名。
* OCR 模块记录对报告做出贡献的 Oracles，以便进行支付。
* OCR 模块存储观测数据的中位值。
* OCR 模块为第一个提交 Msg 的用户提供额外奖励。

### 集成概览

Chainlink 有多个[价格数据 Feed](https://data.chain.link/ethereum/mainnet/stablecoins)，包括：

* 80 个加密货币/USD 配对（例如 ETH/USD、BTC/USD）
* 17 个稳定币配对（例如 USDT/USD、USDC/USD）
* 73 个 ETH 配对（例如 LINK/ETH）
* 17 个外汇配对（例如 GBP/USD、CNY/USD）

在 Biyachain 上的衍生品市场指定了以下 Oracle 参数：

* `oracleBase`（例如 BTC）
* `oracleQuote`（例如 USDT）
* `oracleType`（例如 Chainlink）

因此，对于 Biyachain 上的 BTC/USDT 衍生品市场，`oracleBase` 将是 BTC/USD，`oracleQuote` 将是 USDT/USD，`oracleType` 将是 Chainlink。市场价格将通过将 BTC/USD 价格除以 USDT/USD 价格来获得，从而得出 BTC/USDT 价格。
