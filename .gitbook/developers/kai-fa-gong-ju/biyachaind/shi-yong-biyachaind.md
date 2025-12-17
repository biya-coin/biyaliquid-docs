# 使用 biyachaind

以下页面解释了通过 `biyachaind` (连接到 Biyachain 的命令行界面) 可以做什么。您可以使用 `biyachaind` 与 Biyachain 区块链交互,包括上传智能合约、查询数据、管理质押活动、处理治理提案等。

## 前置条件

### 确保 biyachaind 已安装

有关更多信息,请参阅 [安装 Biyachaind](an-zhuang-biyachaind.md)。如果您已成功安装 `biyachaind`,应该能够运行以下命令:

```bash
biyachaind version
```

请调整您的命令以正确使用主目录。

```bash
biyachaind keys list --home ~/.biyachain
```

### 使用 Docker 化的 CLI

从 Docker 运行时,您必须将主目录挂载到容器。

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

使用 Docker 化的 CLI 添加密钥很简单。

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys add my_key --home /root/.biyachain
```

该命令的详细说明:

* docker 运行镜像 `biya-coin/biyachain-core:v1.14.1`
* `biyachaind` 是在容器内运行 CLI 的命令
* `keys add` 是添加密钥的命令
* `my_key` 是密钥的名称
* `--home /root/.biyachain` 是容器内 CLI 的主目录
* `-v ~/.biyachain:/root/.biyachain` 将主机的 `~/.biyachain` 目录挂载到容器的 `/root/.biyachain` 目录。

它将创建一个密钥对并保存到容器的 `/root/.biyachain/keyring-file` 目录,这与您主机的 `~/.biyachain/keyring-file` 目录相同。

您可以通过运行以下命令列出所有密钥:

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

### 使用 RPC 端点

在访问 Biyachain 区块链之前,您需要有一个正在运行的节点。您可以运行自己的全节点或连接到他人的节点。

要查询状态和发送交易,您必须连接到一个节点,这是访问整个对等连接网络的接入点。您可以运行自己的全节点或连接到他人的节点。

[运行自己的节点](../../../operations/join-a-network.md) 仅适用于高级用户。对于大多数用户,建议连接到公共节点。

要设置 RPC 端点,您可以使用以下命令:

```bash
biyachaind config set client node https://sentry.tm.biyachain.network:443
biyachaind config set client chain-id biyachain-1
```

{% hint style="info" %}
仅对于测试网,您可以使用: `https://k8s.testnet.tm.biyachain.network:443` (chain-id `biyachain-888`)
{% endhint %}

现在尝试查询状态:

```bash
biyachaind q bank balances biya1yu75ch9u6twffwp94gdtf4sa7hqm6n7egsu09s

balances:
- amount: "28748617927330656"
  denom: biya
```

### 常规帮助

有关 `biyachaind` 的更多常规信息,请运行:

```bash
biyachaind --help
```

有关特定 `biyachaind` 命令的更多信息,在命令后附加 `-h` 或 `--help` 标志。例如:

```bash
biyachaind query --help.
```

### 配置 `biyachaind` 客户端

要配置 `biyachaind` 的更多选项,请编辑 `~/.biyachain/config/` 目录中的 `config.toml` 文件。当 keyring-backend 设置为 `file` 时,密钥环文件位于 `~/.biyachain/keyring-file` 目录中。也可以将 keyring-backend 设置为 `test` 或 `os`。对于测试模式,它也将存储为文件 `~/.biyachain/keyring-test`,但不受密码保护。

文件中的所有选项都可以使用 CLI 设置: `biyachaind config set client <option> <value>`。

## 生成、签名和广播交易

运行以下命令将 BIYA 代币从发送者账户发送到接收者账户。`1000biya` 是要发送的 BIYA 代币数量,其中 `1 BIYA = 10^18 biya`,因此 `1000biya` 是一个非常小的数量。

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET
```

执行以下步骤:

* 生成一个包含一个 `Msg` (`x/bank` 的 `MsgSend`) 的交易,并将生成的交易打印到控制台。
* 要求用户确认从 `$MY_WALLET` 账户发送交易。
* 从密钥环获取 `$MY_WALLET`。这是可能的,因为我们在之前的步骤中设置了 CLI 的密钥环。
* 使用密钥环的账户签名生成的交易。
* 将已签名的交易广播到网络。这是可能的,因为 CLI 连接到公共 Biyachain 节点的 RPC 端点。

CLI 将所有必要的步骤打包成简单易用的用户体验。但是,也可以单独运行所有步骤。

### (仅) 生成交易

生成交易只需在任何 `tx` 命令后附加 `--generate-only` 标志即可,例如:

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET --generate-only
```

这将在控制台中以 JSON 格式输出未签名的交易。我们还可以通过在上述命令后附加 `> unsigned_tx.json` 将未签名的交易保存到文件中 (以便更容易在签名者之间传递)。

### 签名预生成的交易

使用 CLI 签名交易需要将未签名的交易保存在文件中。假设未签名的交易在当前目录的 `unsigned_tx.json` 文件中 (请参阅前一段了解如何执行此操作)。然后,只需运行以下命令:

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET
```

此命令将解码未签名的交易,并使用我们已在密钥环中设置的 `MY_WALLET` 的密钥以 `SIGN_MODE_DIRECT` 模式对其进行签名。已签名的交易将以 JSON 格式输出到控制台,如上所述,我们可以通过在命令行后附加 `> signed_tx.json` 将其保存到文件中。

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET > signed_tx.json
```

`tx sign` 命令中需要考虑的一些有用标志:

* `--sign-mode`: 您可以使用 `amino-json` 以 `SIGN_MODE_LEGACY_AMINO_JSON` 模式签名交易,
* `--offline`: 离线签名模式。这意味着 `tx sign` 命令不会连接到节点来检索签名者的账户号码和序列号,这两者都是签名所需的。在这种情况下,您必须手动提供 `--account-number` 和 `--sequence` 标志。这对于离线签名很有用,即在无法访问互联网的安全环境中签名。

### 使用多签名者签名 (多重签名)

使用多个签名者签名通过 `tx multi-sign` 命令完成。此命令假定所有签名者都使用 `SIGN_MODE_LEGACY_AMINO_JSON`。流程类似于 `tx sign` 命令流程,但每个签名者不是签名未签名的交易文件,而是签名前一个签名者签名的文件。`tx multi-sign` 命令将把签名附加到现有交易中。重要的是签名者必须**按照相同的顺序**签名交易,该顺序由交易给出,可以使用 `GetSigners()` 方法检索。

例如,从 `unsigned_tx.json` 开始,假设交易有 4 个签名者,我们将运行:

```bash
# 让 signer1 签名未签名的交易。
biyachaind tx multi-sign unsigned_tx.json signer_key_1 > partial_tx_1.json
# 现在 signer1 将 partial_tx_1.json 发送给 signer2。
# Signer2 附加他们的签名:
biyachaind tx multi-sign partial_tx_1.json signer_key_2 > partial_tx_2.json
# Signer2 将 partial_tx_2.json 文件发送给 signer3,signer3 可以附加他的签名:
biyachaind tx multi-sign partial_tx_2.json signer_key_3 > partial_tx_3.json
```

### 广播交易

广播交易使用以下命令完成:

```bash
biyachaind tx broadcast tx_signed.json
```

您可以选择传递 `--broadcast-mode` 标志来指定从节点接收哪种响应:

* `block`: CLI 等待交易包含在区块中。
* `sync`: CLI 仅等待 CheckTx 执行响应,手动查询交易结果以确保其已包含。
* `async`: CLI 立即返回 (交易可能失败) - 不要使用。

要查询交易结果,您可以使用以下命令:

```bash
biyachaind tx query TX_HASH
```

## 其他故障排除

有时配置设置不正确。您可以通过在命令行中添加以下内容来强制使用正确的节点 RPC 端点。与他人共享命令时,建议在命令行中明确设置所有标志。(chain-id、node、keyring-backend 等)

```bash
biyachaind --node https://sentry.tm.biyachain.network:443
```
