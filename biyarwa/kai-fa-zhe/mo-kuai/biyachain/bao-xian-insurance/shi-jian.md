# 事件

保险模块会触发以下事件：

## Handlers

### MsgCreateInsuranceFund

| 类型                                                   | 属性键  | 属性值        |
| ---------------------------------------------------- | ---- | ---------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund | {fundJSON} |

### MsgUnderwrite

| 类型                                                   | 属性键  | 属性值        |
| ---------------------------------------------------- | ---- | ---------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund | {fundJSON} |

### MsgRequestRedemption

| 类型                                                 | 属性键      | 属性值            |
| -------------------------------------------------- | -------- | -------------- |
| biyachain.insurance.v1beta1.EventRequestRedemption | schedule | {scheduleJSON} |

## EndBlocker

| 类型                                                   | 属性键          | 属性值            |
| ---------------------------------------------------- | ------------ | -------------- |
| biyachain.insurance.v1beta1.EventInsuranceFundUpdate | fund         | {fundJSON}     |
| biyachain.insurance.v1beta1.EventWithdrawRedemption  | schedule     | {scheduleJSON} |
| biyachain.insurance.v1beta1.EventWithdrawRedemption  | redeem\_coin | {redeemCoin}   |
