# WasmX

## 摘要

`wasmx` 模块处理 [CosmWasm](https://cosmwasm.com) 智能合约与 Biya Chain 链的集成。\
它的主要功能是提供一种方法，使合约可以在每个区块的 begin blocker 部分执行。\
如果合约耗尽 gas，可能会自动停用，但可以由合约所有者重新激活。

它还包括用于管理合约的辅助方法，例如批量代码存储提案。这些功能允许 CosmWasm 合约与 Biya Chain 链无缝集成，并提供用于管理和维护这些合约的有用工具。

## 目录

1. [概念](01_concepts.md)
2. [数据](02_data.md)
3. [治理提案](03_proposals.md)
4. [消息](04_messages.md)
5. [参数](05_params.md)
