# biyachaind 命令

本节描述了 `biyachaind` 提供的命令,这是连接正在运行的 `biyachaind` 进程 (节点) 的命令行界面。

{% hint style="info" %}
几个 `biyachaind` 命令需要子命令、参数或标志才能运行。要查看此信息,请使用 `--help` 或 `-h` 标志运行 `biyachaind` 命令。有关帮助标志的使用示例,请参阅 `query` 或 `tx`。

对于 `chain-id` 参数,主网应使用 `biyachain-1`,测试网应使用 `biyachain-888`。
{% endhint %}

### `add-genesis-account`

将创世账户添加到 `genesis.json`。有关 `genesis.json` 的更多信息,请参阅加入测试网或加入主网指南。

**语法**

```bash
biyachaind add-genesis-account <address-or-key-name> <amount><coin-denominator>
```

**示例**

```bash
biyachaind add-genesis-account acc1 100000000000biya
```

### `collect-gentxs`

收集创世交易并将其输出到 `genesis.json`。有关 `genesis.json` 的更多信息,请参阅[此处](../../../infra/join-a-network.md)的加入测试网或加入主网指南。

**语法**

```bash
biyachaind collect-gentxs
```

### `debug`

帮助调试应用程序。有关语法和子命令列表,请使用 `--help` 或 `-h` 标志运行 `debug` 命令:

```bash
biyachaind debug -h
```

**子命令**:

```bash
biyachaind debug [subcommand]
```

* **`addr`**: 在十六进制和 bech32 之间转换地址
* **`pubkey`**: 从 proto JSON 解码公钥
* **`raw-bytes`**: 将原始字节输出 (例如, \[72 101 108 108 111 44 32 112 108 97 121 103 114 111 117 110 100]) 转换为十六进制

### `export`

将状态导出为 JSON。

**语法**

```bash
biyachaind export
```

### `gentx`

将创世交易添加到 `genesis.json`。有关 `genesis.json` 的更多信息,请参阅加入测试网或加入主网指南。

{% hint style="info" %}
**注意:** `gentx` 命令有许多可用标志。使用 `--help` 或 `-h` 运行 `gentx` 命令以查看所有标志。
{% endhint %}

**语法**

```bash
biyachaind gentx <key-name> <amount><coin-denominator>
```

**示例**

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

**示例**

```bash
biyachaind init myNode
```

### `keys`

管理密钥环命令。这些密钥可以是 Tendermint 加密库支持的任何格式,并且可以被轻客户端、全节点或任何其他需要使用私钥签名的应用程序使用。

有关语法和子命令列表,请使用 `--help` 或 `-h` 标志运行 `keys` 命令:

```bash
biyachaind keys -h
```

**子命令**:

```bash
biyachaind keys [subcommand]
```

* **`add`**: 添加一个加密的私钥 (新生成或恢复的),加密它,并保存到提供的文件名
* **`delete`**: 删除给定的密钥
* **`export`**: 导出私钥
* **`import`**: 将私钥导入本地密钥库
* **`list`**: 列出所有密钥
* **`migrate`**: 从传统 (基于数据库的) 密钥库迁移密钥
* **`mnemonic`**: 为某些输入熵计算 bip39 助记词
* **`parse`**: 将地址从十六进制解析为 bech32,反之亦然
* **`show`**: 按名称或地址检索密钥信息
* **`unsafe-export-eth-key`**: 以纯文本形式导出以太坊私钥
* **`unsafe-import-eth-key`**: 将以太坊私钥导入本地密钥库

\
`migrate`

将源创世文件迁移到目标版本并打印到 STDOUT。有关 `genesis.json` 的更多信息,请参阅加入测试网或加入主网指南。

**语法**

```bash
biyachaind migrate <target version> <path-to-genesis-file>
```

**示例**

```bash
biyachaind migrate v1.9.0 /path/to/genesis.json --chain-id=biyachain-888 --genesis-time=2023-03-07T17:00:00Z 
```

### `query`

管理查询。有关语法和子命令列表,请使用 `--help` 或 `-h` 标志运行 `query` 子命令:

```bash
biyachaind query -h
```

**子命令**:

```bash
biyachaind query [subcommand]
```

* **`account`**: 按地址查询账户
* **`auction`**: `auction` 模块的查询命令
* **`auth`**: `auth` 模块的查询命令
* **`authz`**: `authz` 模块的查询命令
* **`bank`**: `bank` 模块的查询命令
* **`block`**: 获取给定高度的区块的已验证数据
* **`chainlink`**: `oracle` 模块的查询命令
* **`distribution`**: `distribution` 模块的查询命令
* **`evidence`**: 按哈希查询证据或查询所有 (分页的) 提交的证据
* **`exchange`**: `exchange` 模块的查询命令
* **`feegrant`**: `feegrant` 模块的查询命令
* **`gov`**: `governance` 模块的查询命令
* **`ibc`**: `ibc` 模块的查询命令
* **`ibc-fee`**: IBC 中继激励查询子命令
* **`ibc-transfer`**: IBC 可替代代币转移查询子命令
* **`insurance`**: `insurance` 模块的查询命令
* **`interchain-accounts`**: 跨链账户子命令
* **`mint`**: 铸币模块的查询命令
* **`oracle`**: `oracle` 模块的查询命令
* **`params`**: `params` 模块的查询命令
* **`peggy`**: `peggy` 模块的查询命令
* **`slashing`**: `slashing` 模块的查询命令
* **`staking`**: `staking` 模块的查询命令
* **`tendermint-validator-set`**: 获取给定高度的完整 Tendermint 验证者集
* **`tokenfactory`**: `tokenfactory` 模块的查询命令
* **`tx`**: 在已提交的区块中按哈希、账户序列或组合或逗号分隔的签名查询交易
* **`txs`**: 查询匹配一组事件的分页交易
* **`upgrade`**: `upgrade` 模块的查询命令
* **`wasm`**: `wasm` 模块的查询命令
* **`xwasm`**: `wasmx` 模块的查询命令

### `rollback`

执行状态回滚以从不正确的应用程序状态转换中恢复,当 Tendermint 持久化了不正确的应用程序哈希并因此无法取得进展时。回滚用高度 _n - 1_ 的状态覆盖高度 _n_ 的状态。应用程序也回滚到高度 _n - 1_。不会删除任何区块,因此在重启 Tendermint 时,区块 _n_ 中的交易将针对应用程序重新执行。

**语法**

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

运行带有 Tendermint 的全节点应用程序 (进程内或进程外)。默认情况下,应用程序与 Tendermint 在同一进程中运行。

{% hint style="info" %}
`start` 命令有许多可用标志。使用 `--help` 或 `-h` 运行 `start` 命令以查看所有标志。
{% endhint %}

**语法**

```bash
biyachaind start [flags]
```

### `status`

显示远程节点的状态。使用 `--node` 或 `-n` 标志指定节点端点。

**语法**

```bash
biyachaind status
```

### `tendermint`

管理 Tendermint 协议。有关语法和子命令列表,请使用 `--help` 或 `-h` 标志运行 `query` 子命令:

```bash
biyachaind tendermint -h
```

**子命令**:

```bash
biyachaind tendermint [subcommand]
```

* **`reset-state`**: 删除所有数据和 WAL
* **`show-address`**: 显示此节点的 Tendermint 验证者共识地址
* **`show-node-id`**: 显示此节点的 ID
* **`show-validator`**: 显示此节点的 Tendermint 验证者信息
* **`unsafe-reset-all`**: 删除所有数据和 WAL,将此节点的验证者重置为创世状态
* **`version`** 显示 Tendermint 库版本

### `testnet`

创建具有指定数量目录的测试网,并用必要的文件填充每个目录。

{% hint style="info" %}
`testnet` 命令有许多可用标志。使用 `--help` 或 `-h` 运行 `testnet` 命令以查看所有标志。
{% endhint %}

**语法**

```bash
biyachaind testnet [flags]
```

**示例**

```bash
biyachaind testnet --v 4 --keyring-backend test --output-dir ./output --ip-addresses 192.168.10.2
```

### `tx`

管理交易的生成、签名和广播。有关示例,请参阅使用 Biyachaind。

有关语法和可用子命令的更多信息,请使用 `--help` 或 `-h` 标志运行 `tx` 命令:

```bash
biyachaind tx -h
```

**子命令**:

```bash
biyachaind tx [subcommand]
```

* **`auction`**: 拍卖交易子命令
* **`authz`**: 授权交易子命令
* **`bank`**: 银行交易子命令
* **`broadcast`**: 广播离线生成的交易
* **`chainlink`**: 链下报告 (OCR) 子命令
* **`crisis`**: 危机交易子命令
* **`decode`**: 解码二进制编码的交易字符串
* **`distribution`**: 分配交易子命令
* **`encode`**: 编码离线生成的交易
* **`evidence`**: 证据交易子命令
* **`exchange`**: 交易所交易子命令
* **`feegrant`**: 费用授予交易子命令
* **`gov`**: 治理交易子命令
* **`ibc`**: IBC 交易子命令
* **`ibc-fee`**: IBC 中继激励交易子命令
* **`ibc-transfer`**: IBC 可替代代币转移交易子命令
* **`insurance`**: 保险交易子命令
* **`multisign`**: 为离线生成的交易生成多签签名
* **`oracle`**: 预言机交易子命令
* **`peggy`**: Peggy 交易子命令
* **`sign`**: 签名离线生成的交易
* **`sign-batch`**: 签名交易批处理文件
* **`slashing`**: 惩罚交易子命令
* **`staking`**: 质押交易子命令
* **`tokenfactory`**: 代币工厂交易子命令
* **`validate-signatures`**: 验证交易签名
* **`vesting`**: 归属交易子命令
* **`wasm`**: Wasm 交易子命令
* **`xwasm`**: Wasmx 交易子命令

### `validate-genesis`

验证默认位置或指定位置的创世文件。有关创世文件的更多信息,请参阅加入测试网或加入主网指南。

**语法**

```bash
biyachaind validate-genesis </path-to-file>
```

### `version`

返回您正在运行的 Biyachain 版本。

**语法**

```bash
biyachaind version
```
