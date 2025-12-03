# OCR

## 摘要

OCR 模块用于将 Chainlink 的 OCR（Off-Chain Report，链下报告）信息存储到链上存储。

Feed 配置由模块管理员管理，报告由传输者（Transmitters）和观察者（Observers）提交至链上。传输者和观察者在由治理配置的链上以 LINK 代币获得奖励。

在存储 Feed 信息时，模块提供钩子，供 Oracle 模块用于计算期货市场的累积价格。

## 目录

1. [概念](gai-nian.md)
2. [状态](zhuang-tai.md)
3. [消息](xiao-xi.md)
4. [提案](ti-an.md)
5. [**Begin-Block**](beginblock.md)
6. [钩子(Hooks)](gou-zi-hooks.md)
7. [事件](shi-jian.md)
8. [参数](can-shu.md)
