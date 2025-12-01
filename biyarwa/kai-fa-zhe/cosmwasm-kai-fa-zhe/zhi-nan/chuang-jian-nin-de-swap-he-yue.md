# 创建您的 Swap 合约

[swap contract](https://github.com/InjectiveLabs/swap-contract) 允许在两个不同的代币之间进行即时交换。在后台，它使用原子订单在一个或多个现货市场中下达市场订单。

## 快速开始

任何人都可以实例化交换合约的实例。此合约的一个版本已经上传到 Biyachain 主网，并可以在[此处](https://explorer.injective.network/code/67/)找到。\
在实例化合约之前，作为合约拥有者，你需要回答以下三个问题：

1. 哪个地址应为手续费接收者？\
   由于交换合约下的订单是 Biyachain 交易模块中的订单，这意味着每个订单可以有一个手续费接收者，该接收者可以获得 40% 的交易手续费。通常，交易所 dApp 会将手续费接收者设置为自己的地址。
2.  该合约应支持哪些代币？\
    合约中可用的每个代币必须定义一个交易路线。路线是指代币 A 要通过哪些市场才能换取代币 B。例如，如果你想支持 ATOM 和 BIYA 之间的交换，则需要通过提供 ATOM/USDT 和 BIYA/USDT 的市场 ID 来设置路线，这样它就知道 ATOM 和 B创建您的 Swap 合约

    [swap contract](https://github.com/InjectiveLabs/swap-contract) 允许在两个不同的代币之间进行即时交换。在后台，它使用原子订单在一个或多个现货市场中下达市场订单。

    #### 快速开始

    任何人都可以实例化交换合约的实例。此合约的一个版本已经上传到 Biyachain 主网，并可以在[此处](https://explorer.injective.network/code/67/)找到。\
    在实例化合约之前，作为合约拥有者，你需要回答以下三个问题：

    1. 哪个地址应为手续费接收者？\
       由于交换合约下的订单是 Biyachain 交易模块中的订单，这意味着每个订单可以有一个手续费接收者，该接收者可以获得 40% 的交易手续费。通常，交易所 dApp 会将手续费接收者设置为自己的地址。
    2. 该合约应支持哪些代币？\
       合约中可用的每个代币必须定义一个交易路线。路线是指代币 A 要通过哪些市场才能换取代币 B。例如，如果你想支持 ATOM 和 BIYA 之间的交换，则需要通过提供 ATOM/USDT 和 BIYA/USDT 的市场 ID 来设置路线，这样它就知道 ATOM 和 BIYA 之间的交换路线是 ATOM ⇔ USDT ⇔ BIYA。\
       目前，合约只能支持以 USDT 报价的市场。
    3. 应该为该合约提供多少缓冲资金？\
       作为合约拥有者，你还需要为合约提供资金，当发生交换时，这些资金将被使用。缓冲资金由合约在下单时使用。如果用户想要交换大额资产或在流动性不足的市场中进行交换，则需要更多的缓冲资金。当合约的缓冲资金无法满足用户输入金额时，会发生错误。

    目前，缓冲资金应仅为 USDT。

    #### Messages

    **Instantiate**

    初始化合约状态，包含合约版本和配置详情。配置包括管理员地址和手续费接收者地址。

    ```rust
    pub fn instantiate(
        deps: DepsMut<BiyachainQueryWrapper>,
        env: Env,
        info: MessageInfo,
        msg: InstantiateMsg,
    ) -> Result<Response<BiyachainMsgWrapper>, ContractError>
    ```

    **Execute**

    处理不同类型的交易和管理员功能：

    * **SwapMinOutput**: 以最小输出数量进行交换。
    * **SwapExactOutput**: 以精确输出数量进行交换。
    * **SetRoute**: 设置交换路线。
    * **DeleteRoute**: 删除交换路线。
    * **UpdateConfig**: 更新合约配置。
    * **WithdrawSupportFunds**: 从合约中提取支持资金。

    ```rust
    pub fn execute(
        deps: DepsMut<BiyachainQueryWrapper>,
        env: Env,
        info: MessageInfo,
        msg: ExecuteMsg,
    ) -> Result<Response<BiyachainMsgWrapper>, ContractError>
    ```

    **Reply**

    处理来自其他合约或交易的回复。

    ```rust
    pub fn reply(
        deps: DepsMut<BiyachainQueryWrapper>,
        env: Env,
        msg: Reply,
    ) -> Result<Response<BiyachainMsgWrapper>, ContractError>
    ```

    **Query**

    处理对合约的各种查询：

    * **GetRoute**: 获取特定的交换路径。
    * **GetOutputQuantity**: 获取给定输入数量的输出数量。
    * **GetInputQuantity**: 获取给定输出数量的输入数量。
    * **GetAllRoutes**: 获取所有可用的交换路径。

    ```rust
    pub fn query(deps: Deps<BiyachainQueryWrapper>, env: Env, msg: QueryMsg) -> StdResult<Binary>
    ```

    #### 代码库

    swap contract 的完整 GitHub 仓库可以在[这里](https://github.com/InjectiveLabs/swap-contract)找到。BYIYA 之间的交换路线是 ATOM ⇔ USDT ⇔ BIYA。\
    目前，合约只能支持以 USDT 报价的市场。
3. 应该为该合约提供多少缓冲资金？\
   作为合约拥有者，你还需要为合约提供资金，当发生交换时，这些资金将被使用。缓冲资金由合约在下单时使用。如果用户想要交换大额资产或在流动性不足的市场中进行交换，则需要更多的缓冲资金。当合约的缓冲资金无法满足用户输入金额时，会发生错误。

目前，缓冲资金应仅为 USDT。

## Messages

**Instantiate**

初始化合约状态，包含合约版本和配置详情。配置包括管理员地址和手续费接收者地址。

```rust
pub fn instantiate(
    deps: DepsMutQueryWrapper>,
    env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

**Execute**

处理不同类型的交易和管理员功能：

* **SwapMinOutput**: 以最小输出数量进行交换。
* **SwapExactOutput**: 以精确输出数量进行交换。
* **SetRoute**: 设置交换路线。
* **DeleteRoute**: 删除交换路线。
* **UpdateConfig**: 更新合约配置。
* **WithdrawSupportFunds**: 从合约中提取支持资金。

```rust
pub fn execute(
    deps: DepsMut<BiyachainQueryWrapper>,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

**Reply**

处理来自其他合约或交易的回复。

```rust
pub fn reply(
    deps: DepsMut<BiyachainQueryWrapper>,
    env: Env,
    msg: Reply,
) -> Result<Response<BiyachainMsgWrapper>, ContractError>
```

**Query**

处理对合约的各种查询：

* **GetRoute**: 获取特定的交换路径。
* **GetOutputQuantity**: 获取给定输入数量的输出数量。
* **GetInputQuantity**: 获取给定输出数量的输入数量。
* **GetAllRoutes**: 获取所有可用的交换路径。

```rust
pub fn query(deps: Deps<BiyachainQueryWrapper>, env: Env, msg: QueryMsg) -> StdResult<Binary>
```

## 代码库

swap contract 的完整 GitHub 仓库可以在[这里](https://github.com/InjectiveLabs/swap-contract)找到。
