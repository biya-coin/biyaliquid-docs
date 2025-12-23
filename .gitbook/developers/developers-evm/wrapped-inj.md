# Wrapped BIYA (wBIYA)

## 什么是包装加密货币？

在 Biya Chain 上，BIYA 是加密货币，用于支付网络上的交易费用。

但是，一些 dApp（包括 DEX）仅在其界面中接受 ERC20 代币，因此 BIYA **不能**与它们一起使用。

解决方案是创建一个包装 BIYA 的 ERC20 代币，称为"wrapped BIYA"。
其代币符号是 **wBIYA**。
因此，任何接受 ERC20 代币的 dApp 都接受 wBIYA。

wBIYA 代币的工作机制很简单：

- 铸造：每当向其中存入 BIYA 时增加总供应量。
- 销毁：每当从中提取 BIYA 时减少总供应量。

您可以将 wBIYA 视为与 BIYA 1:1 抵押的 ERC20 代币，因此被视为等值但具有不同的技术接口。

## wBIYA 与 wETH 相同吗？

对于那些熟悉以太坊的人，
您可能会认为这听起来与包装以太（wETH）相同。
您是对的，到目前为止 wBIYA 的行为方式与 wETH 相同。

但是，请注意 Biya Chain 网络采用多虚拟机技术架构设计。
这意味着如果 wBIYA 使用*标准* ERC20 实现来实现，
就像 wETH 一样，当与 Biya Chain 网络的非 EVM 部分（例如 Cosmos 交易）交互时，
wBIYA 将**无法**访问。

这正是 Biya Chain 的
[多虚拟机代币标准（MTS）](./multivm-token-standard.md)
设计的限制类型。

具体来说，请注意
[这一行](https://github.com/biya-coin/solidity-contracts/blob/b152129a/src/WBIYA9.sol#L9C10-L9C15)：

```solidity
contract WBIYA9 is BankERC20, IWBIYA9 {
```

wBIYA 智能合约不是像 ERC20 实现的典型做法那样在智能合约中将余额存储为 `uint256` 值，
而是使用 `Bank` 预编译合约。
魔法发生在
[`BankERC20` 的 `_update` 函数](https://github.com/biya-coin/solidity-contracts/blob/b152129a/src/BankERC20.sol#L50-L81)中，
其中通过其 [EVM 预编译合约](./bank-precompile.md "Biya Chain 原生 Bank 模块的 EVM 预编译合约")调用 `Bank` 模块中的 `mint`、`burn` 或 `transfer` 函数。

由于这些余额从 `Bank` 预编译合约存储/检索，
它们可以从 Biya Chain 的多虚拟机架构中的其他地方访问。
例如，使用 Cosmos SDK，您可以查询 wBIYA 余额，
即使在通过 EVM 交易更新它们之后；
反之亦然。
我们将此称为"原生链余额"。

查看 [wBIYA 的完整演示](https://github.com/biya-coin/solidity-contracts/tree/master/demos/wbiya9)。

## 如何以编程方式使用 wBIYA

- Biya Chain 主网地址：`0x0000000088827d2d103ee2d9A6b781773AE03FfB`
- Biya Chain 测试网地址：`0x0000000088827d2d103ee2d9A6b781773AE03FfB`

要将 BIYA 转换为 wBIYA，请在此智能合约上调用 `deposit` 函数：

- 函数签名是：`deposit() public payable`
- 请注意，您不需要将金额指定为参数，
  而是在交易上设置 `value`，`payable` 将把它作为 `msg.value` 获取。

要将 wBIYA 转换为 BIYA，请在此智能合约上调用 `withdraw` 函数：

- 函数签名是：`withdraw(uint256 wad) public`
- 将您打算接收的 BIYA 金额设置为 `wad` 参数。

所有其他函数，例如转账，与标准 ERC20 相同。

## 如何通过网络浏览器使用 wBIYA

- Biya Chain 主网浏览器 URL：[`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB?tab=contract)
- Biya Chain 测试网浏览器 URL：[`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://testnet.blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB?tab=contract)

要将 BIYA 转换为 wBIYA，请在此智能合约上调用 `deposit` 函数：

- 导航到浏览器页面中 wBIYA 代币的"Contract"选项卡，然后是"Read/Write contract"子选项卡。
- 找到 `deposit()` 函数，并通过点击 `>` 符号展开它
- 在"Send native BIYA (uint256)"字段中填写您希望转换的 BIYA 金额
  - 请注意，此数字会自动乘以 `10^18`，您不需要手动执行该转换
- 按"Write"按钮
- 在您的钱包中，确认交易以签名并提交。
- 您的钱包应反映 BIYA 减少和 wBIYA 增加您选择的金额。
  - 请注意，BIYA 减少将略多一些，因为它用于支付交易费用。

要将 wBIYA 转换为 BIYA，请在此智能合约上调用 `withdraw` 函数：

- 导航到浏览器页面中 wBIYA 代币的"Contract"选项卡，然后是"Read/Write contract"子选项卡。
- 找到 `withdraw()` 函数，并通过点击 `>` 符号展开它
- 在"wad (uint256)"字段中填写您希望转换的 wBIYA 金额
  - 请注意，此数字会自动乘以 `10^18`，您不需要手动执行该转换
- 按"Write"按钮
- 在您的钱包中，确认交易以签名并提交。
- 您的钱包应反映 BIYA 增加和 wBIYA 减少您选择的金额。
  - 请注意，BIYA 增加将略少一些，因为它用于支付交易费用。

# 如何通过 Biya Chain Do 使用 wBIYA

- 访问 [Biya Chain Do](https://do.biyachain.network/)
- 按右上角的"Connect"按钮
- 选择您的钱包
- 在您的钱包中选择"Allow"以允许它连接到 Biya Chain Do dApp。
- 您现在应该看到您的钱包地址出现在右上角（之前"Connect"按钮所在的位置）
- 在顶部的导航栏中，选择"EVM"
- 在下拉菜单中选择"Wrap/Unwrap"
- 要将 BIYA 转换为 wBIYA
  - 按顶部的"Wrap"选项卡
  - 在"Amount"字段中，输入您想要转换的金额
  - 按底部的"Wrap"按钮
  - 当交易完成时，检查您钱包中的 BIYA 和 wBIYA 余额
- 要将 wBIYA 转换为 BIYA
  - 按顶部的"Unwrap"选项卡
  - 在"Amount"字段中，输入您想要转换的金额
  - 按底部的"Unwrap"按钮
  - 当交易完成时，检查您钱包中的 BIYA 和 wBIYA 余额
