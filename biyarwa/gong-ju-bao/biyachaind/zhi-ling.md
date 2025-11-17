# 指令

本节描述了 `biyachaind` 提供的命令，这是连接运行中的 `biyachaind` 进程（节点）的命令行界面。

{% hint style="info" %}
一些 `biyachaind` 命令需要子命令、参数或标志才能运行。要查看这些信息，可以在命令后添加 `--help` 或 `-h` 标志。有关帮助标志的使用示例，请参见 `query` 或 `tx`。

对于 `chain-id` 参数，主网应使用 `biyachain-1`，测试网应使用 `biyachain-888`。
{% endhint %}

### `add-genesis-account`

将一个创世账户添加到 `genesis.json` 文件中。有关 `genesis.json` 的更多信息，请参阅加入测试网或[加入主网](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)指南。

**语法**

```
biyachaind add-genesis-account <address-or-key-name> <amount><coin-denominator>
```

**例子**

```bash
biyachaind add-genesis-account acc1 100000000000biya
```

### `collect-gentxs`

收集创世交易并将其输出到 `genesis.json` 文件中。有关 `genesis.json` 的更多信息，请参阅加入测试网或[加入主网](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)指南。

**语法**

```bash
biyachaind collect-gentxs
```

### `debug`

用于调试应用程序。要查看语法和子命令列表，请在 `debug` 命令后添加 `--help` 或 `-h` 标志运行：

```bash
biyachaind debug -h
```

子命令:

```bash
biyachaind debug [subcommand]
```

* `addr`：在十六进制（hex）和 bech32 地址格式之间转换。
* `pubkey`：从 proto JSON 解码公钥。
* `raw-bytes`：将原始字节输出（例如 `[72 101 108 108 111 44 32 112 108 97 121 103 114 111 117 110 100]`）转换为十六进制（hex）。

### `export`

将状态导出为 JSON。

**语法**

```bash
biyachaind export
```

### `gentx`

将创世交易添加到 `genesis.json` 文件中。有关 `genesis.json` 的更多信息，请参阅加入测试网或[加入主网](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)指南。

{% hint style="info" %}
**Note:** `gentx` 命令提供了多个可用的标志。运行 `gentx` 命令并添加 `--help` 或 `-h` 以查看所有标志。
{% endhint %}

**语法**

```bash
biyachaind gentx <key-name> <amount><coin-denominator>
```

**例子**

```bash
biyachaind gentx myKey 100000000000biya --home=/path/to/home/dir --keyring-backend=os --chain-id=biyachain-1 \
    --moniker="myValidator" \
    --commission-max-change-rate=0.01 \
    --commission-max-rate=1.0 \
    --commission-rate=0.07 \
    --details="..." \
    --security-contact="..." \
    --website="..."
```

### `help`

显示可用命令的概览。

**语法**

```bash
biyachaind help
```

### `init`

初始化节点的配置文件。

**语法**

```bash
biyachaind init <moniker>
```

**例子**

```bash
biyachaind init myNode
```

### `keys`

管理 Keyring 相关命令。这些密钥可以采用 Tendermint 加密库支持的任何格式，并可用于轻客户端、全节点或其他需要使用私钥签名的应用程序。

要查看语法和子命令列表，请在 `keys` 命令后添加 `--help` 或 `-h` 标志运行：

```bash
biyachaind keys -h
```

子命令:

```bash
biyachaind keys [subcommand]
```

* `add`：添加加密的私钥（新生成或恢复的），加密后保存到指定文件。
* `delete`：删除指定的密钥。
* `export`：导出私钥。
* `import`：将私钥导入本地 Keybase。
* `list`：列出所有密钥。
* `migrate`：将密钥从旧版（基于数据库的）Keybase 迁移。
* `mnemonic`：根据输入的熵计算 BIP39 助记词。
* `parse`：在十六进制（hex）和 bech32 地址格式之间解析转换。
* `show`：通过名称或地址检索密钥信息。
* `unsafe-export-eth-key`：以明文形式导出 Ethereum 私钥。
* `unsafe-import-eth-key`：将 Ethereum 私钥导入本地 Keybase。

\
`migrate`

将源创世数据迁移到目标版本，并打印到标准输出（STDOUT）。有关 `genesis.json` 的更多信息，请参阅加入测试网或[加入主网](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)指南。

**语法**

```bash
biyachaind migrate <target version> <path-to-genesis-file>
```

**例子**

```bash
biyachaind migrate v1.9.0 /path/to/genesis.json --chain-id=biyachain-888 --genesis-time=2023-03-07T17:00:00Z 
```

### `query`

管理查询命令。要查看语法和子命令列表，请在 `query` 子命令后添加 `--help` 或 `-h` 标志运行：

```bash
biyachaind query -h
```

子命令:

```bash
biyachaind query [subcommand]
```

* `account`：通过地址查询账户。
* `auction`：拍卖模块的查询命令。
* `auth`：身份验证模块的查询命令。
* `authz`：授权模块的查询命令。
* `bank`：银行模块的查询命令。
* `block`：获取指定高度区块的验证数据。
* `chainlink`：预言机模块的查询命令。
* `distribution`：分发模块的查询命令。
* `evidence`：根据哈希或查询所有（分页）提交的证据。
* `exchange`：交换模块的查询命令。
* `feegrant`：费用授权模块的查询命令。
* `gov`：治理模块的查询命令。
* `ibc`：IBC 模块的查询命令。
* `ibc-fee`：IBC 中继激励查询子命令。
* `ibc-transfer`：IBC 同质化代币转账查询子命令。
* `insurance`：保险模块的查询命令。
* `interchain-accounts`：跨链账户子命令。
* `mint`：铸币模块的查询命令。
* `oracle`：预言机模块的查询命令。
* `params`：参数模块的查询命令。
* `peggy`：Peggy 模块的查询命令。
* `slashing`：惩罚模块的查询命令。
* `staking`：质押模块的查询命令。
* `tendermint-validator-set`：获取给定高度的完整 Tendermint 验证者集合。
* `tokenfactory`：代币工厂模块的查询命令。
* `tx`：通过哈希、账户序列或已提交区块中的签名组合或逗号分隔的签名查询交易。
* `txs`：查询匹配一组事件的分页交易。
* `upgrade`：升级模块的查询命令。
* `wasm`：WASM 模块的查询命令。
* `xwasm`：wasmx 模块的查询命令。

### `rollback`

状态回滚是为了从错误的应用状态转换中恢复，当 Tendermint 持久化了错误的应用哈希，导致无法继续前进时，执行回滚操作。回滚将高度为 n 的状态覆盖为高度 n - 1 的状态。应用程序也会回滚到高度 n - 1。没有区块被删除，因此当重新启动 Tendermint 时，第 n 区块中的交易将会重新执行。

语法

```bash
biyachaind rollback
```

### `rosetta`

创建一个 Rosetta 服务器。

**语法**

```bash
biyachaind rosetta [flags]
```

### `start`

运行全节点应用程序，可以选择在进程内或进程外与 Tendermint 一起运行。默认情况下，应用程序与 Tendermint 在同一进程中运行。

{% hint style="info" %}
`start` 命令提供了多个可用的标志。运行 `start` 命令并添加 `--help` 或 `-h` 以查看所有标志。
{% endhint %}

语法

```bash
biyachaind start [flags]
```

### `status`

显示远程节点的状态。使用 `--node` 或 `-n` 标志来指定节点端点。

语法

```bash
biyachaind status
```

### `tendermint`

管理 Tendermint 协议。要查看语法和子命令列表，请在 `query` 子命令后添加 `--help` 或 `-h` 标志运行：

```bash
biyachaind tendermint -h
```

子命令:

```bash
biyachaind tendermint [subcommand]
```

* `reset-state`：删除所有数据和 WAL（写前日志）。
* `show-address`：显示该节点的 Tendermint 验证者共识地址。
* `show-node-id`：显示该节点的 ID。
* `show-validator`：显示该节点的 Tendermint 验证者信息。
* `unsafe-reset-all`：删除所有数据和 WAL，将该节点的验证者重置为创世状态。
* `version`：显示 Tendermint 库的版本信息。

### `testnet`

创建一个测试网，指定目录的数量，并为每个目录填充必要的文件。

{% hint style="info" %}
`testnet` 命令提供了多个可用的标志。运行 `testnet` 命令并添加 `--help` 或 `-h` 以查看所有标志。
{% endhint %}

**语法**

```bash
biyachaind testnet [flags]
```

**例子**

```bash
biyachaind testnet --v 4 --keyring-backend test --output-dir ./output --ip-addresses 192.168.10.2
```

### `tx`

管理交易的生成、签名和广播。有关示例，请参阅使用 `Biyachaind`。\
要查看语法、可用的子命令及其详细信息，请在 `tx` 命令后添加 `--help` 或 `-h` 标志运行：

```bash
biyachaind tx -h
```

子命令:

```bash
biyachaind tx [subcommand]
```

* `auction`：拍卖交易子命令
* `authz`：授权交易子命令
* `bank`：银行交易子命令
* `broadcast`：广播离线生成的交易
* `chainlink`：链下报告（OCR）子命令
* `crisis`：危机交易子命令
* `decode`：解码二进制编码的交易字符串
* `distribution`：分发交易子命令
* `encode`：编码离线生成的交易
* `evidence`：证据交易子命令
* `exchange`：交换交易子命令
* `feegrant`：费用授权交易子命令
* `gov`：治理交易子命令
* `ibc`：IBC 交易子命令
* `ibc-fee`：IBC 中继激励交易子命令
* `ibc-transfer`：IBC 同质化代币转账交易子命令
* `insurance`：保险交易子命令
* `multisign`：为离线生成的交易生成多签名
* `oracle`：预言机交易子命令
* `peggy`：Peggy 交易子命令
* `sign`：签署离线生成的交易
* `sign-batch`：签署交易批处理文件
* `slashing`：惩罚交易子命令
* `staking`：质押交易子命令
* `tokenfactory`：代币工厂交易子命令
* `validate-signatures`：验证交易签名
* `vesting`：归属交易子命令
* `wasm`：WASM 交易子命令
* `xwasm`：wasmx 交易子命令

### `validate-genesis`

验证默认位置或指定位置的创世文件。有关创世文件的更多信息，请参阅加入测试网或[加入主网](../../jie-dian/kuai-su-ru-men/yun-xing-jie-dian/jia-ru-wang-luo.md)指南。

**语法**

```bash
biyachaind validate-genesis </path-to-file>
```

### `version`

返回你正在运行的 Biyachain 版本。

**语法**

```bash
biyachaind version
```
