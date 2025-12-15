# Peggo

如果您正在阅读此页面，那么您可能已经成为 Biyachain 上的验证器。恭喜！配置 `peggo` 是设置的最后一步。

peggo 的 `.env` 示例：

```bash
PEGGO_ENV="local"         # environment name for metrics (dev/test/staging/prod/local)
PEGGO_LOG_LEVEL="debug"   # log level depth

PEGGO_COSMOS_CHAIN_ID="biyachain-1"           # chain ID of the Biyachain network
PEGGO_COSMOS_GRPC="tcp://localhost:9090"      # gRPC of your biyachaind process
PEGGO_TENDERMINT_RPC="http://localhost:26657" # Tendermint RPC of your biyachaind process

# Note: omitting PEGGO_COSMOS_GRPC and PEGGO_TENDERMINT_RPC enables stand-alone peggo mode. In this mode,
# peggo is connected to load balanced endpoints provided by the Biyachain network. This decouples peggo's connection from your biyachaind process.

# Biyachain config
PEGGO_COSMOS_FEE_DENOM="biya"            # token used to pay fees on Biyachain
PEGGO_COSMOS_GAS_PRICES="160000000biya"  # default --gas-prices flag value for sending messages to Biyachain
PEGGO_COSMOS_KEYRING="file"             # keyring backends ("os", "file", "kwallet", "memory", "pass", "test")
PEGGO_COSMOS_KEYRING_DIR=               # path to your keyring dir
PEGGO_COSMOS_KEYRING_APP="peggo"        # arbitrary name for your keyring app
PEGGO_COSMOS_FROM=                      # account address of your Validator (or your Delegated Orchestrator)
PEGGO_COSMOS_FROM_PASSPHRASE=           # keyring passphrase
PEGGO_COSMOS_PK=                        # private key of your Validator (or your Delegated Orchestrator)
PEGGO_COSMOS_USE_LEDGER=false

# Ethereum config
PEGGO_ETH_KEYSTORE_DIR=               # path to your Ethereum keystore
PEGGO_ETH_FROM=                       # your Ethereum address (must be Delegated Ethereum address if you're a Validator)
PEGGO_ETH_PASSPHRASE=                 # passphrase of your Ethereum keystore
PEGGO_ETH_PK=                         # private key of your Ethereum address
PEGGO_ETH_GAS_PRICE_ADJUSTMENT=1.3    # suggested Ethereum gas price will be adjusted by this factor (Relayer)
PEGGO_ETH_MAX_GAS_PRICE="500gwei"     # max gas price allowed for sending Eth transactions (Relayer)
PEGGO_ETH_CHAIN_ID=1                  # chain ID of Ethereum network
PEGGO_ETH_RPC="http://localhost:8545" # RPC of your Ethereum node
PEGGO_ETH_ALCHEMY_WS=""               # optional websocket endpoint for listening pending transactions on Peggy.sol
PEGGO_ETH_USE_LEDGER=false 

# Price feed provider for token assets (Batch Creator)
PEGGO_COINGECKO_API="https://api.coingecko.com/api/v3"

# Relayer config
PEGGO_RELAY_VALSETS=true                      # set to `true` to relay Validator Sets
PEGGO_RELAY_VALSET_OFFSET_DUR="5m"            # duration which needs to expire before a Valset is eligible for relaying 
PEGGO_RELAY_BATCHES=true                      # set to `true` to relay Token Batches
PEGGO_RELAY_BATCH_OFFSET_DUR="5m"             # duration which needs to expire before a Token Batch is eligible for relaying
PEGGO_RELAY_PENDING_TX_WAIT_DURATION="20m"    # time to wait until a pending tx is processed

# Batch Creator config
PEGGO_MIN_BATCH_FEE_USD=23.2  # minimum amount of fee a Token Batch must satisfy to be created

# Metrics config
PEGGO_STATSD_PREFIX="peggo."
PEGGO_STATSD_ADDR="localhost:8125"
PEGGO_STATSD_STUCK_DUR="5m"
PEGGO_STATSD_MOCKING=false
PEGGO_STATSD_DISABLED=true
```

{% hint style="info" %}
**重要提示：** 如果您正在运行自己的 `biyachaind`（Biyachain 节点）和 `geth`（以太坊节点）进程，请确保它们与最新状态同步。过时的节点可能会使 `peggo` 的业务逻辑出现偏差，有时会显示"误报"日志。
{% endhint %}

## 步骤 1：配置 .env

```bash
# official Biyachain mainnet .env config 
mkdir ~/.peggo
cp mainnet-config/10001/peggo-config.env ~/.peggo/.env
cd ~/.peggo
```

以太坊配置

首先，使用有效的以太坊 EVM RPC 端点更新 `.env` 文件中的 `PEGGO_ETH_RPC`。

要设置您自己的以太坊全节点，请按照[此处](https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/)的说明进行操作。可以使用外部以太坊 RPC 提供商（如 Alchemy 或 Infura），但请注意，Peggo 桥接中继器大量使用 `eth_getLogs` 调用，这可能会增加您的成本负担，具体取决于您的提供商。

## **管理 `peggo` 的以太坊密钥**

Peggo 支持两种提供签名密钥凭证的选项 - 使用 Geth keystore（推荐）或提供明文以太坊私钥。

#### **选项 1. Geth Keystore**

您可以在 Geth 文档[此处](https://geth.ethereum.org/docs/interface/managing-your-accounts)找到使用 keystore 安全创建新以太坊账户的说明。

为方便起见，下面提供了一个示例。

```bash
geth account new --datadir=/home/ec2-user/.peggo/data/

INFO [03-23|18:18:36.407] Maximum peer count                       ETH=50 LES=0 total=50
Your new account is locked with a password. Please give a password. Do not forget this password.
Password:
Repeat password:

Your new key was generated

Public address of the key:   0x9782dc957DaE6aDc394294954B27e2118D05176C
Path of the secret key file: /home/ec2-user/.peggo/data/keystore/UTC--2021-03-23T15-18-44.284118000Z--9782dc957dae6adc394294954b27e2118d05176c

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```

请确保注意 geth 提供的警告，特别是备份密钥文件，以免意外丢失密钥。我们还建议在密码短语中不要使用任何引号或反引号字符，以确保 peggo 兼容性。

现在您应该设置以下环境变量：

```bash
# example values, replace with your own
PEGGO_ETH_KEYSTORE_DIR=/home/ec2-user/.peggo/data/keystore
PEGGO_ETH_FROM=0x9782dc957DaE6aDc394294954B27e2118D05176C
PEGGO_ETH_PASSPHRASE=12345678
```

然后确保您的以太坊地址有足够的 ETH。

#### **选项 2. 以太坊私钥（不安全）**

只需使用新账户的新以太坊私钥更新 `PEGGO_ETH_PK`。

然后确保您的以太坊地址有足够的 ETH。

## Biyachain 配置

### **创建用于发送 Biyachain 交易的委托 Cosmos 密钥**

您的 peggo orchestrator 可以：

* 使用专门用于发送验证器特定 Peggy 交易（即 `ValsetConfirm`、`BatchConfirm` 和 `SendToCosmos` 交易）的明确委托账户密钥，或
* 简单地使用验证器的账户密钥（"您的验证器就是您的 Orchestrator"）

为了隔离目的，我们建议创建委托的 Cosmos 密钥来发送 Biyachain 交易，而不是使用验证器账户密钥。

要创建新密钥，请运行

```bash
biyachaind keys add $ORCHESTRATOR_KEY_NAME
```

然后确保您的 orchestrator biya 地址中有 BIYA 余额，以便 peggo orchestrator 可以向 Biyachain 发送消息。

要获取您的 orchestrator 的 biya 地址，请运行

```bash
biyachaind keys list $ORCHESTRATOR_KEY_NAME
```

您可以使用此命令将 BIYA 从验证器账户转移到 orchestrator 地址

```bash
biyachaind tx bank send $VALIDATOR_KEY_NAME  $ORCHESTRATOR_BIYA_ADDRESS <amount-in-biya> --chain-id=biyachain-1 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

示例

```bash
biyachaind tx bank send genesis biya1u3eyz8nkvym0p42h79aqgf37gckf7szreacy9e 20000000000000000000biya --chain-id=biyachain-1  --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

然后您可以通过运行以下命令验证您的 orchestrator 账户是否有 BIYA 余额

```bash
biyachaind q bank balances $ORCHESTRATOR_BIYA_ADDRESS
```

### **管理 `peggo` 的 Cosmos 账户密钥**

Peggo 支持两种提供 Cosmos 签名密钥凭证的选项 - 使用 Cosmos 密钥环（推荐）或提供明文私钥。

#### **选项 1. Cosmos 密钥环**

在 `.env` 文件中，首先指定与您的 peggo 账户签名密钥对应的 `PEGGO_COSMOS_FROM` 和 `PEGGO_COSMOS_FROM_PASSPHRASE`。

如果您使用上面推荐的委托账户密钥配置，这将是您的 `$ORCHESTRATOR_KEY_NAME` 和密码短语。否则，这应该是您的 `$VALIDATOR_KEY_NAME` 和关联的验证器密码短语。

请注意，默认密钥环后端是 `file`，因此 peggo 默认会尝试在磁盘上定位密钥。

要使用默认的 biyachaind 密钥配置，您应该将密钥环路径设置为 biyachaind 节点的主目录，例如 `~/.biyachaind`。

您也可以在[此处](https://docs.cosmos.network/v0.46/run-node/keyring.html)阅读有关 Cosmos 密钥环设置的更多信息。

#### **选项 2. Cosmos 私钥（不安全）**

在 `.env` 文件中，指定与您的 peggo 账户签名密钥对应的 `PEGGO_COSMOS_PK`。

如果您使用上面推荐的委托账户密钥配置，这将是您的 orchestrator 账户的私钥。否则，这应该是您的验证器的账户私钥。

要获取您的 orchestrator 的 Cosmos 私钥（如果适用），请运行

```bash
biyachaind keys unsafe-export-eth-key $ORCHESTRATOR_KEY_NAME
```

要获取您的验证器的 Cosmos 私钥（如果适用），请运行

```bash
biyachaind keys unsafe-export-eth-key $VALIDATOR_KEY_NAME
```

同样，此方法不太安全，不推荐使用。

### 步骤 2：注册您的 Orchestrator 和以太坊地址

您只能注册一次 orchestrator 和以太坊地址。以后**无法**更新。因此在运行以下命令之前请检查两次。

```bash
biyachaind tx peggy set-orchestrator-address $VALIDATOR_BIYA_ADDRESS $ORCHESTRATOR_BIYA_ADDRESS $ETHEREUM_ADDRESS --from $VALIDATOR_KEY_NAME --chain-id=biyachain-1 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya

```

* 要获取验证器的 biya 地址，请运行 `biyachaind keys list $VALIDATOR_KEY_NAME`
* 要获取 orchestrator 的 biya 地址，请运行 `biyachaind keys list $ORCHESTRATOR_KEY_NAME`

示例：

```bash
biyachaind tx peggy set-orchestrator-address biya10m247khat0esnl0x66vu9mhlanfftnvww67j9n biya1x7kvxlz2epqx3hpq6v8j8w859t29pgca4z92l2 0xf79D16a79130a07e77eE36e8067AeA783aBdA3b6 --from validator-key-name --chain-id=biyachain-1 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

您可以通过在 https://lcd.biyachain.network/peggy/v1/valset/current 上检查验证器的映射以太坊地址来验证注册是否成功。

{% hint style="info" %}
**注意：** 一旦您使用 `set-orchestrator-address` 消息注册了 Orchestrator，您**无法**再次注册。一旦此步骤完成，您的 `Validator` 就绑定到提供的以太坊地址（以及您可能提供的委托地址）。换句话说，您的 peggo 必须始终使用您为注册提供的地址运行。
{% endhint %}

### 步骤 3：启动中继器

```bash
cd ~/.peggo
peggo orchestrator
```

这将启动 Peggo 桥接（中继器 / orchestrator）。

### 步骤 4：创建 Peggo systemd 服务

在 `/etc/systemd/system/peggo.service` 下添加 `peggo.service` 文件，内容如下

```ini
[Unit]
  Description=peggo

[Service]
  WorkingDirectory=/home/ec2-user/.peggo
  ExecStart=/bin/bash -c 'peggo orchestrator '
  Type=simple
  Restart=always
  RestartSec=1
  User=ec2-user

[Install]
  WantedBy=multi-user.target
```

然后使用以下命令配置环境变量、启动和停止 peggo 中继器。

```bash
sudo systemctl start peggo
sudo systemctl stop peggo
sudo systemctl restart peggo
sudo systemctl status peggo

# enable start on system boot
sudo systemctl enable peggo

# To check Logs
journalctl -f -u peggo
```

### 步骤 5：（可选）保护 Cosmos 密钥环免受未授权访问

{% hint style="info" %}
这是一个高级 DevOps 主题，请咨询您的系统管理员。
{% endhint %}

在[此处](https://docs.cosmos.network/v0.46/run-node/keyring.html)了解更多有关 Cosmos 密钥环设置的信息。一旦您启动了节点，默认密钥环将以加密形式在磁盘上存储验证器运营者密钥。通常密钥环位于节点的主目录内，即 `~/.biyachaind/keyring-file`。

Biyachain 质押文档的某些部分将指导您将此密钥用于治理目的，即提交交易和设置以太坊桥接。为了保护密钥免受未授权访问，即使密钥环密码短语通过配置泄露，您也可以设置操作系统权限，仅允许 `biyachaind` / `peggo` 进程访问磁盘。

在 Debian、Ubuntu 和 RHEL 等 Linux 系统中，可以使用 POSIX 访问控制列表 (ACL) 来实现这一点。在开始使用 ACL 之前，必须启用 ACL 挂载文件系统。每个发行版都有一些官方指南：

* [Ubuntu](https://help.ubuntu.com/community/FilePermissionsACLs)
* [Debian](https://wiki.debian.org/Permissions)
* [Amazon Linux (RHEL)](https://www.redhat.com/sysadmin/linux-access-control-lists)

### 贡献

如果您想检查 Peggo orchestrator 源代码并做出贡献，可以在 [https://github.com/biya-coin/peggo](https://github.com/biya-coin/peggo) 进行。
