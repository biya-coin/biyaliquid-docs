# 加入网络

本指南将引导您完成在本地设置独立网络以及在主网或测试网上运行节点的过程。

您还可以在相应的标签页中找到每个网络的硬件要求。

{% tabs %}
{% tab title="本地网络" %}
要轻松设置本地节点，请下载并运行 `setup.sh` 脚本。这将初始化您的本地 Biya Chain 网络。

```bash
wget https://raw.githubusercontent.com/biya-coin/biyachain-chain-releases/master/scripts/setup.sh
chmod +x ./setup.sh # Make the script executable
./setup.sh
```

通过运行以下命令启动节点：

```bash
biyachaind start # Blocks should start coming in after running this
```

有关脚本正在做什么的进一步说明以及对设置过程的更细粒度控制，请继续阅读下文。

**初始化链**

在运行 Biya Chain 节点之前，我们需要初始化链以及节点的创世文件：

```bash
# The <moniker> argument is the custom username of your node. It should be human-readable.
biyachaind init <moniker> --chain-id=biyachain-1
```

上面的命令创建节点运行所需的所有配置文件以及默认的创世文件，该文件定义了网络的初始状态。默认情况下，所有这些配置文件都在 `~/.biyachaind` 中，但您可以通过传递 `--home` 标志来覆盖此文件夹的位置。请注意，如果您选择使用除 `~/.biyachaind` 之外的其他目录，则每次运行 `biyachaind` 命令时都必须使用 `--home` 标志指定位置。如果您已有创世文件，可以使用 `--overwrite` 或 `-o` 标志覆盖它。

`~/.biyachaind` 文件夹具有以下结构：

```bash
.                                   # ~/.biyachaind
  |- data                           # Contains the databases used by the node.
  |- config/
      |- app.toml                   # Application-related configuration file.
      |- config.toml                # Tendermint-related configuration file.
      |- genesis.json               # The genesis file.
      |- node_key.json              # Private key to use for node authentication in the p2p protocol.
      |- priv_validator_key.json    # Private key to use as a validator in the consensus protocol.
```

**修改 `genesis.json` 文件**

此时，需要在 `genesis.json` 文件中进行修改：

* 将质押 `bond_denom`、危机 `denom`、治理 `denom` 和铸币 `denom` 值更改为 `"biya"`，因为这是 Biya Chain 的原生代币。

通过运行以下命令可以轻松完成：

```bash
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
```

{% hint style="info" %}
上面的命令仅在使用了默认 `.biyachaind` 目录时才有效。对于特定目录，请修改上面的命令或手动编辑 `genesis.json` 文件以反映更改。
{% endhint %}

**为验证器账户创建密钥**

在启动链之前，您需要在状态中填充至少一个账户。为此，首先在 `test` 密钥环后端下创建一个名为 `my_validator` 的新账户（可以自由选择其他名称和其他后端）：

```bash
biyachaind keys add my_validator --keyring-backend=test

# Put the generated address in a variable for later use.
MY_VALIDATOR_ADDRESS=$(biyachaind keys show my_validator -a --keyring-backend=test)
```

现在您已经创建了一个本地账户，继续在链的创世文件中授予它一些 `biya` 代币。这样做还将确保您的链从链的创世开始就知道此账户的存在：

```bash
biyachaind add-genesis-account $MY_VALIDATOR_ADDRESS 100000000000000000000000000biya --chain-id=biyachain-1
```

`$MY_VALIDATOR_ADDRESS` 是保存密钥环中 `my_validator` 密钥地址的变量。Biya Chain 中的代币具有 `{amount}{denom}` 格式：`amount` 是一个 18 位精度的十进制数，`denom` 是带有其面额键的唯一代币标识符（例如 `biya`）。在这里，我们授予 `biya` 代币，因为 `biya` 是 `biyachaind` 中用于质押的代币标识符。

**将验证器添加到链**

现在您的账户有一些代币，您需要向链添加验证器。验证器是参与共识过程以向链添加新区块的特殊全节点。任何账户都可以声明其成为验证器运营者的意图，但只有那些有足够委托的账户才能进入活跃集合。在本指南中，您将把本地节点（通过上面的 `init` 命令创建）添加为链的验证器。验证器可以在链首次启动之前通过包含在创世文件中的特殊交易（称为 `gentx`）来声明：

```bash
# Create a gentx.
biyachaind genesis gentx my_validator 1000000000000000000000biya --chain-id=biyachain-1 --keyring-backend=test

# Add the gentx to the genesis file.
biyachaind genesis collect-gentxs
```

`gentx` 做三件事：

1. 将您创建的 `validator` 账户注册为验证器运营者账户（即控制验证器的账户）。
2. 自委托提供的质押代币 `amount`。
3. 将运营者账户与将用于签名区块的 Tendermint 节点公钥链接。如果未提供 `--pubkey` 标志，则默认为通过上面的 `biyachaind init` 命令创建的本地节点公钥。

有关 `gentx` 的更多信息，请使用以下命令：

```bash
biyachaind genesis gentx --help
```

**使用 `app.toml` 和 `config.toml` 配置节点**

在 `~/.biyachaind/config` 内自动生成两个配置文件：

* `config.toml`：用于配置 Tendermint（在 [Tendermint 文档](https://docs.tendermint.com/v0.34/tendermint-core/configuration.html) 上了解更多信息），以及
* `app.toml`：由 Cosmos SDK（Biya Chain 构建于其上）生成，用于配置状态修剪策略、遥测、gRPC 和 REST 服务器配置、状态同步等。

两个文件都有大量注释——请直接参考它们来调整您的节点。

要调整的一个示例配置是 `app.toml` 内的 `minimum-gas-prices` 字段，它定义了验证器节点愿意接受处理交易的最低 gas 价格。如果为空，请确保使用某个值编辑该字段，例如 `10biya`，否则节点将在启动时停止。在本教程中，让我们将最低 gas 价格设置为 0：

```toml
 # The minimum gas prices a validator is willing to accept for processing a
 # transaction. A transaction's fees must meet the minimum of any denomination
 # specified in this config (e.g. 0.25token1;0.0001token2).
 minimum-gas-prices = "0biya"
```

**运行本地网络**

现在一切都已设置好，您终于可以启动节点了：

```bash
biyachaind start # Blocks should start coming in after running this
```

此命令允许您运行单个节点，这足以通过节点与链交互，但您可能希望同时运行多个节点以查看它们之间如何达成共识。
{% endtab %}

{% tab title="测试网网络" %}
**硬件规格**

节点运营者应部署裸机服务器以实现最佳性能。此外，验证器节点必须满足推荐的硬件规格，特别是 CPU 要求，以确保高正常运行时间。

|      _最低要求_     |      _推荐配置_     |
| :-------------: | :-------------: |
|     内存 128GB    |     内存 128GB    |
|     CPU 12 核    |     CPU 16 核    |
| CPU 基础频率 3.7GHz | CPU 基础频率 4.2GHz |
|   存储 2TB NVMe   |   存储 2TB NVMe   |
|    网络 1Gbps+    |    网络 1Gbps+    |

**安装 `biyachaind` 和 `peggo`**

非验证器节点运营者无需安装 `peggo`。

```bash
wget https://github.com/biya-coin/testnet/releases/latest/download/linux-amd64.zip
unzip linux-amd64.zip
sudo mv peggo /usr/bin
sudo mv biyachaind /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib 
```

**初始化新的 Biya Chain 链节点**

在运行 Biya Chain 节点之前，我们需要初始化链以及节点的创世文件：

```bash
# The argument <moniker> is the custom username of your node, it should be human-readable.
export MONIKER=<moniker>
# Biya Chain Testnet has a chain-id of "biyachain-888"
biyachaind init $MONIKER --chain-id biyachain-888
```

运行 `init` 命令将在 `~/.biyachaind` 创建 `biyachaind` 默认配置文件。

**准备加入测试网的配置**

您现在应该使用测试网的创世文件和应用配置文件更新默认配置，并使用种子节点配置您的持久对等节点。

```bash
git clone https://github.com/biya-coin/testnet.git

# copy genesis file to config directory
aws s3 cp --no-sign-request s3://biyachain-snapshots/testnet/genesis.json .
mv genesis.json ~/.biyachaind/config/

# copy config file to config directory
cp testnet/corfu/70001/app.toml  ~/.biyachaind/config/app.toml
cp testnet/corfu/70001/config.toml ~/.biyachaind/config/config.toml
```

您还可以运行验证创世校验和 - a4abe4e1f5511d4c2f821c1c05ecb44b493eec185c0eec13b1dcd03d36e1a779

```bash
sha256sum ~/.biyachaind/config/genesis.json
```

**为 `biyachaind` 配置 `systemd` 服务**

编辑 `/etc/systemd/system/biyachaind.service` 处的配置：

```bash
[Unit]
  Description=biyachaind

[Service]
  WorkingDirectory=/usr/bin
  ExecStart=/bin/bash -c '/usr/bin/biyachaind --log-level=error start'
  Type=simple
  Restart=always
  RestartSec=5
  User=root

[Install]
  WantedBy=multi-user.target
```

启动和重启 systemd 服务

```bash
sudo systemctl daemon-reload
sudo systemctl restart biyachaind
sudo systemctl status biyachaind

# enable start on system boot
sudo systemctl enable biyachaind

# To check Logs
journalctl -u biyachaind -f
```
{% endtab %}
{% endtabs %}
