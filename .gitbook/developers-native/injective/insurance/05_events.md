---
sidebar_position: 5
title: Events
---

# Events

The insurance module emits the following events:

## Handlers

### MsgCreateInsuranceFund

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyaliquid.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |

### MsgUnderwrite

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyaliquid.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |

### MsgRequestRedemption

| Type                                               | Attribute Key | Attribute Value |
| -------------------------------------------------- | ------------- | --------------- |
| biyaliquid.insurance.v1beta1.EventRequestRedemption | schedule      | {scheduleJSON}  |



## EndBlocker

| Type                                                 | Attribute Key | Attribute Value |
| ---------------------------------------------------- | ------------- | --------------- |
| biyaliquid.insurance.v1beta1.EventInsuranceFundUpdate | fund          | {fundJSON}      |
| biyaliquid.insurance.v1beta1.EventWithdrawRedemption  | schedule      | {scheduleJSON}  |
| biyaliquid.insurance.v1beta1.EventWithdrawRedemption  | redeem_coin   | {redeemCoin}    |

