# 创建您的交换合约

[交换合约](https://github.com/biya-coin/swap-contract) 允许在两种不同代币之间进行即时交换。在底层,它使用原子订单在一个或多个现货市场中下市价订单。

### 入门指南

任何人都可以实例化交换合约的实例。Biya Chain 主网上已经上传了此合约的一个版本,可以在 [这里](https://biyascan.com/code/67/) 找到。

在实例化合约之前,作为合约所有者,您需要回答三个问题:

#### 1. 哪个地址应该是手续费接收者?

由于交换合约下的订单是 Biya Chain 交易所模块中的订单,这意味着每个订单都可以有一个手续费接收者,可以接收 40% 的交易手续费。通常,交易所 dApp 会将手续费接收者设置为自己的地址。

#### 2. 此合约应该支持哪些代币?

合约中可用的每个代币都必须定义路由。路由是指 `代币 A` 将通过哪些市场才能获得 `代币 B`。例如,如果您想支持 ATOM 和 BIYA 之间的交换,那么您必须通过向合约提供 ATOM/USDT 和 BIYA/USDT 的市场 ID 来设置路由,以便它知道 ATOM 和 BIYA 之间的交换路由是 ATOM ⇔ USDT ⇔ BIYA。

目前,合约只能支持以 USDT 报价的市场。

#### 3. 应该为此合约提供多少缓冲资金?

作为合约所有者,您还必须向合约提供资金,这些资金将在交换发生时使用。合约在下订单时使用缓冲资金。如果用户想要交换大量资金或在流动性不足的市场中交换,则需要更多缓冲资金。当合约缓冲资金无法满足用户的输入金额时,将发生错误。

目前,缓冲资金应该只是 USDT。

### 消息

#### 实例化

使用合约版本和配置详细信息初始化合约状态。配置包括管理员地址和手续费接收者地址。

```rust
pub fn instantiate(
    deps: DepsMut<BiyachainQueryWrapper>,
    env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

#### 执行

处理不同类型的交易和管理功能:

* SwapMinOutput: 以最小输出数量进行交换。
* SwapExactOutput: 以精确输出数量进行交换。
* SetRoute: 设置交换路由。
* DeleteRoute: 删除交换路由。
* UpdateConfig: 更新合约配置。
* WithdrawSupportFunds: 从合约中提取支持资金。

```rust
pub fn execute(
    deps: DepsMut<BiyachainQueryWrapper>,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

#### 回复

处理来自其他合约或交易的回复。

```rust
pub fn reply(
    deps: DepsMut<BiyachainQueryWrapper>,
    env: Env,
    msg: Reply,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

#### 查询

处理对合约的各种查询:

* GetRoute: 获取特定的交换路由。
* GetOutputQuantity: 获取给定输入数量的输出数量。
* GetInputQuantity: 获取给定输出数量的输入数量。
* GetAllRoutes: 获取所有可用的交换路由。

```rust
pub fn query(deps: Deps<BiyachainQueryWrapper>, env: Env, msg: QueryMsg) -> StdResult<Binary>
```

### 仓库

交换合约的完整 GitHub 仓库可以在 [这里](https://github.com/biya-coin/swap-contract) 找到。
