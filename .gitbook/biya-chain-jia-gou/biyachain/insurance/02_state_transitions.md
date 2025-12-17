---
sidebar_position: 2
title: State Transitions
---

# 状态转换

## 状态转换

本文档描述了与以下内容相关的状态转换操作：

* Creating an insurance fund
* Underwriting an insurance fund
* Request a redemption from the insurance fund
* Automatic processing of matured redemption requests

### 创建保险基金

**参数描述**`Sender` 字段描述保险基金的创建者。`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleType`、`Expiry` 字段描述保险基金关联的衍生品市场信息。`InitialDeposit` 字段描述要存入保险基金的初始存款金额。

**步骤**

* 获取保险基金的 `MarketId` - **注意**，市场可能尚未在 `exchange` 上可用，这不是问题
* 确保与 `MarketId` 关联的保险基金不存在
* 确保初始存款金额不为零
* 获取唯一的 `shareDenom` - 当为保险基金创建请求份额面额时，或在承保余额为零且总份额面额供应量非零的保险基金时，它会递增
* 从创建者的账户发送代币到保险基金模块账户
* 使用 `DefaultRedemptionNoticePeriodDuration` 和提供的参数创建保险基金对象
* 将基金对象的 `Balance` 设置为初始存款金额
* 向创建者账户铸造 `InsuranceFundInitialSupply` (10^18) `shareDenom` 代币
* 将保险基金对象保存到存储
* 在 BankKeeper 中注册新创建的保险基金 `shareDenom` 元数据

### 承保保险基金

**参数描述**`Sender` 字段描述保险基金的承保人。`MarketId` 字段描述保险基金的衍生品市场 ID。`Deposit` 字段描述要添加到保险基金的存款金额。

**步骤**

* 确保与 `MarketId` 关联的保险基金存在
* 从发送者的账户发送承保代币到模块账户
* 根据与 `MarketId` 关联的保险基金状态执行操作。
  * A. 当 `Balance` 和 `ShareDenomSupply` 为零时
    1. 向发送者铸造 `InsuranceFundInitialSupply` (10^18)。
    2. 将 `Balance` 设置为存款金额
    3. 将 `ShareDenomSupply` 设置为 `InsuranceFundInitialSupply`
  * B. 当 `Balance` 为零且 `ShareDenomSupply` 不为零时
    1. 更改保险基金的 `ShareDenom` 以从头开始新的保险基金。
    2. 在银行保管器中注册新创建的 `ShareDenom`
    3. 向发送者铸造 `InsuranceFundInitialSupply` (10^18)。
    4. 将 `Balance` 设置为存款金额
    5. 将 `ShareDenomSupply` 设置为 `InsuranceFundInitialSupply`
  * C. 当 `Balance` 不为零且 `ShareDenomSupply` 为零时
    1. 向发送者铸造 `InsuranceFundInitialSupply` (10^18)。
    2. 将 `Balance` 增加存款金额
    3. 将 `ShareDenomSupply` 设置为 `InsuranceFundInitialSupply`
  * D. 当 `Balance` 和 `ShareDenomSupply` 都不为零时 - 正常情况
    1. 将 `Balance` 增加存款金额
    2. 向发送者铸造 `prev_ShareDenomSupply * deposit_amount / prev_Balance` 数量的 `ShareDenom`
    3. 将 `ShareDenomSupply` 增加铸造数量
* 将保险基金对象保存到存储

### 从保险基金请求赎回

**参数描述**`Sender` 字段描述保险基金的赎回请求者。`MarketId` 字段描述与保险基金关联的衍生品市场 ID。`Amount` 字段描述要赎回的份额代币数量。

**步骤**

* 确保与 `MarketId` 关联的保险基金存在
* 将 `ShareDenom` 发送到模块账户
* 获取新的赎回计划 ID
* 根据保险基金的赎回通知期限和当前区块时间计算 `ClaimTime`
* 计算存储待处理赎回（赎回计划）的键
* 创建包含详细信息的赎回计划对象
* 将赎回计划对象存储到存储

### 衍生品市场清算事件中的保险基金操作

**步骤**

* `exchange` 模块从保险保管器中找到相关保险基金。
* 如果 `missingFund` 为正数，它通过 `WithdrawFromInsuranceFund` 从保险基金中提取金额。
* 如果 `missingFund` 为负数，它通过 `DepositIntoInsuranceFund` 将金额存入保险基金。

### 自动处理待处理赎回

**步骤**

按 `ClaimTime` 排序顺序迭代所有到期的赎回，并执行以下操作：

* 如果 `ClaimTime` 在当前区块时间之后，提前中断
* 确保到期赎回计划存在保险基金
* 根据份额数量计算赎回金额 - `shareAmt * fund.Balance * fund.TotalShare`
* 从模块账户发送计算的赎回金额到赎回者账户
* 销毁在赎回计划时发送到模块账户的份额代币
* 删除赎回计划对象
* 将保险基金的 `Balance` 减少赎回金额
* 将更新的保险对象存储到存储

## Hooks

其他模块可以注册操作，以便在保险基金内发生某些事件时执行。这些事件可以注册为在交易所事件之前或之后执行（根据 hook 名称）。以下 hooks 可以向交易所注册：

**注意**：Hooks 不可用，交易所模块直接调用保险保管器函数。

**步骤**\
当衍生品市场发生清算事件时

* `exchange` 模块从保险保管器中找到相关保险基金。
* 如果 `missingFund` 为正数，它通过 `WithdrawFromInsuranceFund` 从保险基金中提取金额。
* 如果 `missingFund` 为负数，它通过 `DepositIntoInsuranceFund` 将金额存入保险基金。
