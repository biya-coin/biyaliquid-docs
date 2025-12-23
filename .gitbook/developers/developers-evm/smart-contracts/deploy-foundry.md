# 使用 Foundry 部署智能合约

## 前置条件

您应该已经设置了 Foundry 项目，并成功编译了智能合约。
请参阅[设置 Foundry 并编译智能合约](./compile-foundry.md)教程了解如何操作。

可选但强烈建议：您还应该已成功测试了智能合约。
请参阅[使用 Foundry 测试智能合约](./test-foundry.md)教程了解如何操作。

## 运行部署

运行以下命令部署智能合约：

```shell
forge create \
  src/Counter.sol:Counter \
  --rpc-url biyachainEvm \
  --legacy \
  --account biyaTest \
  --gas-price 160000000 \
  --gas-limit 2000000 \
  --broadcast
```

{% hint style="info" %}
请注意，我们使用的是保存到密钥库的 `biyaTest` 账户，
该账户之前在[设置 Foundry 并编译智能合约](./compile-foundry.md)中设置。
{% endhint %}

输出应类似于：

```text
Enter keystore password:
Deployer: 0x58f936cb685Bd6a7dC9a21Fa83E8aaaF8EDD5724
Deployed to: 0x213bA803265386C10CE04a2cAa0f31FF3440b9cF
Transaction hash: 0x6aa9022f593083c7779da014a3032efd40f3faa2cf3473f4252a8fbd2a80db6c
```

复制部署的地址，访问 [`https://testnet.blockscout.biyachain.network`](https://testnet.blockscout.biyachain.network/)，并在搜索字段中粘贴地址。
您将访问刚刚部署的智能合约在区块浏览器中的页面。

如果您点击"Contract"选项卡，您应该看到该合约的 EVM 字节码，它将与编译后的构件目录中找到的 EVM 字节码匹配。

## 下一步

现在您已经部署了智能合约，您已准备好验证该智能合约！
接下来查看[使用 Foundry 验证智能合约](./verify-foundry.md)教程。
