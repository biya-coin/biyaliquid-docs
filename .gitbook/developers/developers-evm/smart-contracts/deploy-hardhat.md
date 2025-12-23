# 使用 Hardhat 部署智能合约

## 前置条件

您应该已经设置了 Hardhat 项目，并成功编译了智能合约。
请参阅[设置 Hardhat 并编译智能合约](./compile-hardhat.md)教程了解如何操作。

可选但强烈建议：您还应该已成功测试了智能合约。
请参阅[使用 Hardhat 测试智能合约](./test-hardhat.md)教程了解如何操作。

## 编辑部署脚本

为了让您在计算机上编译的智能合约存在于 Biya Chain 测试网上，需要将其部署到网络上。

为此，我们将使用一个脚本，该脚本使用 Hardhat 预先配置的 `ethers` 实例，使用 `hardhat.config.js` 中指定的值。

打开文件：`script/deploy.js`

```js
async function main() {
    const Counter = await ethers.getContractFactory('Counter');
    const counter = await Counter.deploy({
        gasPrice: 160e6,
        gasLimit: 2e6,
    });
    await counter.waitForDeployment();
    const address = await counter.getAddress();

    console.log('Counter smart contract deployed to:', address);
}
```

回想一下，在编译智能合约后，我们查看了 `artifacts/contracts/Counter.sol/Counter.json`？在此脚本中，`ethers.getContractFactory('Counter')` 检索该文件，并从中提取 ABI 和 EVM 字节码。
接下来的几行使用该信息构造部署交易并将其提交到网络。
如果成功，将输出智能合约部署的地址，例如：
[`0x98798cc92651B1876e9Cc91EcBcfe64cac720a1b`](https://testnet.blockscout.biyachain.network/address/0x98798cc92651B1876e9Cc91EcBcfe64cac720a1b)

请注意，在其他 EVM 网络上，交易（包括部署交易）不需要指定 gas 价格和 gas 限制。但是，目前在 Biya Chain 上这是必需的。

## 运行部署脚本

运行以下命令部署智能合约：

```shell
npx hardhat run script/deploy.js --network biya_testnet
```

复制部署的地址，访问 [`https://testnet.blockscout.biyachain.network`](https://testnet.blockscout.biyachain.network/)，并在搜索字段中粘贴地址。
您将访问刚刚部署的智能合约在区块浏览器中的页面。

如果您点击"Contract"选项卡，您应该看到该合约的 EVM 字节码，它将与编译后的构件目录中找到的 EVM 字节码匹配。

## 下一步

现在您已经部署了智能合约，您已准备好验证该智能合约！
接下来查看[使用 Hardhat 验证智能合约](./verify-hardhat.md)教程。
