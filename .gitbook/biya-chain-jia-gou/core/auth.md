---
sidebar_position: 1
---

# Auth

## 摘要

本文档指定了 Cosmos SDK 的 auth 模块。

auth 模块负责为应用指定基础交易和账户类型，因为 SDK 本身对这些细节是不可知的。它包含中间件，所有基本交易有效性检查（签名、nonce、辅助字段）都在其中执行，并暴露账户 keeper，允许其他模块读取、写入和修改账户。

此模块在 Cosmos Hub 中使用。

## 概念

**注意：** auth 模块不同于 [authz 模块](authz.md)。

区别在于：

* `auth` - Cosmos SDK 应用的账户和交易的身份验证，负责指定基础交易和账户类型。
* `authz` - 账户代表其他账户执行操作的授权，使授权者能够向被授权者授予授权，允许被授权者代表授权者执行消息。

### Gas & Fees

费用对网络运营商有两个目的。

费用限制每个全节点存储的状态增长，并允许对经济价值较低的交易进行通用审查。费用最适合作为反垃圾邮件机制，其中验证者不关心网络的使用和用户身份。

费用由交易提供的 gas 限制和 gas 价格确定，其中 `fees = ceil(gasLimit * gasPrices)`。交易对所有状态读取/写入、签名验证以及与交易大小成比例的成本产生 gas 成本。运营商应在启动节点时设置最低 gas 价格。他们必须设置他们希望支持的每个代币单位的 gas 单位成本：
`simd start ... --minimum-gas-prices=0.00001stake;0.05photinos`

当将交易添加到内存池或传播交易时，验证者检查交易提供的费用所确定的 gas 价格是否满足验证者的任何最低 gas 价格。换句话说，交易必须提供至少一个与验证者最低 gas 价格匹配的代币单位的费用。

CometBFT 目前不提供基于费用的内存池优先级排序，基于费用的内存池过滤是节点本地的，不是共识的一部分。但是通过设置最低 gas 价格，节点运营商可以实现这样的机制。

由于代币的市场价值会波动，预计验证者会动态调整其最低 gas 价格，以达到鼓励使用网络的水平。

## 状态

### 账户

账户包含 SDK 区块链唯一标识的外部用户的身份验证信息，包括公钥、地址和用于重放保护的账户编号/序列号。为了提高效率，由于还必须获取账户余额以支付费用，账户结构体还将用户的余额存储为 `sdk.Coins`。

账户在外部作为接口暴露，在内部存储为基础账户或归属账户。希望添加更多账户类型的模块客户端可以这样做。
* `0x01 | Address -> ProtocolBuffer(account)`

#### 账户接口

账户接口暴露读取和写入标准账户信息的方法。请注意，所有这些方法都在符合接口的账户结构体上操作 - 为了将账户写入存储，需要使用账户 keeper。

```go
// AccountI is an interface used to store coins at a given address within state.
// It presumes a notion of sequence numbers for replay protection,
// a notion of account numbers for replay protection for previously pruned accounts,
// and a pubkey for authentication purposes.
//
// Many complex conditions can be used in the concrete struct which implements AccountI.
type AccountI interface {
	proto.Message

	GetAddress() sdk.AccAddress
	SetAddress(sdk.AccAddress) error // errors if already set.

	GetPubKey() crypto.PubKey // can return nil.
	SetPubKey(crypto.PubKey) error

	GetAccountNumber() uint64
	SetAccountNumber(uint64) error

	GetSequence() uint64
	SetSequence(uint64) error

	// Ensure that account implements stringer
	String() string
}
```

**基础账户**

基础账户是最简单和最常见的账户类型，它只是将所有必需字段直接存储在结构体中。

```protobuf
// BaseAccount defines a base account type. It contains all the necessary fields
// for basic account functionality. Any custom account type should extend this
// type for additional functionality (e.g. vesting).
message BaseAccount {
  string address = 1;
  google.protobuf.Any pub_key = 2;
  uint64 account_number = 3;
  uint64 sequence       = 4;
}
```

### 归属账户

参见 [Vesting](https://docs.cosmos.network/main/modules/auth/vesting/)。

## AnteHandlers

`x/auth` 模块目前没有自己的交易处理器，但确实暴露了特殊的 `AnteHandler`，用于对交易执行基本有效性检查，以便可以将其从内存池中丢弃。`AnteHandler` 可以看作是一组装饰器，在当前上下文中检查交易，根据 [ADR 010](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-010-modular-antehandler.md)。

请注意，`AnteHandler` 在 `CheckTx` 和 `DeliverTx` 上都会被调用，因为 CometBFT 提案者目前有能力在其提议的区块中包含在 `CheckTx` 中失败的交易。

### 装饰器

auth 模块提供 `AnteDecorator`，它们按以下顺序递归链接成单个 `AnteHandler`：

* `SetUpContextDecorator`: 在 `Context` 中设置 `GasMeter`，并用 defer 子句包装下一个 `AnteHandler`，以从 `AnteHandler` 链中的任何下游 `OutOfGas` panic 中恢复，返回包含提供的 gas 和使用的 gas 信息的错误。
* `RejectExtensionOptionsDecorator`: 拒绝所有可以在 protobuf 交易中可选包含的扩展选项。
* `MempoolFeeDecorator`: 在 `CheckTx` 期间检查 `tx` 费用是否高于本地内存池 `minFee` 参数。
* `ValidateBasicDecorator`: 调用 `tx.ValidateBasic` 并返回任何非 nil 错误。
* `TxTimeoutHeightDecorator`: 检查 `tx` 高度超时。
* `ValidateMemoDecorator`: 使用应用参数验证 `tx` memo 并返回任何非 nil 错误。
* `ConsumeGasTxSizeDecorator`: 根据应用参数消耗与 `tx` 大小成比例的 gas。
* `DeductFeeDecorator`: 从 `tx` 的第一个签名者扣除 `FeeAmount`。如果启用了 `x/feegrant` 模块并设置了费用授权者，则从费用授权者账户扣除费用。
* `SetPubKeyDecorator`: 从 `tx` 的签名者中设置尚未在状态机和当前上下文中保存其对应公钥的公钥。
* `ValidateSigCountDecorator`: 根据应用参数验证 `tx` 中的签名数量。
* `SigGasConsumeDecorator`: 为每个签名消耗参数定义的 gas 量。这要求作为 `SetPubKeyDecorator` 的一部分，在上下文中为所有签名者设置公钥。
* `SigVerificationDecorator`: 验证所有签名是否有效。这要求作为 `SetPubKeyDecorator` 的一部分，在上下文中为所有签名者设置公钥。
* `IncrementSequenceDecorator`: 为每个签名者递增账户序列号以防止重放攻击。

## Keepers

auth 模块仅暴露一个 keeper，即账户 keeper，可用于读取和写入账户。

### 账户 Keeper

目前仅暴露一个完全权限的账户 keeper，它能够读取和写入所有账户的所有字段，并迭代所有存储的账户。

```go
// AccountKeeperI is the interface contract that x/auth's keeper implements.
type AccountKeeperI interface {
	// Return a new account with the next account number and the specified address. Does not save the new account to the store.
	NewAccountWithAddress(sdk.Context, sdk.AccAddress) types.AccountI

	// Return a new account with the next account number. Does not save the new account to the store.
	NewAccount(sdk.Context, types.AccountI) types.AccountI

	// Check if an account exists in the store.
	HasAccount(sdk.Context, sdk.AccAddress) bool

	// Retrieve an account from the store.
	GetAccount(sdk.Context, sdk.AccAddress) types.AccountI

	// Set an account in the store.
	SetAccount(sdk.Context, types.AccountI)

	// Remove an account from the store.
	RemoveAccount(sdk.Context, types.AccountI)

	// Iterate over all accounts, calling the provided function. Stop iteration when it returns true.
	IterateAccounts(sdk.Context, func(types.AccountI) bool)

	// Fetch the public key of an account at a specified address
	GetPubKey(sdk.Context, sdk.AccAddress) (crypto.PubKey, error)

	// Fetch the sequence of an account at a specified address.
	GetSequence(sdk.Context, sdk.AccAddress) (uint64, error)

	// Fetch the next account number, and increment the internal counter.
	NextAccountNumber(sdk.Context) uint64
}
```

## 参数

auth 模块包含以下参数：

| 键                      | 类型   | 示例   |
| ----------------------- | ------ | ------ |
| MaxMemoCharacters       | uint64 | 256    |
| TxSigLimit              | uint64 | 7      |
| TxSizeCostPerByte       | uint64 | 10     |
| SigVerifyCostED25519    | uint64 | 590    |
| SigVerifyCostSecp256k1  | uint64 | 1000   |

## 客户端

### CLI

用户可以使用 CLI 查询和与 `auth` 模块交互。

### 查询

`query` 命令允许用户查询 `auth` 状态。

```bash
simd query auth --help
```

#### account

`account` 命令允许用户通过地址查询账户。

```bash
simd query auth account [address] [flags]
```

示例：

```bash
simd query auth account cosmos1...
```

示例输出：

```bash
'@type': /cosmos.auth.v1beta1.BaseAccount
account_number: "0"
address: cosmos1zwg6tpl8aw4rawv8sgag9086lpw5hv33u5ctr2
pub_key:
  '@type': /cosmos.crypto.secp256k1.PubKey
  key: ApDrE38zZdd7wLmFS9YmqO684y5DG6fjZ4rVeihF/AQD
sequence: "1"
```

#### accounts

`accounts` 命令允许用户查询所有可用账户。

```bash
simd query auth accounts [flags]
```

示例：

```bash
simd query auth accounts
```

Example Output:

```bash
accounts:
- '@type': /cosmos.auth.v1beta1.BaseAccount
  account_number: "0"
  address: cosmos1zwg6tpl8aw4rawv8sgag9086lpw5hv33u5ctr2
  pub_key:
    '@type': /cosmos.crypto.secp256k1.PubKey
    key: ApDrE38zZdd7wLmFS9YmqO684y5DG6fjZ4rVeihF/AQD
  sequence: "1"
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "8"
    address: cosmos1yl6hdjhmkf37639730gffanpzndzdpmhwlkfhr
    pub_key: null
    sequence: "0"
  name: transfer
  permissions:
  - minter
  - burner
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "4"
    address: cosmos1fl48vsnmsdzcv85q5d2q4z5ajdha8yu34mf0eh
    pub_key: null
    sequence: "0"
  name: bonded_tokens_pool
  permissions:
  - burner
  - staking
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "5"
    address: cosmos1tygms3xhhs3yv487phx3dw4a95jn7t7lpm470r
    pub_key: null
    sequence: "0"
  name: not_bonded_tokens_pool
  permissions:
  - burner
  - staking
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "6"
    address: cosmos10d07y265gmmuvt4z0w9aw880jnsr700j6zn9kn
    pub_key: null
    sequence: "0"
  name: gov
  permissions:
  - burner
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "3"
    address: cosmos1jv65s3grqf6v6jl3dp4t6c9t9rk99cd88lyufl
    pub_key: null
    sequence: "0"
  name: distribution
  permissions: []
- '@type': /cosmos.auth.v1beta1.BaseAccount
  account_number: "1"
  address: cosmos147k3r7v2tvwqhcmaxcfql7j8rmkrlsemxshd3j
  pub_key: null
  sequence: "0"
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "7"
    address: cosmos1m3h30wlvsf8llruxtpukdvsy0km2kum8g38c8q
    pub_key: null
    sequence: "0"
  name: mint
  permissions:
  - minter
- '@type': /cosmos.auth.v1beta1.ModuleAccount
  base_account:
    account_number: "2"
    address: cosmos17xpfvakm2amg962yls6f84z3kell8c5lserqta
    pub_key: null
    sequence: "0"
  name: fee_collector
  permissions: []
pagination:
  next_key: null
  total: "0"
```

#### params

`params` 命令允许用户查询当前 auth 参数。

```bash
simd query auth params [flags]
```

示例：

```bash
simd query auth params
```

示例输出：

```bash
max_memo_characters: "256"
sig_verify_cost_ed25519: "590"
sig_verify_cost_secp256k1: "1000"
tx_sig_limit: "7"
tx_size_cost_per_byte: "10"
```

### 交易

`auth` 模块支持交易命令，帮助您进行签名等操作。与其他模块相比，您可以直接使用 `tx` 命令访问 `auth` 模块的交易命令。

直接使用 `--help` 标志获取有关 `tx` 命令的更多信息。

```bash
simd tx --help
```

#### `sign`

`sign` 命令允许用户签署离线生成的交易。

```bash
simd tx sign tx.json --from $ALICE > tx.signed.json
```

结果是已签名的交易，可以通过 broadcast 命令广播到网络。

有关 `sign` 命令的更多信息，可以运行 `simd tx sign --help` 找到。

#### `sign-batch`

`sign-batch` 命令允许用户签署多个离线生成的交易。交易可以在一个文件中，每行一个交易，也可以在多个文件中。

```bash
simd tx sign txs.json --from $ALICE > tx.signed.json
```

或

```bash
simd tx sign tx1.json tx2.json tx3.json --from $ALICE > tx.signed.json
```

结果是多个已签名的交易。要将已签名的交易合并为一个交易，请使用 `--append` 标志。

有关 `sign-batch` 命令的更多信息，可以运行 `simd tx sign-batch --help` 找到。

#### `multi-sign`

`multi-sign` 命令允许用户签署由多签账户离线生成的交易。

```bash
simd tx multisign transaction.json k1k2k3 k1sig.json k2sig.json k3sig.json
```

其中 `k1k2k3` 是多签账户地址，`k1sig.json` 是第一个签名者的签名，`k2sig.json` 是第二个签名者的签名，`k3sig.json` 是第三个签名者的签名。

**嵌套多签交易**

要允许交易由嵌套多签签署，即多签账户的参与者可以是另一个多签账户，必须使用 `--skip-signature-verification` 标志。

```bash
# 首先聚合多签参与者的签名
simd tx multi-sign transaction.json ms1 ms1p1sig.json ms1p2sig.json --signature-only --skip-signature-verification > ms1sig.json

# 然后使用聚合签名和其他签名来签署最终交易
simd tx multi-sign transaction.json k1ms1 k1sig.json ms1sig.json --skip-signature-verification
```

其中 `ms1` 是嵌套多签账户地址，`ms1p1sig.json` 是嵌套多签账户第一个参与者的签名，`ms1p2sig.json` 是嵌套多签账户第二个参与者的签名，`ms1sig.json` 是嵌套多签账户的聚合签名。

`k1ms1` 是由单个签名者和另一个嵌套多签账户（`ms1`）组成的多签账户。`k1sig.json` 是单个成员第一个签名者的签名。

有关 `multi-sign` 命令的更多信息，可以运行 `simd tx multi-sign --help` 找到。

#### `multisign-batch`

`multisign-batch` 的工作方式与 `sign-batch` 相同，但用于多签账户。不同之处在于 `multisign-batch` 命令要求所有交易都在一个文件中，并且不存在 `--append` 标志。

有关 `multisign-batch` 命令的更多信息，可以运行 `simd tx multisign-batch --help` 找到。

#### `validate-signatures`

`validate-signatures` 命令允许用户验证已签名交易的签名。

```bash
$ simd tx validate-signatures tx.signed.json
Signers:
  0: cosmos1l6vsqhh7rnwsyr2kyz3jjg3qduaz8gwgyl8275

Signatures:
  0: cosmos1l6vsqhh7rnwsyr2kyz3jjg3qduaz8gwgyl8275                      [OK]
```

有关 `validate-signatures` 命令的更多信息，可以运行 `simd tx validate-signatures --help` 找到。

#### `broadcast`

`broadcast` 命令允许用户将已签名的交易广播到网络。

```bash
simd tx broadcast tx.signed.json
```

有关 `broadcast` 命令的更多信息，可以运行 `simd tx broadcast --help` 找到。

### gRPC

用户可以使用 gRPC 端点查询 `auth` 模块。

#### Account

`account` 端点允许用户通过地址查询账户。

```bash
cosmos.auth.v1beta1.Query/Account
```

示例：

```bash
grpcurl -plaintext \
    -d '{"address":"cosmos1.."}' \
    localhost:9090 \
    cosmos.auth.v1beta1.Query/Account
```

示例输出：

```bash
{
  "account":{
    "@type":"/cosmos.auth.v1beta1.BaseAccount",
    "address":"cosmos1zwg6tpl8aw4rawv8sgag9086lpw5hv33u5ctr2",
    "pubKey":{
      "@type":"/cosmos.crypto.secp256k1.PubKey",
      "key":"ApDrE38zZdd7wLmFS9YmqO684y5DG6fjZ4rVeihF/AQD"
    },
    "sequence":"1"
  }
}
```

#### Accounts

`accounts` 端点允许用户查询所有可用账户。

```bash
cosmos.auth.v1beta1.Query/Accounts
```

示例：

```bash
grpcurl -plaintext \
    localhost:9090 \
    cosmos.auth.v1beta1.Query/Accounts
```

Example Output:

```bash
{
   "accounts":[
      {
         "@type":"/cosmos.auth.v1beta1.BaseAccount",
         "address":"cosmos1zwg6tpl8aw4rawv8sgag9086lpw5hv33u5ctr2",
         "pubKey":{
            "@type":"/cosmos.crypto.secp256k1.PubKey",
            "key":"ApDrE38zZdd7wLmFS9YmqO684y5DG6fjZ4rVeihF/AQD"
         },
         "sequence":"1"
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos1yl6hdjhmkf37639730gffanpzndzdpmhwlkfhr",
            "accountNumber":"8"
         },
         "name":"transfer",
         "permissions":[
            "minter",
            "burner"
         ]
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos1fl48vsnmsdzcv85q5d2q4z5ajdha8yu34mf0eh",
            "accountNumber":"4"
         },
         "name":"bonded_tokens_pool",
         "permissions":[
            "burner",
            "staking"
         ]
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos1tygms3xhhs3yv487phx3dw4a95jn7t7lpm470r",
            "accountNumber":"5"
         },
         "name":"not_bonded_tokens_pool",
         "permissions":[
            "burner",
            "staking"
         ]
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos10d07y265gmmuvt4z0w9aw880jnsr700j6zn9kn",
            "accountNumber":"6"
         },
         "name":"gov",
         "permissions":[
            "burner"
         ]
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos1jv65s3grqf6v6jl3dp4t6c9t9rk99cd88lyufl",
            "accountNumber":"3"
         },
         "name":"distribution"
      },
      {
         "@type":"/cosmos.auth.v1beta1.BaseAccount",
         "accountNumber":"1",
         "address":"cosmos147k3r7v2tvwqhcmaxcfql7j8rmkrlsemxshd3j"
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos1m3h30wlvsf8llruxtpukdvsy0km2kum8g38c8q",
            "accountNumber":"7"
         },
         "name":"mint",
         "permissions":[
            "minter"
         ]
      },
      {
         "@type":"/cosmos.auth.v1beta1.ModuleAccount",
         "baseAccount":{
            "address":"cosmos17xpfvakm2amg962yls6f84z3kell8c5lserqta",
            "accountNumber":"2"
         },
         "name":"fee_collector"
      }
   ],
   "pagination":{
      "total":"9"
   }
}
```

#### Params

`params` 端点允许用户查询当前 auth 参数。

```bash
cosmos.auth.v1beta1.Query/Params
```

示例：

```bash
grpcurl -plaintext \
    localhost:9090 \
    cosmos.auth.v1beta1.Query/Params
```

示例输出：

```bash
{
  "params": {
    "maxMemoCharacters": "256",
    "txSigLimit": "7",
    "txSizeCostPerByte": "10",
    "sigVerifyCostEd25519": "590",
    "sigVerifyCostSecp256k1": "1000"
  }
}
```

### REST

用户可以使用 REST 端点查询 `auth` 模块。

#### Account

`account` 端点允许用户通过地址查询账户。

```bash
/cosmos/auth/v1beta1/account?address={address}
```

#### Accounts

`accounts` 端点允许用户查询所有可用账户。

```bash
/cosmos/auth/v1beta1/accounts
```

#### Params

`params` 端点允许用户查询当前 auth 参数。

```bash
/cosmos/auth/v1beta1/params
```
