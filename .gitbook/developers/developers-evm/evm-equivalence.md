---
description: 了解 Biya Chain 上的 EVM 等价性
---

# EVM 等价性

## Biya Chain EVM vs. 以太坊主网

Biya Chain 的原生 EVM 是一个完全嵌入的执行环境，已集成到链的核心架构中。它在开发体验方面被设计为与以太坊 1:1 等效。

Biya Chain 上的原生 EVM 支持最新版本的 `geth`，确保开发者能够访问最新的功能、工具、安全补丁和改进。此外，Biya Chain 的 EVM 增强了性能并扩展了能力，授予访问 Biya Chain 复杂的金融基础设施的权限，这超越了以太坊上可用的功能。

## 交易的 Gas 费用估算

<table data-full-width="false"><thead><tr><th width="131"> </th><th width="162">Gas 价格范围</th><th width="121">代币价格</th><th width="234">创建 ERC-4337 账户</th><th width="157">简单转账</th><th>ERC-20 转账</th></tr></thead><tbody><tr><td>Ethereum¹</td><td>30.5 ± 10.6 gwei</td><td>$3000</td><td>$35.25 ± $12.25</td><td>$1.9215 ± $0.6678</td><td>$5.9475 ± $2.067</td></tr><tr><td>Polygon²</td><td>224 ± 108 gwei</td><td>$0.4</td><td>$0.0345 ± $0.0166</td><td>$0.0018 ± $0.0009</td><td>$0.0058 ± $0.0028</td></tr><tr><td>Optimism³</td><td>0.30 ± 0.15 gwei</td><td>$3000</td><td>$0.3467 ± $0.1733</td><td>$0.0189 ± $0.0094</td><td>$0.0585 ± $0.0292</td></tr><tr><td><p>Avalanche⁴</p><p><br></p></td><td>36.4 ± 4.5 nAVAX</td><td>$28</td><td>$0.3926 ± $0.0485</td><td>$0.0214 ± $0.0026</td><td>$0.0662 ± $0.0081</td></tr><tr><td>BnB Smart Chain⁵</td><td>7.05 ± 0.53 gwei</td><td>$600</td><td>$1.6296 ± $0.1225</td><td>$0.0888 ± $0.0066</td><td>$0.2749 ± $0.0206</td></tr><tr><td>Sei⁶</td><td>0.02 usei</td><td>$0.40</td><td>$0.0030</td><td>$0.00017</td><td>$0.0005</td></tr><tr><td><strong>Biya Chain⁷</strong></td><td><strong>0.16 nBIYA</strong></td><td><strong>$23</strong></td><td><strong>$0.0014</strong></td><td><strong>$0.00008</strong></td><td><strong>$0.0002</strong></td></tr></tbody></table>

### 注意：每个操作的 Gas <a href="#note-gas-per-action" id="note-gas-per-action"></a>

* 创建 ERC-4337 账户: `385266`
* 简单转账: `21000`
* ERC-20 代币转账: `65000`

### Gas 价格来源

1. [Ethereum Gas 价格来源](https://etherscan.io/chart/gasprice) ↩︎
2. [Polygon Gas 价格来源](https://polygonscan.com/chart/gasprice) ↩︎
3. [Optimism Gas 价格来源](https://optimistic.etherscan.io/chart/gasprice) ↩︎
4. [Avalanche Gas 价格来源](https://snowtrace.io/insight/leaderboard/gas-tracker) ↩︎
5. [BnB Smart Chain Gas 价格来源](https://bscscan.com/chart/gasprice) ↩︎
6. [Sei Gas 价格配置](https://github.com/sei-protocol/chain-registry/blob/main/gas.json) ↩︎
7. [Biya Chain 推出 Gas 压缩](https://biyachain.com/blog/biyachain-unveils-fee-reductions-with-gas-compression/) ↩︎

## EIP-1559 配置

即将推出。

