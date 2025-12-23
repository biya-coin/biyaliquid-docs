# 使用 Foundry 验证智能合约

## 前置条件

您应该已经设置了 Foundry 项目，并成功部署了智能合约。
请参阅[使用 Foundry 部署智能合约](./deploy-foundry.md)教程了解如何操作。

## 什么是智能合约验证？

验证过程对智能合约本身或网络的任何其他状态没有任何影响。

相反，这是一个标准化过程，通过该过程向网络浏览器提供部署在特定地址的智能合约的原始源代码。网络浏览器**独立编译**该源代码，并验证生成的字节码确实与智能合约部署交易中的字节码**匹配**。

如果验证通过（有匹配），区块浏览器会为该特定智能合约的页面"解锁"增强模式。
现在显示更多智能合约详细信息，包括：
* 完整源代码（Solidity）
* ABI（JSON）
* 交易和事件以更高的详细程度显示（使用 ABI 解析）

此外，如果用户连接他们的钱包，他们可以在网络浏览器本身内调用函数来查询智能合约，甚至发送交易来更新其状态。

<!-- TODO consider moving this section to FAQs -->

## 运行验证命令

输入以下命令：

```shell
forge verify-contract \
  --rpc-url biyachainEvm \
  --verifier blockscout \
  --verifier-url 'https://testnet.blockscout-api.biyachain.network/api/' \
  ${SC_ADDRESS} \
  src/Counter.sol:Counter
```

将 `${SC_ADDRESS}` 替换为您部署智能合约的地址。

例如，如果智能合约地址是 `0x213bA803265386C10CE04a2cAa0f31FF3440b9cF`，命令是：

```shell
forge verify-contract \
  --rpc-url biyachainEvm \
  --verifier blockscout \
  --verifier-url 'https://testnet.blockscout-api.biyachain.network/api/' \
  0x213bA803265386C10CE04a2cAa0f31FF3440b9cF \
  src/Counter.sol:Counter
```

## 检查验证结果

您应该在终端中看到类似以下的输出：

```text
Start verifying contract `0x213bA803265386C10CE04a2cAa0f31FF3440b9cF` deployed on 1439
Submitting verification for [src/Counter.sol:Counter] 0x213bA803265386C10CE04a2cAa0f31FF3440b9cF.
Submitted contract for verification:
        Response: `OK`
        GUID: `213ba803265386c10ce04a2caa0f31ff3440b9cf686b778c`
        URL: https://testnet.blockscout-api.biyachain.network/address/0x213ba803265386c10ce04a2caa0f31ff3440b9cf
```

更有趣的结果是访问网络浏览器。
从验证输出中访问网络浏览器 URL。
然后选择"Contract"选项卡。
然后选择"Code"子选项卡。
以前，只有"ByteCode"可用，
现在"Code"、"Compiler"和"ABI"也可用了。

仍然在"Contract"选项卡中，
选择"Read/Write contract"子选项卡。
以前，这不存在，
但现在您可以直接从区块浏览器与每个智能合约函数交互。

## 下一步

现在您已经部署并验证了智能合约，您已准备好与该智能合约交互！
接下来查看[使用 Foundry 与智能合约交互](./interact-foundry.md)教程。
