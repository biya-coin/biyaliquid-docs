# 事件

拍卖模块会触发以下事件：

## **处理器（Handlers）**

### Msg/Bid

| 类型       | 属性键（Attribute Key） | Attribute Value |
| -------- | ------------------ | --------------- |
| EventBid | Bidder             |                 |
| EventBid | Amount             |                 |
| EventBid | Round              |                 |

## EndBlocker

| 累心                 | 属性键（Attribute Key） | Attribute Value |
| ------------------ | ------------------ | --------------- |
| EventAuctionResult | Winner             |                 |
| EventAuctionResult | Amount             |                 |
| EventAuctionResult | Round              |                 |
