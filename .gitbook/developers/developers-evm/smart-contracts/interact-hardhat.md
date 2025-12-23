# 使用 Hardhat 与智能合约交互

## 前置条件

您应该已经设置了 Hardhat 项目，并成功部署了智能合约。
请参阅[使用 Hardhat 部署智能合约](./deploy-hardhat.md)教程了解如何操作。

可选但强烈建议：您还应该已成功验证了智能合约。
请参阅[使用 Hardhat 验证智能合约](./verify-hardhat.md)教程了解如何操作。

## 启动 Hardhat 控制台

使用以下命令启动交互式 Javascript REPL。

```shell
npx hardhat console --network biya_testnet
```

现在 shell 将是 NodeJs REPL，而不是您常规的 shell（bash、zsh 等）。
在这个 REPL 中，我们将创建 `Counter` 智能合约的实例。
为此，使用 `ethers.getContractFactory(...)` 和 `contract.attach('0x...');`。
例如，如果智能合约部署到 `0x98798cc92651B1876e9Cc91EcBcfe64cac720a1b`，命令应如下所示：

```js
const Counter = await ethers.getContractFactory('Counter');
const counter = await Counter.attach('0x98798cc92651B1876e9Cc91EcBcfe64cac720a1b');
```

请注意，在此 REPL 中，您将看到 `> ` 作为 shell 提示符。
每个提示符的结果输出时不带此前缀。
因此，您的终端内容将类似于：

```js
> const Counter = await ethers.getContractFactory('Counter');
undefined
> const counter = await Counter.attach('0x98798cc92651B1876e9Cc91EcBcfe64cac720a1b');
undefined
```

现在您可以使用 `counter` 与智能合约交互。

## 调用函数 - 查询

查询是只读操作。
因此智能合约状态**不会更新**。
由于*不需要状态更改*，因此不需要钱包、签名或交易费用（gas）。

使用以下命令查询 `value()` 函数。

```js
await counter.value();
```

这应该输出以下内容。

```js
0n
```

{% hint style="info" %}
请注意，`0n` 表示 `0`，`n` 后缀表示它是
[`BigInt`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
而不是 [`Number`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number)。

这是因为 Solidity 的 `uint256`（智能合约中 `value()` 函数的返回类型），
无法用 `Number` 表示，
因为该类型的最大可能整数值是 `2^53 - 1`。
因此需要使用 `BigInt`。
{% endhint %}

## 调用函数 - 交易

交易是写操作。
因此智能合约**状态会更新**。
由于*可能发生状态更改*，交易必须由钱包签名，并且需要支付交易费用（gas）。

使用以下命令交易 `increment(num)` 函数。

```js
await counter.increment(1, { gasPrice: 160e6, gasLimit: 2e6 });
```
{% hint style="info" %}
请注意，gas 价格以 *wei* 为单位。
1 wei = 10^-18 BIYA。
{% endhint %}

如果成功，这应该产生类似以下的结果：

```js
ContractTransactionResponse { ...
```

更新状态后，您可以查询新状态。
结果将反映状态更改。

```js
await counter.value();
```

这次结果应该是 `1n`，因为 `0 + 1 = 1`。

```js
1n
```

## 停止 Hardhat 控制台

连续按两次 `Ctrl+C`，或输入 `.exit` 命令。

## 下一步

恭喜，您已经完成了使用 Hardhat 在 Biya Chain 上开发 EVM 智能合约的整个指南！

智能合约不为非技术用户提供用户体验。
为了满足他们的需求，您需要构建一个去中心化应用程序。
要做到这一点，请查看[您的第一个 dApp](../dapps/README.md) 指南！
