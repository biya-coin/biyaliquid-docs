# Exchange 预编译合约

Exchange 预编译合约是一个驻留在固定地址 `0x0000000000000000000000000000000000000065` 的系统智能合约。它为 Solidity 开发者提供了一个节省 gas 且原生的途径，可以直接与 Biya Chain 链的 exchange 模块交互。通过利用此预编译合约，您的智能合约可以无缝执行各种与交易所相关的操作，包括：

* 向子账户存入和提取资金。
* 下单或取消现货和衍生品订单。
* 查询子账户余额和未平仓头寸。
* 管理其他账户或合约的授权授予。

#### 调用预编译合约：直接访问与代理访问

与 Exchange 预编译合约交互可以通过两种主要方式进行：

**1. 直接访问（自调用合约）**

在此模式下，您的智能合约代表自己与预编译合约交互。合约本身是在 exchange 模块上执行操作的参与者，使用自己的资金并管理自己的头寸。

_示例：_

```
exchange.deposit(address(this), subaccountID, denom, amount);  
```

这种方法很简单，**不需要显式授权授予**，因为合约本质上有权管理自己的资源。

**2. 代理访问（代表另一个用户调用）**

智能合约也可以被设计为中介，代表外部用户账户执行交易所操作。在这种情况下，合约调用预编译合约，指定第三方的地址作为发送者或要操作的账户。

_示例：_

```
exchange.deposit(userAddress, subaccountID, denom, amount);  
```

为了成功，智能合约（`grantee`）**必须由用户（`userAddress`，即 `granter`）明确授权**执行指定的操作。此授权使用预编译合约提供的 `approve` 和 `revoke` 方法进行管理。**谨慎处理这些授权以确保用户资金安全至关重要。**

要授权合约代表您执行特定操作：

```
exchange.approve(grantee, msgTypes, spendLimit, duration);  
```

* `grantee`：被授权的合约地址。
* `msgTypes`：`grantee` 被授权执行的消息类型数组（例如，`MsgCreateDerivativeLimitOrder`、`MsgDeposit`）。有关完整列表，请参阅 `ExchangeTypes.sol` 或 Biya Chain 协议 protobuf 定义。
* `spendLimit`：`Cosmos.Coin` 结构数组，定义 `grantee` 每个消息类型或整个授予可以使用的指定代币的最大数量。
* `duration`：授权保持有效的时间段（以秒为单位）。

要撤销先前授予的授权：

```
exchange.revoke(grantee, msgTypes);  
```

要检查授权当前是否存在：

```
exchange.allowance(grantee, granter, msgType);  
```

#### 示例：直接方法

下面的 `ExchangeDemo` 合约说明了智能合约如何使用直接访问方法。它执行基本的交易所操作，如存入资金、提取资金、创建衍生品限价订单和查询子账户头寸，所有这些都使用自己的子账户和资金。

`Exchange.sol` 和 `ExchangeTypes.sol` 文件包含与预编译合约交互所需的接口定义和数据结构。这些通常在官方 Biya Chain Solidity 合约仓库中可用，或者可以作为依赖项包含在您的项目中。

```solidity
// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.4;  
  
import "../src/Exchange.sol"; // 包含 IExchangeModule 接口  
import "../src/ExchangeTypes.sol"; // 包含必要的结构，如 DerivativeOrder  
  
contract ExchangeDemo {  
    address constant exchangeContract = 0x0000000000000000000000000000000000000065;  
    IExchangeModule exchange = IExchangeModule(exchangeContract);  
  
    /***************************************************************************  
     * 直接调用预编译合约（合约代表自己行事）  
    ****************************************************************************/  
  
    /**  
     * @notice 从合约的余额中将资金存入其交易所子账户之一。  
     * @param subaccountID 目标子账户 ID（从合约地址派生）。  
     * @param denom 要存入的资产面额（例如，"biya"）。  
     * @param amount 要存入的资产数量。  
     * @return success 指示存款是否成功的布尔值。  
     */  
    function deposit(  
        string calldata subaccountID,  
        string calldata denom,  
        uint256 amount  
    ) external returns (bool) {  
        try exchange.deposit(address(this), subaccountID, denom, amount) returns (bool success) {  
            return success;  
        } catch Error(string memory reason) {  
            revert(string(abi.encodePacked("Deposit error: ", reason)));  
        } catch {  
            revert("Unknown error during deposit");  
        }  
    }  
  
    /**  
     * @notice 从合约的交易所子账户之一提取资金到其主余额。  
     * @param subaccountID 源子账户 ID。  
     * @param denom 要提取的资产面额。  
     * @param amount 要提取的资产数量。  
     * @return success 指示提取是否成功的布尔值。  
     */  
    function withdraw(  
        string calldata subaccountID,  
        string calldata denom,  
        uint256 amount  
    ) external returns (bool) {  
        try exchange.withdraw(address(this), subaccountID, denom, amount) returns (bool success) {  
            return success;  
        } catch Error(string memory reason) {  
            revert(string(abi.encodePacked("Withdraw error: ", reason)));  
        } catch {  
            revert("Unknown error during withdraw");  
        }  
    }  
  
    /**  
     * @notice 查询此合约给定子账户的衍生品头寸。  
     * @param subaccountID 要查询的子账户 ID。  
     * @return positions DerivativePosition 结构数组。  
     */  
    function subaccountPositions(  
        string calldata subaccountID  
    ) external view returns (IExchangeModule.DerivativePosition[] memory positions) {  
        // 注意：调用预编译合约的视图函数可能会根据节点配置而有所不同  
        // 对于链上状态，这很好。对于链外查询，通常首选直接 gRPC/API 查询。  
        return exchange.subaccountPositions(subaccountID);  
    }  
  
    /**  
     * @notice 从合约的子账户创建新的衍生品限价订单。  
     * @param order 包含订单详细信息的 DerivativeOrder 结构。  
     * @return response 包含订单哈希等详细信息的响应结构。  
     */  
    function createDerivativeLimitOrder(  
        IExchangeModule.DerivativeOrder calldata order  
    ) external returns (IExchangeModule.CreateDerivativeLimitOrderResponse memory response) {  
        try exchange.createDerivativeLimitOrder(address(this), order) returns (IExchangeModule.CreateDerivativeLimitOrderResponse memory resp) {  
            return resp;  
        } catch Error(string memory reason) {  
            revert(string(abi.encodePacked("CreateDerivativeLimitOrder error: ", reason)));  
        } catch {  
            revert("Unknown error during createDerivativeLimitOrder");  
        }  
    }  
}  
```

#### 开始构建

有关如何构建、部署和与此 `ExchangeDemo` 智能合约交互的详细说明，包括设置子账户和资金，请参阅我们 [solidity-contracts](https://github.com/biya-coin/solidity-contracts/tree/master/demos/exchange) 仓库中提供的综合演示。

#### 结论

Exchange 预编译合约是一个强大的工具，使复杂的、协议集成的交易逻辑能够直接嵌入到 Biya Chain 上的智能合约中。无论您的合约是管理自己的投资组合还是充当其他用户的多功能交易接口（通过带有 `approve` 和 `revoke` 的代理模式），此预编译合约都提供了一种干净、安全且高效的方法，可以使用 Solidity 与核心 exchange 模块交互。

请记住，对于自包含的合约逻辑优先使用直接调用，并在为更广泛的 Biya Chain 生态系统构建可重用的合约接口时，使用强大的授权谨慎实现代理模式。

\
