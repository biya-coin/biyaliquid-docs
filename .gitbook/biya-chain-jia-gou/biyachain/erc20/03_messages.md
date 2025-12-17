---
sidebar_position: 3
---

# 消息

在本节中，我们描述 `erc20` 模块消息的处理以及相应的状态更新。

### 创建代币对：`MsgCreateTokenPair`

在现有银行代币单位与新或现有的 ERC20 智能合约之间创建关联。
如果 ERC20 地址为空，将实例化新的 ERC20 智能合约。并非所有银行代币单位都受支持。

验证规则：

- 对于 tokenfactory 代币单位，只有代币单位管理员可以创建代币对
- 对于 peggy 和 IBC 代币单位，任何人都可以创建代币对（仅在 erc20 地址为空时）

```go
type MsgCreateTokenPair struct {
	Sender    string   
	TokenPair TokenPair
}

type TokenPair struct {
	BankDenom    string
	Erc20Address string
}
```

**状态修改：**

- 验证检查：
	- 发送者具有为此代币单位创建代币对的权限（对于 tokenfactory 代币单位，必须是代币单位管理员）
	- 提供的银行代币单位存在且供应量非零
	- 如果提供了 ERC20 地址：
		- 检查合约是否存在，并且实际上是一个 ERC-20 智能合约（通过调用其上的 `symbol()` 方法）
		- 检查现有合约是否已经有关联的银行代币单位且具有流通供应量
- 根据银行代币单位类型创建关联：
	- tokenfactory 代币单位：
		- 如果未提供 ERC-20 地址，实例化新的 `MintBurnBankERC20` 智能合约，否则使用提供的地址
		- 存储关联
	- IBC 和 peggy 代币单位：
		- 实例化新的 `FixedSupplyBankERC20` 智能合约
		- 存储关联

### 删除代币对：`MsgDeleteTokenPair`

目前只有授权机构可以通过提供代币对的银行代币单位来删除代币对。

```go
type MsgDeleteTokenPair struct {
	Sender    string
	BankDenom string
}
```
