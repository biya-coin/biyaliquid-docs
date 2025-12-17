<!--
order: 2
-->

# 状态

本节概述了 `x/evm` 模块状态中存储的对象、从 go-ethereum `StateDB` 接口派生的功能、通过 Keeper 的实现以及创世时的状态实现。

## 状态对象

`x/evm` 模块在状态中维护以下对象：

### 状态

|             | 描述                                                  | 键                           | 值               | 存储     |
| ----------- | ------------------------------------------------------------ | ----------------------------- | ------------------- | --------- |
| Code        | 智能合约字节码                                      | `[]byte{1} + []byte(address)` | `[]byte{code}`      | KV        |
| Storage     | 智能合约存储                                       | `[]byte{2} + [32]byte{key}`   | `[32]byte(value)`   | KV        |
| Block Bloom | 区块布隆过滤器，用于累积当前区块的布隆过滤器，在区块结束处理器处发出事件。 | `[]byte{1} + []byte(tx.Hash)` | `protobuf([]Log)`   | Transient |
| Tx Index    | 当前区块中当前交易的索引。               | `[]byte{2}`                   | `BigEndian(uint64)` | Transient |
| Log Size    | 当前区块中已发出的日志数量。用于决定后续日志的日志索引。 | `[]byte{3}`                   | `BigEndian(uint64)` | Transient |
| Gas Used    | 当前 cosmos-sdk 交易的以太坊消息使用的 gas 数量，当 cosmos-sdk 交易包含多个以太坊消息时这是必要的。 | `[]byte{4}`                   | `BigEndian(uint64)` | Transient |

## StateDB

`StateDB` 接口由 `x/evm/statedb` 模块中的 `StateDB` 实现，表示用于完整状态查询合约和账户的 EVM 数据库。在以太坊协议中，`StateDB` 用于存储 IAVL 树内的任何内容，并负责缓存和存储嵌套状态。

```go
// github.com/ethereum/go-ethereum/core/vm/interface.go
type StateDB interface {
 CreateAccount(common.Address)

 SubBalance(common.Address, *big.Int)
 AddBalance(common.Address, *big.Int)
 GetBalance(common.Address) *big.Int

 GetNonce(common.Address) uint64
 SetNonce(common.Address, uint64)

 GetCodeHash(common.Address) common.Hash
 GetCode(common.Address) []byte
 SetCode(common.Address, []byte)
 GetCodeSize(common.Address) int

 AddRefund(uint64)
 SubRefund(uint64)
 GetRefund() uint64

 GetCommittedState(common.Address, common.Hash) common.Hash
 GetState(common.Address, common.Hash) common.Hash
 SetState(common.Address, common.Hash, common.Hash)

 Suicide(common.Address) bool
 HasSuicided(common.Address) bool

 // Exist reports whether the given account exists in state.
 // Notably this should also return true for suicided accounts.
 Exist(common.Address) bool
 // Empty returns whether the given account is empty. Empty
 // is defined according to EIP161 (balance = nonce = code = 0).
 Empty(common.Address) bool

 PrepareAccessList(sender common.Address, dest *common.Address, precompiles []common.Address, txAccesses types.AccessList)
 AddressInAccessList(addr common.Address) bool
 SlotInAccessList(addr common.Address, slot common.Hash) (addressOk bool, slotOk bool)
 // AddAddressToAccessList adds the given address to the access list. This operation is safe to perform
 // even if the feature/fork is not active yet
 AddAddressToAccessList(addr common.Address)
 // AddSlotToAccessList adds the given (address,slot) to the access list. This operation is safe to perform
 // even if the feature/fork is not active yet
 AddSlotToAccessList(addr common.Address, slot common.Hash)

 RevertToSnapshot(int)
 Snapshot() int

 AddLog(*types.Log)
 AddPreimage(common.Hash, []byte)

 ForEachStorage(common.Address, func(common.Hash, common.Hash) bool) error
}
```

`x/evm` 中的 `StateDB` 提供以下功能：

### 以太坊账户的 CRUD

您可以从提供的地址创建 `EthAccount` 实例，并使用 `createAccount()` 设置要存储在 `AccountKeeper` 上的值。如果给定地址的账户已存在，此函数还会重置与该地址关联的任何预先存在的代码和存储。

账户的代币余额可以通过 `BankKeeper` 进行管理，可以使用 `GetBalance()` 读取，并使用 `AddBalance()` 和 `SubBalance()` 更新。

- `GetBalance()` 返回所提供地址的 EVM 代币单位余额。代币单位从模块参数获取。
- `AddBalance()` 通过铸造新代币并将其转移到地址，将给定金额添加到地址余额代币。代币单位从模块参数获取。
- `SubBalance()` 通过将代币转移到托管账户然后销毁它们，从地址余额中减去给定金额。代币单位从模块参数获取。如果金额为负数或用户没有足够的资金进行转移，此函数将执行无操作。

nonce（或交易序列）可以通过 auth 模块 `AccountKeeper` 从账户 `Sequence` 获取。

- `GetNonce()` 检索给定地址的账户并返回交易序列（即 nonce）。如果未找到账户，此函数将执行无操作。
- `SetNonce()` 将给定的 nonce 设置为地址账户的序列。如果账户不存在，将从地址创建一个新账户。

包含任意合约逻辑的智能合约字节码存储在 `EVMKeeper` 上，可以使用 `GetCodeHash()`、`GetCode()` 和 `GetCodeSize()` 查询，并使用 `SetCode()` 更新。

- `GetCodeHash()` 从存储中获取账户并返回其代码哈希。如果账户不存在或不是 EthAccount 类型，它返回空代码哈希值。
- `GetCode()` 返回与给定地址关联的代码字节数组。如果账户的代码哈希为空，此函数返回 nil。
- `SetCode()` 将代码字节数组存储到应用程序 KVStore，并将代码哈希设置为给定账户。如果代码为空，则从存储中删除代码。
- `GetCodeSize()` 返回与此对象关联的合约代码大小，如果没有则返回零。

需要跟踪并存储在单独变量中的 gas 退款，以便在 EVM 执行完成后从 gas 使用值中减去/添加到它。退款值在每个交易和每个区块结束时清除。

- `AddRefund()` 将给定数量的 gas 添加到内存中的退款值。
- `SubRefund()` 从内存中的退款值中减去给定数量的 gas。如果 gas 数量大于当前退款，此函数将 panic。
- `GetRefund()` 返回交易执行完成后可用于返回的 gas 数量。此值在每个交易时重置为 0。

状态存储在 `EVMKeeper` 上。可以使用 `GetCommittedState()`、`GetState()` 查询，并使用 `SetState()` 更新。

- `GetCommittedState()` 返回存储中为给定键哈希设置的值。如果未注册键，此函数返回空哈希。
- `GetState()` 返回给定键哈希的内存中脏状态，如果不存在，则从 KVStore 加载已提交的值。
- `SetState()` 将给定的哈希（键、值）设置到状态。如果值哈希为空，此函数从状态中删除键，新值首先保存在脏状态中，最后将提交到 KVStore。

账户也可以设置为自杀状态。当合约自杀时，账户被标记为已自杀，提交时代码、存储和账户被删除（从下一个区块开始）。

- `Suicide()` 将给定账户标记为已自杀并清除 EVM 代币的账户余额。
- `HasSuicided()` 查询内存标志以检查账户是否在当前交易中被标记为已自杀。已自杀的账户在查询期间将作为非 nil 返回，并在区块提交后"清除"。

要检查账户存在性，请使用 `Exist()` 和 `Empty()`。

- `Exist()` 如果给定账户存在于存储中或已被标记为已自杀，则返回 true。
- `Empty()` 如果地址满足以下条件，则返回 true：
  - nonce 为 0
  - evm 代币单位的余额金额为 0
  - 账户代码哈希为空

### EIP2930 功能

支持包含[访问列表](https://eips.ethereum.org/EIPS/eip-2930)的交易类型，该列表包含交易计划访问的地址和存储键列表。访问列表状态保存在内存中，并在交易提交后丢弃。

- `PrepareAccessList()` 处理执行状态转换的准备工作，涉及 EIP-2929 和 EIP-2930。只有在当前编号适用 Yolov3/Berlin/2929+2930 时才应调用此方法。
  - 将发送者添加到访问列表（EIP-2929）
  - 将目标添加到访问列表（EIP-2929）
  - 将预编译添加到访问列表（EIP-2929）
  - 添加可选交易访问列表的内容（EIP-2930）
- `AddressInAccessList()` 如果地址已注册，则返回 true。
- `SlotInAccessList()` 检查地址和插槽是否已注册。
- `AddAddressToAccessList()` 将给定地址添加到访问列表。如果地址已在访问列表中，此函数执行无操作。
- `AddSlotToAccessList()` 将给定的（地址、插槽）添加到访问列表。如果地址和插槽已在访问列表中，此函数执行无操作。

### 快照状态和回滚功能

EVM 使用状态回滚异常来处理错误。这样的异常将撤销当前调用（及其所有子调用）中对状态所做的所有更改，调用者可以处理错误而不传播。您可以使用 `Snapshot()` 用修订版标识当前状态，并使用 `RevertToSnapshot()` 将状态回滚到给定修订版以支持此功能。

- `Snapshot()` 创建新快照并返回标识符。
- `RevertToSnapshot(rev)` 撤销到标识为 `rev` 的快照的所有修改。

Ethermint 采用了 [go-ethereum journal 实现](https://github.com/ethereum/go-ethereum/blob/master/core/state/journal.go#L39) 来支持此功能，它使用日志列表来记录到目前为止完成的所有状态修改操作，快照由唯一 id 和日志列表中的索引组成，要回滚到快照，它只需按相反顺序撤销快照索引之后的日志日志。

### 以太坊交易日志

使用 `AddLog()` 您可以将给定的以太坊 `Log` 追加到与当前状态中保存的交易哈希关联的日志列表中。此函数还在将日志设置到存储之前填充交易哈希、区块哈希、交易索引和日志索引字段。

## Keeper

EVM 模块 `Keeper` 授予对 EVM 模块状态的访问权限，并实现 `statedb.Keeper` 接口以支持 `StateDB` 实现。Keeper 包含一个存储键，允许数据库写入只有 EVM 模块可以访问的多存储的具体子树。不使用 trie 和数据库进行查询和持久化（Ethermint 上的 `StateDB` 实现），而是使用 Cosmos `KVStore`（键值存储）和 Cosmos SDK `Keeper` 来促进状态转换。

为了支持接口功能，它导入了 4 个模块 Keepers：

- `auth`：CRUD 账户
- `bank`：会计（供应）和余额的 CRUD
- `staking`：查询历史区块头
- `fee market`：EIP1559 基础费用，用于在 `ChainConfig` 参数上激活 `London` 硬分叉后处理 `DynamicFeeTx`

```go
type Keeper struct {
 // Protobuf codec
 cdc          codec.Codec
 // Store key required for the EVM Prefix KVStore. It is required by:
 // - storing account's Storage State
 // - storing account's Code
 // - storing module parameters
 storeKey storetypes.StoreKey

 // key to access the object store, which is reset on every block during Commit
 objectKey storetypes.StoreKey

 // the address capable of executing a MsgUpdateParams message. Typically, this should be the x/gov module account.
 authority sdk.AccAddress
 // access to account state
 accountKeeper types.AccountKeeper
 // update balance and accounting operations with coins
 bankKeeper types.BankKeeper
 // access historical headers for EVM state transition execution
 stakingKeeper types.StakingKeeper
 // fetch EIP1559 base fee and parameters
 feeMarketKeeper types.FeeMarketKeeper

 // chain ID number obtained from the context's chain id
 eip155ChainID *big.Int

 // Tracer used to collect execution traces from the EVM transaction execution
 tracer string

 // EVM Hooks for tx post-processing
 hooks types.EvmHooks

 customContractFns []CustomContractFn
}
```

## 创世状态

`x/evm` 模块 `GenesisState` 定义了从先前导出的高度初始化链所需的状态。它包含 `GenesisAccounts` 和模块参数

```go
type GenesisState struct {
  // accounts is an array containing the ethereum genesis accounts.
  Accounts []GenesisAccount `protobuf:"bytes,1,rep,name=accounts,proto3" json:"accounts"`
  // params defines all the parameters of the module.
  Params Params `protobuf:"bytes,2,opt,name=params,proto3" json:"params"`
}
```

## 创世账户

`GenesisAccount` 类型对应于以太坊 `GenesisAccount` 类型的适配。它定义要在创世状态中初始化的账户。

它的主要区别在于 Ethermint 上的账户使用自定义 `Storage` 类型，该类型使用切片而不是映射用于 evm `State`（由于非确定性），并且它不包含私钥字段。

同样重要的是要注意，由于 Cosmos SDK 上的 `auth` 模块管理账户状态，`Address` 字段必须对应于存储在 `auth` 模块 `Keeper`（即 `AccountKeeper`）中的现有 `EthAccount`。

```go
type GenesisAccount struct {
  // address defines an ethereum hex formated address of an account
  Address string `protobuf:"bytes,1,opt,name=address,proto3" json:"address,omitempty"`
  // code defines the hex bytes of the account code.
  Code string `protobuf:"bytes,2,opt,name=code,proto3" json:"code,omitempty"`
  // storage defines the set of state key values for the account.
  Storage Storage `protobuf:"bytes,3,rep,name=storage,proto3,castrepeated=Storage" json:"storage"`
}
```
