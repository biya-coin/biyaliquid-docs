---
sidebar_position: 4
title: Events
---

# 事件

拍卖模块发出以下事件：

## Handlers

### Msg/Bid

| 类型             | 属性键 | 属性值    |
| ---------------- | ------------- | ------------------ |
| EventBid | Bidder（出价者） |  |
| EventBid | Amount（金额） |  |
| EventBid | Round（轮次） |  |


## EndBlocker

| 类型                  | 属性键         | 属性值           |
| --------------------- | --------------------- | ------------------------- |
| EventAuctionResult（拍卖结果事件） | Winner（获胜者） |
| EventAuctionResult | Amount（金额） |
| EventAuctionResult | Round（轮次） |

