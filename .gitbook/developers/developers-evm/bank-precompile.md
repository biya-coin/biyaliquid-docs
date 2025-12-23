# Bank 预编译合约

Bank 预编译合约是一个驻留在固定地址 `0x0000000000000000000000000000000000000064` 的系统智能合约。

它为 EVM 开发者提供了一个节省 gas 且原生的途径，可以直接与 Biya Chain 的 **bank 模块**（`x/bank`）交互。这有效地将 ERC-20 代币带到链上。任何使用 Bank 预编译合约的 ERC-20 合约都将在链上表示为 `erc20:0x...` 面额。从技术上讲，这意味着代币仅驻留在链上，EVM 提供对链状态的视图，而不是维护单独的副本。与传统桥接不同，传统桥接中两个代币版本需要用户操作才能切换，Bank 预编译合约为使用链上 bank 面额或 ERC-20 `transfer()` 方法的任何转账提供实时的双环境反映。

[Biya Chain 的 Solidity 合约仓库](https://github.com/biya-coin/solidity-contracts)提供了一系列由 Bank 预编译合约支持的 ERC-20 实现，以及预编译合约接口和抽象合约。关键合约包括：

* **Bank.sol** – 预编译合约接口
* **BankERC20.sol** – 由 Bank 预编译合约支持的抽象 ERC20 实现
* **FixedSupplyBankERC20.sol** – 固定供应的去中心化 ERC20（无所有者，无铸造或销毁）
* **MintBurnBankERC20.sol** – 具有授权铸造和销毁代币的所有者的 ERC20

这些实现基于 OpenZeppelin 的 ERC20 合约。开发者可以自由创建利用 Bank 预编译合约的自定义 ERC20 合约。

## ERC20 合约部署

**ℹ️ 注意：**

为了防止面额垃圾邮件，通过 ERC20 模块部署 ERC20 合约是一个**付费操作**，需要支付 **1 BIYA** 的部署费用。确保您的 ERC20 合约部署交易包含此金额，否则操作将被拒绝。

## Bank 预编译合约接口

<pre class="language-solidity" data-full-width="false"><code class="lang-solidity"><strong>interface IBankModule {
</strong>    function mint(address,uint256) external payable returns (bool);
    function balanceOf(address,address) external view returns (uint256);
    function burn(address,uint256) external payable returns (bool);
    function transfer(address,address,uint256) external payable returns (bool);
    function totalSupply(address) external view returns (uint256);
    function metadata(address) external view returns (string memory,string memory,uint8);
    function setMetadata(string memory,string memory,uint8) external payable returns (bool);
}
</code></pre>

## 示例

[Wrapped BIYA (wBIYA)](../../developers-evm/wrapped-biya.md#is-wbiya-the-same-as-weth) 使用 Bank EVM 预编译合约来实现[多虚拟机代币标准（MTS）](multivm-token-standard.md)。

## 开始构建

我们准备了一些演示，展示如何使用 Bank、Exchange 和 Staking 预编译合约构建合约。这些示例还演示了如何使用最常见的以太坊开发框架 **Foundry** 与 Biya Chain EVM 交互。

在[这里](https://github.com/biya-coin/solidity-contracts/tree/master/demos/erc20)查看 bank 预编译合约演示并遵循相应的 README。
