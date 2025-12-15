# 测试网 Peggo

## Equinox 测试网

## 步骤 1：配置 Peggo 中继器

```bash
mkdir ~/.peggo
cp testnet-config/staking/40014/peggo-config.env ~/.peggo/.env
cd ~/.peggo
```

首先，使用有效的 Sepolia EVM RPC 端点更新 `.env` 文件中的 `PEGGO_ETH_RPC`。

要设置您自己的 Sepolia 全节点，请按照[此处](https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/)的说明进行操作。可以使用 Alchemy 或 Infura RPC，但请注意，Peggo 桥接仍在开发中，它对 RPC 的请求量尚未优化。确保它不会在您的账户上产生高成本。

Peggo 还需要访问验证器的 Cosmos 和以太坊凭证，以便为相应网络签署交易。

## **Cosmos 密钥**

有两种提供凭证访问的方式 - 使用加密密钥的密钥环，或仅使用明文私钥。

### **1. Cosmos 密钥环**

将 `PEGGO_COSMOS_FROM` 更新为您的验证器密钥名称（或账户地址），将 `PEGGO_COSMOS_FROM_PASSPHRASE` 更新为您的 Cosmos 密钥环密码短语。请注意，默认密钥环后端是 `file`，它将尝试在磁盘上定位密钥。

如果您想重用那里的密钥，密钥环路径必须指向 biyachaind 节点的主目录。

在[此处](https://docs.cosmos.network/v0.46/run-node/keyring.html)了解更多有关密钥环设置的信息。

### **2. Cosmos 私钥（不安全）**

只需使用验证器账户的私钥更新 `PEGGO_COSMOS_PK`。

要获取验证器的 Cosmos 私钥，请运行 `biyachaind keys unsafe-export-eth-key $VALIDATOR_KEY_NAME`。

此方法不安全，不推荐使用。

## **以太坊密钥**

有两种提供凭证访问的方式 - 使用加密密钥的 Geth keystore，或仅使用明文私钥。

### **1. Geth Keystore**

只需创建新的私钥存储并更新以下环境变量：

* `PEGGO_ETH_KEYSTORE_DIR`
* `PEGGO_ETH_FROM`
* `PEGGO_ETH_PASSPHRASE`

您可以在 Geth 文档[此处](https://geth.ethereum.org/docs/interface/managing-your-accounts)找到使用 keystore 安全创建新以太坊账户的说明。

下面提供了一个示例。

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

现在，您可以像这样设置环境变量：

```ini
PEGGO_ETH_KEYSTORE_DIR=/home/ec2-user/.peggo/data/keystore
PEGGO_ETH_FROM=0x9782dc957DaE6aDc394294954B27e2118D05176C
PEGGO_ETH_PASSPHRASE=12345678
```

接下来，确保您的以太坊地址有 Sepolia ETH。您可以从公共水龙头[此处](https://www.alchemy.com/faucets/ethereum-sepolia)请求 Sepolia ETH。

### **2. 以太坊私钥（不安全）**

只需使用新账户的新以太坊私钥更新 `PEGGO_ETH_PK`。

接下来，确保您的以太坊地址有 Sepolia ETH。您可以从公共水龙头[此处](https://www.alchemy.com/faucets/ethereum-sepolia)请求 Sepolia ETH。

### 步骤 2：注册您的 Orchestrator 和以太坊地址

您只能注册一次 orchestrator 和以太坊地址。以后**无法**更新。因此在运行以下命令之前请检查两次。

```bash
biyachaind tx peggy set-orchestrator-address $VALIDATOR_BIYA_ADDRESS $ORCHESTRATOR_BIYA_ADDRESS $ETHEREUM_ADDRESS --from $VALIDATOR_KEY_NAME --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=160000000biya

```

* To obtain your validator's biya address, run, `biyachaind keys list $VALIDATOR_KEY_NAME`
* To obtain your orchestrators's biya address, `biyachaind keys list $ORCHESTRATOR_KEY_NAME`

Example:

```bash
biyachaind tx peggy set-orchestrator-address biya10m247khat0esnl0x66vu9mhlanfftnvww67j9n biya1x7kvxlz2epqx3hpq6v8j8w859t29pgca4z92l2 0xf79D16a79130a07e77eE36e8067AeA783aBdA3b6 --from validator-key-name --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=160000000biya
```

您可以通过在 https://testnet.sentry.lcd.biyachain.network/peggy/v1/valset/current 上检查验证器的映射以太坊地址来验证注册是否成功。

{% hint style="info" %}
**注意：** 一旦您使用 `set-orchestrator-address` 消息注册了 Orchestrator，您**无法**再次注册。一旦此步骤完成，您的 `Validator` 就绑定到提供的以太坊地址（以及您可能提供的委托地址）。换句话说，您的 peggo 必须始终使用您为注册提供的地址运行。
{% endhint %}

## 步骤 3：启动中继器

```bash
peggo orchestrator
```

这将启动 Peggo 桥接（中继器 / orchestrator）。

## 步骤 4：创建 Peggo systemd 服务

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

然后，运行以下命令配置环境变量、启动和停止 peggo 中继器。

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

## 步骤 5：（可选）保护 Cosmos 密钥环免受未授权访问

{% hint style="warning" %}
这是一个高级 DevOps 主题，请咨询您的系统管理员。
{% endhint %}

在[此处](https://docs.cosmos.network/v0.46/run-node/keyring.html)了解更多有关 Cosmos 密钥环设置的信息。一旦您启动了节点，默认密钥环将以加密形式在磁盘上存储验证器运营者密钥。通常，密钥环位于节点的主目录内，即 `~/.biyachaind/keyring-file`。

Biyachain 质押文档的某些部分将指导您将此密钥用于治理目的，即提交交易和设置以太坊桥接。为了保护密钥免受未授权访问，即使密钥环密码短语通过配置泄露，您也可以设置操作系统权限，仅允许 `biyachaind` / `peggo` 进程访问磁盘。

在 Debian、Ubuntu 和 RHEL 等 Linux 系统中，可以使用 POSIX 访问控制列表 (ACL) 来实现这一点。在开始使用 ACL 之前，必须启用 ACL 挂载文件系统。每个发行版都有一些官方指南：

* [Ubuntu](https://help.ubuntu.com/community/FilePermissionsACLs)
* [Debian](https://wiki.debian.org/Permissions)
* [Amazon Linux (RHEL)](https://www.redhat.com/sysadmin/linux-access-control-lists)

## 测试网

## 步骤 1：配置 Peggo 中继器

```bash
mkdir ~/.peggo
cp testnet-config/40014/peggo-config.env ~/.peggo/.env
cd ~/.peggo
```

首先，使用有效的以太坊 EVM RPC 端点更新 `.env` 文件中的 `PEGGO_ETH_RPC`。

要创建您自己的以太坊全节点，您可以按照我们的说明[此处](https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/)进行操作。可以使用外部以太坊 RPC 提供商（如 Alchemy 或 Infura），但请注意，Peggo 桥接中继器大量使用 `eth_getLogs` 调用，这可能会根据您的提供商增加您的成本负担。

Peggo 还需要访问验证器的委托 Biyachain 链账户和以太坊密钥凭证，以便为相应网络签署交易。

### **创建用于发送 Biyachain 交易的委托 Cosmos 密钥**

您的 peggo 中继器可以：

* 使用专门用于发送验证器特定 Peggy 交易（即 `ValsetConfirm`、`BatchConfirm` 和 `SendToCosmos` 交易）的明确委托账户密钥，或
* 简单地使用验证器的账户密钥。

为了隔离目的，我们建议创建委托的 Cosmos 密钥来发送 Biyachain 交易，而不是使用验证器账户密钥。

To create a new key, run:

```bash
biyachaind keys add $ORCHESTRATOR_KEY_NAME
```

Then, ensure that your orchestrator biya address has BIYA balance.

To obtain your orchestrators's biya address, run:

```bash
biyachaind keys list $ORCHESTRATOR_KEY_NAME
```

You can transfer BIYA from your validator account to orchestrator address using this command:

```bash
biyachaind tx bank send $VALIDATOR_KEY_NAME  $ORCHESTRATOR_BIYA_ADDRESS <amount-in-biya> --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

Example:

```bash
biyachaind tx bank send genesis biya1u3eyz8nkvym0p42h79aqgf37gckf7szreacy9e 20000000000000000000biya --chain-id=biyachain-888  --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

You can then verify that your orchestrator account has BIYA balances by running:

```bash
biyachaind q bank balances $ORCHESTRATOR_BIYA_ADDRESS
```

### **Managing Cosmos account keys for `peggo`**

Peggo supports two options to provide Cosmos signing key credentials - using the Cosmos keyring (recommended), or by providing a plaintext private key.

#### **Option 1. Cosmos Keyring**

In the `.env` file, first specify the `PEGGO_COSMOS_FROM` and `PEGGO_COSMOS_FROM_PASSPHRASE` corresponding to your peggo account signing key.

If you are using a delegated account key configuration as recommended above, this will be your `$ORCHESTRATOR_KEY_NAME` and passphrase, respectively. Otherwise, this should be your `$VALIDATOR_KEY_NAME` and associated validator passphrase.

Please note that the default keyring backend is `file` and that, as such, peggo will try to locate keys on disk by default.

To use the default biyachaind key configuration, you should set the keyring path to the home directory of your biyachaind node, e.g. `~/.biyachaind`.

You can also read more about the Cosmos Keyring setup [here](https://docs.cosmos.network/v0.46/run-node/keyring.html).

#### **Option 2. Cosmos Private Key (Unsafe)**

In the `.env` file, specify the `PEGGO_COSMOS_PK` corresponding to your peggo account signing key.

If you are using a delegated account key configuration as recommended above, this will be your orchestrator account's private key. Otherwise, this should be your validator's account private key.

To obtain your orchestrator's Cosmos private key (if applicable), run:

```bash
biyachaind keys unsafe-export-eth-key $ORCHESTRATOR_KEY_NAME
```

To obtain your validator's Cosmos private key (if applicable), run:

```bash
biyachaind keys unsafe-export-eth-key $VALIDATOR_KEY_NAME
```

Again, this method is less secure and is not recommended.

### **Managing Ethereum keys for `peggo`**

Peggo supports two options to provide signing key credentials - using the Geth keystore (recommended), or by providing a plaintext Ethereum private key.

#### **Option 1. Geth Keystore**

Simply create a new private key store and update the following env variables:

* `PEGGO_ETH_KEYSTORE_DIR`
* `PEGGO_ETH_FROM`
* `PEGGO_ETH_PASSPHRASE`

You can find instructions for securely creating a new Ethereum account using a keystore in the Geth Documentation [here](https://geth.ethereum.org/docs/interface/managing-your-accounts).

For convience, an example is provided below.

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

Make sure you heed the warnings that geth provides, particularly in backing up your key file so that you don't lose your keys by mistake. We also recommend not using any quote or backtick characters in your passphrase for peggo compatibility purposes.

You should now set the following env variables:

```bash
# example values, replace with your own
PEGGO_ETH_KEYSTORE_DIR=/home/ec2-user/.peggo/data/keystore
PEGGO_ETH_FROM=0x9782dc957DaE6aDc394294954B27e2118D05176C
PEGGO_ETH_PASSPHRASE=12345678
```

Then, ensure that your Ethereum address has enough ETH.

#### **Option 2. Ethereum Private Key (Unsafe)**

Simply update the `PEGGO_ETH_PK` with a new Ethereum Private Key from a new account.

Then, ensure that your Ethereum address has ETH.

## 步骤 2：注册您的 Orchestrator 和以太坊地址

您只能注册一次 orchestrator 和以太坊地址。以后**无法**更新。因此在运行以下命令之前请检查两次。

```bash
biyachaind tx peggy set-orchestrator-address $VALIDATOR_BIYA_ADDRESS $ORCHESTRATOR_BIYA_ADDRESS $ETHEREUM_ADDRESS --from $VALIDATOR_KEY_NAME --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya

```

* To obtain your validator's biya address, run, `biyachaind keys list $VALIDATOR_KEY_NAME`
* To obtain your orchestrators's biya address, `biyachaind keys list $ORCHESTRATOR_KEY_NAME`

Example:

```bash
biyachaind tx peggy set-orchestrator-address biya10m247khat0esnl0x66vu9mhlanfftnvww67j9n biya1x7kvxlz2epqx3hpq6v8j8w859t29pgca4z92l2 0xf79D16a79130a07e77eE36e8067AeA783aBdA3b6 --from validator-key-name --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657 --gas-prices=500000000biya
```

您可以通过在 https://testnet.lcd.biyachain.dev/peggy/v1/valset/current 上检查验证器的映射以太坊地址来验证注册是否成功。

## 步骤 3：启动中继器

```bash
cd ~/.peggo
peggo orchestrator
```

这将启动 Peggo 桥接（中继器 / orchestrator）。

## 步骤 4：创建 Peggo systemd 服务

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

然后，运行以下命令配置环境变量、启动和停止 peggo 中继器：

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

## 步骤 5：（可选）保护 Cosmos 密钥环免受未授权访问

{% hint style="warning" %}
这是一个高级 DevOps 主题，请咨询您的系统管理员。
{% endhint %}

在[此处](https://docs.cosmos.network/v0.46/run-node/keyring.html)了解更多有关 Cosmos 密钥环设置的信息。一旦您启动了节点，默认密钥环将以加密形式在磁盘上存储验证器运营者密钥。通常，密钥环位于节点的主目录内，即 `~/.biyachaind/keyring-file`。

Biyachain 质押文档的某些部分将指导您将此密钥用于治理目的，即提交交易和设置以太坊桥接。为了保护密钥免受未授权访问，即使密钥环密码短语通过配置泄露，您也可以设置操作系统权限，仅允许 `biyachaind` / `peggo` 进程访问磁盘。

在 Debian、Ubuntu 和 RHEL 等 Linux 系统中，可以使用 POSIX 访问控制列表 (ACL) 来实现这一点。在开始使用 ACL 之前，必须启用 ACL 挂载文件系统。每个发行版都有一些官方指南：

* [Ubuntu](https://help.ubuntu.com/community/FilePermissionsACLs)
* [Debian](https://wiki.debian.org/Permissions)
* [Amazon Linux (RHEL)](https://www.redhat.com/sysadmin/linux-access-control-lists)

## 贡献

如果您想检查 Peggo orchestrator 源代码并做出贡献，可以在 [https://github.com/biya-coin/peggo](https://github.com/biya-coin/peggo) 进行
