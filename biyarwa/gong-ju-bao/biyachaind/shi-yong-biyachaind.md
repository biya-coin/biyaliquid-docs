# 使用 biyachaind

以下页面介绍了如何使用 `biyachaind`，这是一个连接到 Biyachain 的命令行界面。您可以使用 `biyachaind` 与 Biyachain 区块链交互，例如上传智能合约、查询数据、管理质押活动、处理治理提案等。

## 前置条件

### 确保已安装 biyachaind

请参阅 [安装 injectived](an-zhuang-biyachaind.md) 获取更多信息。如果您已成功安装 `biyachaind`，您应该能够运行以下命令：

```bash
biyachaind version
```

请调整您的命令以正确使用主目录。

```bash
biyachaind keys list --home ~/.injective
```

### 使用 Docker 化的 CLI

如果从 Docker 运行，您需要将主目录挂载到容器中。

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

使用 Docker 化的 CLI 添加密钥很简单。

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys add my_key --home /root/.biyachain
```

以下是该命令的解析：

* `docker` 运行镜像 `biya-coin/biyachain-core:v1.14.1`。
* `biyachaind` 是在容器内运行 CLI 的命令。
* `keys add` 是用于添加密钥的命令。
* `my_key` 是密钥的名称。
* `--home /root/.biyachain` 指定 CLI 在容器内的主目录。
* `-v ~/.biyachain:/root/.biyachain` 将主机的 `~/.biyachain` 目录挂载到容器的 `/root/.biyachain` 目录。

此命令将创建一个密钥对，并将其保存到容器的 `/root/.biyachain/keyring-file` 目录，该目录与主机的 `~/.biyachain/keyring-file` 目录相同。

你可以运行以下命令列出所有密钥：

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

### 使用 RPC 端点

在访问 Biyachain 区块链之前，你需要运行一个节点。你可以选择运行自己的完整节点，或者连接到其他人的节点。

要查询状态并发送交易，你必须连接到一个节点，它是整个网络的访问入口。你可以选择运行自己的完整节点，或者连接到其他人的节点。

[运行自己的节点](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)仅适用于高级用户。对于大多数用户，建议连接到公共节点。

要设置 RPC 端点，你可以使用以下命令：

```bash
biyachaind config set client node https://sentry.tm.biyachain.network:443
biyachaind config set client chain-id biyachain-1
```

{% hint style="info" %}
对于使用测试网，您可以使用: `https://k8s.testnet.tm.biyachain.network:443` (chain-id `biyachain-888`)
{% endhint %}

现在试着查询状态:

```bash
biyachaind q bank balances biya1yu75ch9u6twffwp94gdtf4sa7hqm6n7egsu09s

balances:
- amount: "28748617927330656"
  denom: biya
```

### 通用帮助

关于使用 `biyachaind 的通用信息`, 运行:

```bash
biyachaind --help
```

要获取有关特定 `biyachaind` 命令的更多信息，可以在命令后附加 `-h` 或 `--help` 标志。例如：

```bash
biyachaind query --help.
```

### 配置 `biyachaind` 客户端

要配置 `biyachaind` 的更多选项，请编辑 `~/.biyachain/config/` 目录中的 `config.toml` 文件。当 `keyring-backend` 设置为 `file` 时，密钥存储文件位于 `~/.biyachain/keyring-file` 目录中。此外，`keyring-backend` 也可以设置为 `test` 或 `os`。\
如果设置为 `test`，密钥将存储在 `~/.biyachain/keyring-test` 文件中，但不会受密码保护。

配置文件中的所有选项都可以使用 CLI 进行设置：\
`biyachaind config set client <option> <value>`

## 生成, 签名, 和广播交易

运行以下命令可将 BIYA 代币从发送方账户转账至接收方账户。`1000biya` 表示要发送的 BIYA 代币数量，其中 1 BIYA = 10¹⁸ biya，因此 `1000biya` 是一个非常小的数额。

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET
```

以下步骤被执行：

1. 生成一个包含 `MsgSend`（`x/bank` 的 `MsgSend`）的交易，并在控制台打印生成的交易。
2. 请求用户确认是否从 `$MY_WALLET` 账户发送交易。
3. 从密钥存储（keyring）中获取 `$MY_WALLET`，这可以实现是因为在前面的步骤中已设置 CLI 的密钥存储。
4. 使用密钥存储中的账户对生成的交易进行签名。
5. 将已签名的交易广播到网络，这可以实现是因为 CLI 连接到了 Biyachain 公共节点的 RPC 端点。

CLI 将所有必要的步骤整合在一起，提供了简洁易用的用户体验。但也可以分别运行每个步骤来完成交易。

### (仅) 生成一个交易

生成交易可以通过在任何交易命令后添加 `--generate-only` 标志来简单完成，例如：

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET --generate-only
```

这将把未签名的交易以 JSON 格式输出到控制台。我们还可以通过在上述命令后添加 `> unsigned_tx.json` 将未签名的交易保存到文件中（以便在签名者之间更方便地传递）。

### 对一个预生成的交易签名

使用 CLI 签名交易需要将未签名的交易保存到文件中。假设未签名的交易保存在当前目录中的一个名为 `unsigned_tx.json` 的文件中（参考前一段了解如何操作）。然后，只需运行以下命令：

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET
```

此命令将解码未签名的交易，并使用我们在密钥存储中已经设置的 MY\_WALLET 的密钥以 `SIGN_MODE_DIRECT` 模式对其进行签名。签名后的交易将以 JSON 格式输出到控制台，像上面一样，我们可以通过在命令后添加 `> signed_tx.json` 将其保存到文件中。

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET > signed_tx.json
```

在 `tx sign` 命令中，有一些有用的标志可以考虑：

* `--sign-mode`：你可以使用 `amino-json` 来通过 `SIGN_MODE_LEGACY_AMINO_JSON` 签名交易。
* `--offline`：在离线模式下签名。这意味着 `tx sign` 命令不会连接到节点以获取签名者的账户号码和序列号，这两个信息在签名时需要。在这种情况下，你必须手动提供 `--account-number` 和 `--sequence` 标志。这对于离线签名非常有用，例如在没有互联网连接的安全环境中进行签名。

### 多个签名者签名 (多签)

使用多个签名者进行签名是通过 `tx multi-sign` 命令完成的。此命令假设所有签名者使用 `SIGN_MODE_LEGACY_AMINO_JSON`。其流程与 `tx sign` 命令类似，但不同之处在于，代替签署未签名的交易文件，每个签名者都会签署前一个签名者签署过的文件。`tx multi-sign` 命令将签名附加到现有的交易上。重要的是，签名者必须按照交易中给定的顺序签署交易，可以通过 `GetSigners()` 方法检索该顺序。

例如，从 `unsigned_tx.json` 开始，假设交易有 4 个签名者，我们将运行：

```bash
# Let signer1 sign the unsigned tx.
biyachaind tx multi-sign unsigned_tx.json signer_key_1 > partial_tx_1.json
# Now signer1 will send the partial_tx_1.json to the signer2.
# Signer2 appends their signature:
biyachaind tx multi-sign partial_tx_1.json signer_key_2 > partial_tx_2.json
# Signer2 sends the partial_tx_2.json file to signer3, and signer3 can append his signature:
biyachaind tx multi-sign partial_tx_2.json signer_key_3 > partial_tx_3.json
```

### 广播一个交易

广播交易是通过以下命令完成的：

```bash
biyachaind tx broadcast tx_signed.json
```

你可以选择性地传递 `--broadcast-mode` 标志来指定从节点接收哪种响应：

* `block`：CLI 等待交易被包含在区块中。
* `sync`：CLI 仅等待 `CheckTx` 执行响应，手动查询交易结果以确保它已被包含。
* `async`：CLI 立即返回（交易可能失败）- **不要使用**。

要查询交易结果，你可以使用以下命令：

```bash
biyachaind tx query TX_HASH
```

## 额外的故障排查

有时候配置可能没有正确设置。你可以通过在命令行中添加以下内容来强制使用正确的节点 RPC 端点。在与他人分享命令时，建议在命令行中明确设置所有标志（如 `chain-id`、`node`、`keyring-backend` 等）。

```bash
biyachaind --node https://sentry.tm.injective.network:443
```
