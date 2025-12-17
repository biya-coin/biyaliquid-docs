# Exchange

## 概述

`exchange` 模块是 Biya Chain 的核心模块，实现了完全去中心化的现货和衍生品交易。\
它是链上不可或缺的模块，与 `auction`、`insurance`、`oracle` 和 `peggy` 模块紧密集成。

交易所协议使交易者能够在任意现货和衍生品市场上创建和交易。\
订单簿管理、交易执行、订单匹配和结算的整个过程都通过 exchange 模块编码的逻辑在链上完成。

`exchange` 模块支持两种类型的市场进行代币交换：

1. `衍生品市场`：`永续合约市场` 或 `期货市场`。
2. `现货市场`

## 目录

1. [衍生品市场概念](00_derivative_market_concepts.md)
2. [现货市场概念](01_spot_market_concepts.md)
3. [其他概念](02_other_concepts.md)
4. [状态](03_state.md)
5. [状态转换](04_state_transitions.md)
6. [消息](05_messages.md)
7. [治理提案](06_proposals.md)
8. [区块开始](07_begin_block.md)
9. [区块结束](08_end_block.md)
10. [事件](09_events.md)
11. [参数](10_params.md)
12. [MsgPrivilegedExecuteContract](11_msg_privileged_execute_contract.md)
