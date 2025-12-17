---
sidebar_position: 1
title: 概念
---

# 概念

`ocr` 模块用于将由已验证成员提供的 Chainlink OCR 信息存储到链上。

链下报告由 N 个节点（预言机）组成，从外部数据源收集数据。报告在预言机之间以点对点（p2p）方式交换以获得批准签名。链上 `ocr` 模块识别出一个节点子集（传输者），它们必须将报告提交到模块，第一个到达链上的传输者会获得额外奖励以覆盖 gas 成本。其他传输者则不会获得。参与该轮次的所有预言机都会获得报酬。`ocr` 模块存储报告的中位数值。

## OCR 术语

协议定期向 OCR 模块发送**预言机报告**。报告协议由三个组件组成：**节奏器（pacemaker）**、**报告生成**和**传输**。

**节奏器（Pacemaker）**

节奏器驱动报告生成过程，该过程以**纪元（epochs）**结构组织。每个纪元都有一个指定的领导者，节奏器会指派该领导者启动报告生成协议。如果领导者没有及时生成有效报告，节奏器也会中止当前的报告生成并开始新的纪元。

**报告生成**

对于给定的纪元，报告生成协议进入**轮次（rounds）**，在此收集**观察值（observations）**，并在满足条件（如心跳和偏差）时生成签名的预言机**报告**。轮次由领导者节点控制，该节点控制轮次频率、收集观察值并生成报告。

**传输**

传输协议然后将生成的报告传输到 OCR 模块。

## 链下 OCR 集成

- 提供使用 sdk-go 与 Biya Chain 通信的方法
- 从模块读取数据，例如已批准的预言机列表
- 以消息（Msgs）形式提交报告（实现 `ContractTransmitter`）
- 实现 `OffchainConfigDigester`
- 实现 `OnchainKeyring` 以生成可在目标链模块上工作的签名
- 实现 `ContractConfigTracker` 以跟踪链模块配置的更改（治理批准）

注意事项：

- 报告以纪元-轮次（Epoch-Round）方式标记时间戳
- `ocr` 模块验证报告上预言机的签名
- `ocr` 模块记录对报告做出贡献的预言机，用于支付
- `ocr` 模块存储观察值的中位数
- `ocr` 模块为消息的第一个提交者提供额外奖励

### 集成概述

Chainlink 有多个[价格数据源](https://data.chain.link/ethereum/mainnet/stablecoins)，包括：

- 80 个加密货币/USD 交易对（例如 ETH/USD、BTC/USD）
- 17 个稳定币交易对（例如 USDT/USD、USDC/USD）
- 73 个 ETH 交易对（例如 LINK/ETH）
- 17 个外汇交易对（例如 GBP/USD、CNY/USD）

Biya Chain 上的衍生品市场指定以下预言机参数：

- oracleBase（例如 BTC）
- oracleQuote（例如 USDT）
- oracleType（例如 Chainlink）

因此，对于 Biya Chain 上的 BTC/USDT 衍生品市场，oracleBase 将是 BTC/USD，oracleQuote 将是 USDT/USD，oracleType 将是 Chainlink。然后通过将 BTC/USD 价格除以 USDT/USD 价格来获得市场价格，得到 BTC/USDT 价格。
