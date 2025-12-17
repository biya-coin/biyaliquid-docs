# `Insurance`

## 概述

本文档规定了 Biya Chain 的保险模块。

该模块为 Biya Chain 的 `exchange` 模块中的衍生品市场提供保险基金，以支持更高杠杆的交易。从高层次来看，每个衍生品市场的保险基金由一组无需许可的承保人提供资金，每个承保人拥有保险基金中基础资产的按比例索赔权（通过保险基金份额代币表示）。

当相应衍生品市场中的持仓以正权益清算时，每个保险基金都会增长，因为清算时正权益的一半会发送到保险基金。当负权益的持仓被清算时（即持仓已超过破产），保险基金被用来弥补缺失的权益。

## 目录

1. [State](01_state.md)
2. [State Transitions](02_state_transitions.md)
3. [Messages](03_messages.md)
4. [End Block](04_end_block.md)
5. [Events](05_events.md)
6. [Params](06_params.md)
7. [Future Improvements](07_future_improvements.md)
