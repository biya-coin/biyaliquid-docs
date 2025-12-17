---
sidebar_position: 5
title: Events
---

# 事件

保险模块发出以下事件：

## 处理器

### MsgCreateInsuranceFund

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |

### MsgUnderwrite

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |

### MsgRequestRedemption

| Type                                               | Attribute Key | Attribute Value |
| -------------------------------------------------- | ------------- | --------------- |
| biyachain.insurance.v1beta1.EventRequestRedemption | schedule      | {scheduleJSON}  |



## EndBlocker

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |
| biyachain.insurance.v1beta1.EventWithdrawRedemption  | schedule      | {scheduleJSON}  |
| biyachain.insurance.v1beta1.EventWithdrawRedemption  | redeem_coin   | {redeemCoin}    |

