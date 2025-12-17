---
sidebar_position: 1
---

# Bank

## 摘要

本文档指定了 Cosmos SDK 的 bank 模块。

bank 模块负责处理账户之间的多资产代币转账，\
并跟踪特殊情况的伪转账，这些伪转账必须与特定类型的账户\
（特别是归属账户的委托/取消委托）以不同方式工作。\
它暴露了几个具有不同能力的接口，用于与必须更改用户余额的其他模块进行安全交互。

此外，bank 模块跟踪并提供对应用中使用的\
所有资产总供应量的查询支持。

此模块在 Cosmos Hub 中使用。

## 目录

* [供应](bank.md#supply)
  * [总供应量](bank.md#total-supply)
* [模块账户](bank.md#module-accounts)
  * [权限](bank.md#permissions)
* [状态](bank.md#state)
* [参数](bank.md#params)
* [Keepers](bank.md#keepers)
* [消息](bank.md#messages)
* [事件](bank.md#events)
  * [消息事件](bank.md#message-events)
  * [Keeper 事件](bank.md#keeper-events)
* [参数](bank.md#parameters)
  * [SendEnabled](bank.md#sendenabled)
  * [DefaultSendEnabled](bank.md#defaultsendenabled)
* [客户端](bank.md#client)
  * [CLI](bank.md#cli)
  * [查询](bank.md#query)
  * [交易](bank.md#transactions)
* [gRPC](bank.md#grpc)

## 供应

`supply` 功能：

* 被动跟踪链内代币的总供应量，
* 为模块提供持有/与 `Coins` 交互的模式，以及
* 引入不变量检查以验证链的总供应量。

### 总供应量

网络的总 `Supply` 等于所有账户的代币总和。\
每次铸造 `Coin`（例如：作为通胀机制的一部分）或销毁 `Coin`（例如：由于削减或治理提案被否决）时，总供应量都会更新。

## 模块账户

供应功能引入了一种新类型的 `auth.Account`，模块可以使用它\
来分配代币，并在特殊情况下铸造或销毁代币。在基础\
级别，这些模块账户能够与 `auth.Account` 和其他模块账户\
发送/接收代币。此设计取代了以前的替代设计，在那些设计中，\
为了持有代币，模块会从发送者账户销毁传入的代币，然后在内部跟踪这些代币。\
后来，为了发送代币，模块需要在目标账户中有效地铸造代币。\
新设计消除了模块之间执行此会计处理的重复逻辑。

`ModuleAccount` 接口定义如下：

```go
type ModuleAccount interface {
  auth.Account               // same methods as the Account interface

  GetName() string           // name of the module; used to obtain the address
  GetPermissions() []string  // permissions of module account
  HasPermission(string) bool
}
```

> **警告！**\
> 任何允许直接或间接发送资金的模块或消息处理器必须明确保证这些资金不能发送到模块账户（除非允许）。

供应 `Keeper` 还为与 `ModuleAccount` 相关的 auth `Keeper`\
和 bank `Keeper` 引入了新的包装函数，以便能够：

* 通过提供 `Name` 获取和设置 `ModuleAccount`。
* 仅通过传递 `Name` 从其他 `ModuleAccount` 或标准 `Account`\
  （`BaseAccount` 或 `VestingAccount`）发送和接收代币。
* 为 `ModuleAccount` `Mint` 或 `Burn` 代币（受其权限限制）。

### 权限

每个 `ModuleAccount` 都有不同的权限集，提供不同的\
对象能力来执行某些操作。权限需要在\
创建供应 `Keeper` 时注册，以便每次 `ModuleAccount` 调用允许的函数时，\
`Keeper` 可以查找该特定账户的权限并执行或不执行该操作。

可用权限包括：

* `Minter`: 允许模块铸造特定数量的代币。
* `Burner`: 允许模块销毁特定数量的代币。
* `Staking`: 允许模块委托和取消委托特定数量的代币。

## 状态

`x/bank` 模块保持以下主要对象的状态：

1. 账户余额
2. 代币单位元数据
3. 所有余额的总供应量
4. 允许发送哪些代币单位的信息。

此外，`x/bank` 模块保持以下索引来管理\
上述状态：

* 供应索引: `0x0 | byte(denom) -> byte(amount)`
* 代币单位元数据索引: `0x1 | byte(denom) -> ProtocolBuffer(Metadata)`
* 余额索引: `0x2 | byte(address length) | []byte(address) | []byte(balance.Denom) -> ProtocolBuffer(balance)`
* 反向代币单位到地址索引: `0x03 | byte(denom) | 0x00 | []byte(address) -> 0`

## 参数

bank 模块将其参数存储在状态中，前缀为 `0x05`，\
可以通过治理或具有权限的地址进行更新。

* Params: `0x05 | ProtocolBuffer(Params)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/bank.proto#L12-L23
```

## Keepers

bank 模块提供这些导出的 keeper 接口，可以\
传递给读取或更新账户余额的其他模块。模块\
应该使用提供其所需功能的最小权限接口。

最佳实践要求仔细审查 `bank` 模块代码，以确保\
权限按您期望的方式受到限制。

### 拒绝的地址

`x/bank` 模块接受一个地址映射，这些地址被视为被阻止\
通过 `MsgSend` 和 `MsgMultiSend` 等方式以及 `SendCoinsFromModuleToAccount` 等直接 API 调用\
直接和明确接收资金。

通常，这些地址是模块账户。如果这些地址在\
状态机的预期规则之外接收资金，不变量可能会被\
破坏，并可能导致网络停止。

通过向 `x/bank` 模块提供被阻止的地址集，如果用户或客户端尝试直接或间接向被阻止的账户发送资金（例如，通过使用 [IBC](https://ibc.cosmos.network)），操作将出错。

### 通用类型

#### Input

多方转账的输入

```protobuf
// Input models transaction input.
message Input {
  string   address                        = 1;
  repeated cosmos.base.v1beta1.Coin coins = 2;
}
```

#### Output

多方转账的输出。

```protobuf
// Output models transaction outputs.
message Output {
  string   address                        = 1;
  repeated cosmos.base.v1beta1.Coin coins = 2;
}
```

### BaseKeeper

基础 keeper 提供完全权限访问：能够任意修改任何账户的余额并铸造或销毁代币。

可以通过使用带有 `WithMintCoinsRestriction` 的 baseKeeper 来为每个模块实现受限的铸造权限，以对铸造施加特定限制（例如，仅铸造某些代币单位）。

```go
// Keeper defines a module interface that facilitates the transfer of coins
// between accounts.
type Keeper interface {
    SendKeeper
    WithMintCoinsRestriction(MintingRestrictionFn) BaseKeeper

    InitGenesis(context.Context, *types.GenesisState)
    ExportGenesis(context.Context) *types.GenesisState

    GetSupply(ctx context.Context, denom string) sdk.Coin
    HasSupply(ctx context.Context, denom string) bool
    GetPaginatedTotalSupply(ctx context.Context, pagination *query.PageRequest) (sdk.Coins, *query.PageResponse, error)
    IterateTotalSupply(ctx context.Context, cb func(sdk.Coin) bool)
    GetDenomMetaData(ctx context.Context, denom string) (types.Metadata, bool)
    HasDenomMetaData(ctx context.Context, denom string) bool
    SetDenomMetaData(ctx context.Context, denomMetaData types.Metadata)
    IterateAllDenomMetaData(ctx context.Context, cb func(types.Metadata) bool)

    SendCoinsFromModuleToAccount(ctx context.Context, senderModule string, recipientAddr sdk.AccAddress, amt sdk.Coins) error
    SendCoinsFromModuleToModule(ctx context.Context, senderModule, recipientModule string, amt sdk.Coins) error
    SendCoinsFromAccountToModule(ctx context.Context, senderAddr sdk.AccAddress, recipientModule string, amt sdk.Coins) error
    DelegateCoinsFromAccountToModule(ctx context.Context, senderAddr sdk.AccAddress, recipientModule string, amt sdk.Coins) error
    UndelegateCoinsFromModuleToAccount(ctx context.Context, senderModule string, recipientAddr sdk.AccAddress, amt sdk.Coins) error
    MintCoins(ctx context.Context, moduleName string, amt sdk.Coins) error
    BurnCoins(ctx context.Context, moduleName string, amt sdk.Coins) error

    DelegateCoins(ctx context.Context, delegatorAddr, moduleAccAddr sdk.AccAddress, amt sdk.Coins) error
    UndelegateCoins(ctx context.Context, moduleAccAddr, delegatorAddr sdk.AccAddress, amt sdk.Coins) error

    // GetAuthority gets the address capable of executing governance proposal messages. Usually the gov module account.
    GetAuthority() string

    types.QueryServer
}
```

### SendKeeper

发送 keeper 提供对账户余额的访问以及在账户之间\
转移代币的能力。发送 keeper 不会改变总供应量（铸造或销毁代币）。

```go
// SendKeeper defines a module interface that facilitates the transfer of coins
// between accounts without the possibility of creating coins.
type SendKeeper interface {
    ViewKeeper

    AppendSendRestriction(restriction SendRestrictionFn)
    PrependSendRestriction(restriction SendRestrictionFn)
    ClearSendRestriction()

    InputOutputCoins(ctx context.Context, input types.Input, outputs []types.Output) error
    SendCoins(ctx context.Context, fromAddr, toAddr sdk.AccAddress, amt sdk.Coins) error

    GetParams(ctx context.Context) types.Params
    SetParams(ctx context.Context, params types.Params) error

    IsSendEnabledDenom(ctx context.Context, denom string) bool
    SetSendEnabled(ctx context.Context, denom string, value bool)
    SetAllSendEnabled(ctx context.Context, sendEnableds []*types.SendEnabled)
    DeleteSendEnabled(ctx context.Context, denom string)
    IterateSendEnabledEntries(ctx context.Context, cb func(denom string, sendEnabled bool) (stop bool))
    GetAllSendEnabledEntries(ctx context.Context) []types.SendEnabled

    IsSendEnabledCoin(ctx context.Context, coin sdk.Coin) bool
    IsSendEnabledCoins(ctx context.Context, coins ...sdk.Coin) error

    BlockedAddr(addr sdk.AccAddress) bool
}
```

#### 发送限制

`SendKeeper` 在每次资金转移之前应用 `SendRestrictionFn`。

```golang
// A SendRestrictionFn can restrict sends and/or provide a new receiver address.
type SendRestrictionFn func(ctx context.Context, fromAddr, toAddr sdk.AccAddress, amt sdk.Coins) (newToAddr sdk.AccAddress, err error)
```

创建 `SendKeeper`（或 `BaseKeeper`）后，可以使用 `AppendSendRestriction` 或 `PrependSendRestriction` 函数向其添加发送限制。\
这两个函数将提供的限制与任何先前提供的限制组合在一起。`AppendSendRestriction` 将提供的限制添加为在任何先前提供的发送限制之后运行。`PrependSendRestriction` 将限制添加为在任何先前提供的发送限制之前运行。\
组合在遇到错误时会短路。即，如果第一个返回错误，第二个不会运行。

在 `SendCoins` 期间，发送限制在从 from 地址移除代币之后应用，但在将它们添加到 to 地址之前。\
在 `InputOutputCoins` 期间，发送限制在移除输入代币之后应用，并在添加资金之前为每个输出应用一次。

发送限制函数应该使用上下文中的自定义值，以允许绕过该特定限制。

发送限制不应用于 `ModuleToAccount` 或 `ModuleToModule` 转账。这样做是因为模块需要将资金移动到用户账户和其他模块账户。这是一个设计决策，允许状态机具有更大的灵活性。状态机应该能够在模块账户和用户账户之间不受限制地移动资金。

其次，这种限制甚至会限制状态机本身的使用。用户将无法接收奖励，无法在模块账户之间移动资金。在用户从用户账户向社区池发送资金，然后使用治理提案将这些代币放入用户账户的情况下，这将取决于应用链开发者的决定。我们不能在这里做出强有力的假设。\
第三，如果代币被禁用并且在 begin/endblock 中移动代币，这个问题可能导致链停止。这是我们看到当前更改的最后一个原因，对用户的损害大于好处。

For example, in your module's keeper package, you'd define the send restriction function:

```golang
var _ banktypes.SendRestrictionFn = Keeper{}.SendRestrictionFn

func (k Keeper) SendRestrictionFn(ctx context.Context, fromAddr, toAddr sdk.AccAddress, amt sdk.Coins) (sdk.AccAddress, error) {
	// Bypass if the context says to.
	if mymodule.HasBypass(ctx) {
		return toAddr, nil
	}

	// Your custom send restriction logic goes here.
	return nil, errors.New("not implemented")
}
```

The bank keeper should be provided to your keeper's constructor so the send restriction can be added to it:

```golang
func NewKeeper(cdc codec.BinaryCodec, storeKey storetypes.StoreKey, bankKeeper mymodule.BankKeeper) Keeper {
	rv := Keeper{/*...*/}
	bankKeeper.AppendSendRestriction(rv.SendRestrictionFn)
	return rv
}
```

Then, in the `mymodule` package, define the context helpers:

```golang
const bypassKey = "bypass-mymodule-restriction"

// WithBypass returns a new context that will cause the mymodule bank send restriction to be skipped.
func WithBypass(ctx context.Context) context.Context {
	return sdk.UnwrapSDKContext(ctx).WithValue(bypassKey, true)
}

// WithoutBypass returns a new context that will cause the mymodule bank send restriction to not be skipped.
func WithoutBypass(ctx context.Context) context.Context {
	return sdk.UnwrapSDKContext(ctx).WithValue(bypassKey, false)
}

// HasBypass checks the context to see if the mymodule bank send restriction should be skipped.
func HasBypass(ctx context.Context) bool {
	bypassValue := ctx.Value(bypassKey)
	if bypassValue == nil {
		return false
	}
	bypass, isBool := bypassValue.(bool)
	return isBool && bypass
}
```

Now, anywhere where you want to use `SendCoins` or `InputOutputCoins`, but you don't want your send restriction applied:

```golang
func (k Keeper) DoThing(ctx context.Context, fromAddr, toAddr sdk.AccAddress, amt sdk.Coins) error {
	return k.bankKeeper.SendCoins(mymodule.WithBypass(ctx), fromAddr, toAddr, amt)
}
```

### ViewKeeper

视图 keeper 提供对账户余额的只读访问。视图 keeper 没有余额修改功能。所有余额查找都是 `O(1)`。

```go
// ViewKeeper defines a module interface that facilitates read only access to
// account balances.
type ViewKeeper interface {
    ValidateBalance(ctx context.Context, addr sdk.AccAddress) error
    HasBalance(ctx context.Context, addr sdk.AccAddress, amt sdk.Coin) bool

    GetAllBalances(ctx context.Context, addr sdk.AccAddress) sdk.Coins
    GetAccountsBalances(ctx context.Context) []types.Balance
    GetBalance(ctx context.Context, addr sdk.AccAddress, denom string) sdk.Coin
    LockedCoins(ctx context.Context, addr sdk.AccAddress) sdk.Coins
    SpendableCoins(ctx context.Context, addr sdk.AccAddress) sdk.Coins
    SpendableCoin(ctx context.Context, addr sdk.AccAddress, denom string) sdk.Coin

    IterateAccountBalances(ctx context.Context, addr sdk.AccAddress, cb func(coin sdk.Coin) (stop bool))
    IterateAllBalances(ctx context.Context, cb func(address sdk.AccAddress, coin sdk.Coin) (stop bool))
}
```

## 消息

### MsgSend

从一个地址向另一个地址发送代币。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/tx.proto#L38-L53
```

在以下条件下，消息将失败：

* 代币未启用发送
* `to` 地址被限制

### MsgMultiSend

从一个发送者向一系列不同地址发送代币。如果任何接收地址不对应现有账户，将创建一个新账户。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/tx.proto#L58-L69
```

在以下条件下，消息将失败：

* 任何代币未启用发送
* 任何 `to` 地址被限制
* 任何代币被锁定
* 输入和输出不能正确对应

### MsgUpdateParams

`bank` 模块参数可以通过 `MsgUpdateParams` 更新，可以使用治理提案完成。签名者将始终是 `gov` 模块账户地址。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/tx.proto#L74-L88
```

如果出现以下情况，消息处理可能失败：

* 签名者不是 gov 模块账户地址。

### MsgSetSendEnabled

与 x/gov 模块一起使用，以设置创建/编辑 SendEnabled 条目。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/tx.proto#L96-L117
```

在以下条件下，消息将失败：

* 权限不是 bech32 地址。
* 权限不是 x/gov 模块的地址。
* 有多个具有相同 Denom 的 SendEnabled 条目。
* 一个或多个 SendEnabled 条目具有无效的 Denom。

## 事件

bank 模块发出以下事件：

### 消息事件

#### MsgSend

| 类型     | 属性键     | 属性值            |
| -------- | ---------- | ----------------- |
| transfer | recipient  | {recipientAddress} |
| transfer | amount     | {amount}           |
| message  | module     | bank               |
| message  | action     | send               |
| message  | sender     | {senderAddress}    |

#### MsgMultiSend

| 类型     | 属性键     | 属性值            |
| -------- | ---------- | ----------------- |
| transfer | recipient  | {recipientAddress} |
| transfer | amount     | {amount}           |
| message  | module     | bank               |
| message  | action     | multisend          |
| message  | sender     | {senderAddress}    |

### Keeper 事件

除了消息事件外，bank keeper 在调用以下方法（或最终调用它们的任何方法）时会产生事件

#### MintCoins

```json
{
  "type": "coinbase",
  "attributes": [
    {
      "key": "minter",
      "value": "{{sdk.AccAddress of the module minting coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being minted}}",
      "index": true
    }
  ]
}
```

```json
{
  "type": "coin_received",
  "attributes": [
    {
      "key": "receiver",
      "value": "{{sdk.AccAddress of the module minting coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being received}}",
      "index": true
    }
  ]
}
```

#### BurnCoins

```json
{
  "type": "burn",
  "attributes": [
    {
      "key": "burner",
      "value": "{{sdk.AccAddress of the module burning coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being burned}}",
      "index": true
    }
  ]
}
```

```json
{
  "type": "coin_spent",
  "attributes": [
    {
      "key": "spender",
      "value": "{{sdk.AccAddress of the module burning coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being burned}}",
      "index": true
    }
  ]
}
```

#### addCoins

```json
{
  "type": "coin_received",
  "attributes": [
    {
      "key": "receiver",
      "value": "{{sdk.AccAddress of the address beneficiary of the coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being received}}",
      "index": true
    }
  ]
}
```

#### subUnlockedCoins/DelegateCoins

```json
{
  "type": "coin_spent",
  "attributes": [
    {
      "key": "spender",
      "value": "{{sdk.AccAddress of the address which is spending coins}}",
      "index": true
    },
    {
      "key": "amount",
      "value": "{{sdk.Coins being spent}}",
      "index": true
    }
  ]
}
```

## 参数

bank 模块包含以下参数

### SendEnabled

SendEnabled 参数现已弃用，不再使用。它已被\
状态存储记录取代。

### DefaultSendEnabled

默认发送启用值控制所有\
代币单位的发送转账能力，除非明确包含在 `SendEnabled`\
参数数组中。

## 客户端

### CLI

用户可以使用 CLI 查询和与 `bank` 模块交互。

#### 查询

`query` 命令允许用户查询 `bank` 状态。

```shell
simd query bank --help
```

**balances**

`balances` 命令允许用户通过地址查询账户余额。

```shell
simd query bank balances [address] [flags]
```

示例：

```shell
simd query bank balances cosmos1..
```

示例输出：

```yml
balances:
- amount: "1000000000"
  denom: stake
pagination:
  next_key: null
  total: "0"
```

**denom-metadata**

`denom-metadata` 命令允许用户查询代币单位的元数据。用户可以使用 `--denom` 标志查询单个代币单位的元数据，或不使用它查询所有代币单位。

```shell
simd query bank denom-metadata [flags]
```

示例：

```shell
simd query bank denom-metadata --denom stake
```

示例输出：

```yml
metadata:
  base: stake
  denom_units:
  - aliases:
    - STAKE
    denom: stake
  description: native staking token of simulation app
  display: stake
  name: SimApp Token
  symbol: STK
```

**total**

`total` 命令允许用户查询代币的总供应量。用户可以使用 `--denom` 标志查询单个代币的总供应量，或不使用它查询所有代币。

```shell
simd query bank total [flags]
```

示例：

```shell
simd query bank total --denom stake
```

示例输出：

```yml
amount: "10000000000"
denom: stake
```

**send-enabled**

`send-enabled` 命令允许用户查询所有或某些 SendEnabled 条目。

```shell
simd query bank send-enabled [denom1 ...] [flags]
```

示例：

```shell
simd query bank send-enabled
```

示例输出：

```yml
send_enabled:
- denom: foocoin
  enabled: true
- denom: barcoin
pagination:
  next-key: null
  total: 2 
```

#### 交易

`tx` 命令允许用户与 `bank` 模块交互。

```shell
simd tx bank --help
```

**send**

`send` 命令允许用户从一个账户向另一个账户发送资金。

```shell
simd tx bank send [from_key_or_address] [to_address] [amount] [flags]
```

示例：

```shell
simd tx bank send cosmos1.. cosmos1.. 100stake
```

## gRPC

用户可以使用 gRPC 端点查询 `bank` 模块。

### Balance

`Balance` 端点允许用户通过地址查询给定代币单位的账户余额。

```shell
cosmos.bank.v1beta1.Query/Balance
```

示例：

```shell
grpcurl -plaintext \
    -d '{"address":"cosmos1..","denom":"stake"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/Balance
```

示例输出：

```json
{
  "balance": {
    "denom": "stake",
    "amount": "1000000000"
  }
}
```

### AllBalances

`AllBalances` 端点允许用户通过地址查询所有代币单位的账户余额。

```shell
cosmos.bank.v1beta1.Query/AllBalances
```

示例：

```shell
grpcurl -plaintext \
    -d '{"address":"cosmos1.."}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/AllBalances
```

示例输出：

```json
{
  "balances": [
    {
      "denom": "stake",
      "amount": "1000000000"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### DenomMetadata

`DenomMetadata` 端点允许用户查询单个代币单位的元数据。

```shell
cosmos.bank.v1beta1.Query/DenomMetadata
```

示例：

```shell
grpcurl -plaintext \
    -d '{"denom":"stake"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/DenomMetadata
```

示例输出：

```json
{
  "metadata": {
    "description": "native staking token of simulation app",
    "denomUnits": [
      {
        "denom": "stake",
        "aliases": [
          "STAKE"
        ]
      }
    ],
    "base": "stake",
    "display": "stake",
    "name": "SimApp Token",
    "symbol": "STK"
  }
}
```

### DenomsMetadata

`DenomsMetadata` 端点允许用户查询所有代币单位的元数据。

```shell
cosmos.bank.v1beta1.Query/DenomsMetadata
```

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/DenomsMetadata
```

示例输出：

```json
{
  "metadatas": [
    {
      "description": "native staking token of simulation app",
      "denomUnits": [
        {
          "denom": "stake",
          "aliases": [
            "STAKE"
          ]
        }
      ],
      "base": "stake",
      "display": "stake",
      "name": "SimApp Token",
      "symbol": "STK"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### DenomOwners

`DenomOwners` 端点允许用户查询单个代币单位的元数据。

```shell
cosmos.bank.v1beta1.Query/DenomOwners
```

示例：

```shell
grpcurl -plaintext \
    -d '{"denom":"stake"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/DenomOwners
```

示例输出：

```json
{
  "denomOwners": [
    {
      "address": "cosmos1..",
      "balance": {
        "denom": "stake",
        "amount": "5000000000"
      }
    },
    {
      "address": "cosmos1..",
      "balance": {
        "denom": "stake",
        "amount": "5000000000"
      }
    },
  ],
  "pagination": {
    "total": "2"
  }
}
```

### TotalSupply

`TotalSupply` 端点允许用户查询所有代币的总供应量。

```shell
cosmos.bank.v1beta1.Query/TotalSupply
```

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/TotalSupply
```

示例输出：

```json
{
  "supply": [
    {
      "denom": "stake",
      "amount": "10000000000"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### SupplyOf

`SupplyOf` 端点允许用户查询单个代币的总供应量。

```shell
cosmos.bank.v1beta1.Query/SupplyOf
```

示例：

```shell
grpcurl -plaintext \
    -d '{"denom":"stake"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/SupplyOf
```

示例输出：

```json
{
  "amount": {
    "denom": "stake",
    "amount": "10000000000"
  }
}
```

### Params

`Params` 端点允许用户查询 `bank` 模块的参数。

```shell
cosmos.bank.v1beta1.Query/Params
```

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/Params
```

示例输出：

```json
{
  "params": {
    "defaultSendEnabled": true
  }
}
```

### SendEnabled

`SendEnabled` 端点允许用户查询 `bank` 模块的 SendEnabled 条目。

未返回的任何代币单位使用 `Params.DefaultSendEnabled` 值。

```shell
cosmos.bank.v1beta1.Query/SendEnabled
```

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/SendEnabled
```

示例输出：

```json
{
  "send_enabled": [
    {
      "denom": "foocoin",
      "enabled": true
    },
    {
      "denom": "barcoin"
    }
  ],
  "pagination": {
    "next-key": null,
    "total": 2
  }
}
```
