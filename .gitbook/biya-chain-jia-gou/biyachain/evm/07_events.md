<!--
order: 7
-->

# 事件

`x/evm` 模块在状态执行后发出 Cosmos SDK 事件。EVM 模块发出相关交易字段的事件，以及交易日志（以太坊事件）。

## MsgEthereumTx

| 类型        | 属性键      | 属性值         |
| ----------- | ------------------ | ----------------------- |
| ethereum_tx | `"amount"`         | `{amount}`              |
| ethereum_tx | `"recipient"`      | `{hex_address}`         |
| ethereum_tx | `"contract"`       | `{hex_address}`         |
| ethereum_tx | `"txHash"`         | `{tendermint_hex_hash}` |
| ethereum_tx | `"ethereumTxHash"` | `{hex_hash}`            |
| ethereum_tx | `"txIndex"`        | `{tx_index}`            |
| ethereum_tx | `"txGasUsed"`      | `{gas_used}`            |
| tx_log      | `"txLog"`          | `{tx_log}`              |
| message     | `"sender"`         | `{eth_address}`         |
| message     | `"action"`         | `"ethereum"`            |
| message     | `"module"`         | `"evm"`                 |

此外，EVM 模块在 `EndBlock` 期间为过滤查询区块布隆发出事件。

## ABCI

| 类型        | 属性键 | 属性值      |
| ----------- | ------------- | -------------------- |
| block_bloom | `"bloom"`     | `string(bloomBytes)` |
