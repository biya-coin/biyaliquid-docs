# 测试网验证器

节点运营者应部署裸机服务器以实现最佳性能。此外，验证器节点必须满足推荐的硬件规格，特别是 CPU 要求，以确保高正常运行时间。

#### 硬件要求

|       _最低要求_       |    _推荐配置_   |
| :-------------------: | :-------------------: |
|    内存 128GB   |    内存 128GB   |
|      CPU 12 核     |      CPU 16 核     |
| CPU 基础频率 3.7GHz | CPU 基础频率 4.2GHz |
|    存储 2TB NVMe   |    存储 2TB NVMe   |
|     网络 1Gbps+    |     网络 1Gbps+    |

### 步骤 1：创建验证器账户

首先，使用您想要的验证器密钥名称运行密钥生成命令。

```bash
export VALIDATOR_KEY_NAME=[my-validator-key]
biyachaind keys add $VALIDATOR_KEY_NAME
```

这将派生一个新的私钥并将其加密到磁盘。请确保记住您使用的密码。

```bash
# EXAMPLE OUTPUT
- name: myvalidatorkey
  type: local
  address: biya1queq795wx8gzqc8706uz80whp07mcgg5nmpj6h
  pubkey: biyapub1r0mckeepqwzmrzt5af00hgc7fhve05rr0q3q6wvx4xn6k46zguzykdszg6cnu0zca4q
  mnemonic: ""
  threshold: 0
  pubkeys: []


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.
```

{% hint style="warning" %}
**输出将包含以明文形式表示您密钥的助记词短语。请确保将此短语保存为密钥的备份，因为没有密钥您将无法控制验证器。最好将短语备份在物理纸张上，存储在云存储中可能会在以后危及您的验证器。**

记住以 `biya` 开头的地址，这将是您的 Biya Chain 链验证器账户地址。
{% endhint %}

### 步骤 2：获取 BIYA

要继续下一步，您需要在 Biya Chain 上获取一些 BIYA。

您可以从[测试网水龙头](https://faucet.biyachain.network/)请求资金。

几分钟后，您应该能够在 UI 上验证您的存款是否成功。或者，您可以使用 `biyachaind` CLI 通过以下命令查询账户余额：

```bash
biyachaind q bank balances <my-validator-biya-address>
```

### 步骤 3：创建验证器账户

获取节点的 Tendermint 验证器 Bech32 编码的 PubKey 共识地址。

```bash
VALIDATOR_PUBKEY=$(biyachaind tendermint show-validator)
echo $VALIDATOR_PUBKEY

# Example: {"@type": "/cosmos.crypto.ed25519.PubKey", "key": "GWEJv/KSFhUUcKBWuf9TTT3Ful+3xV/1lFhchyW1TZ8="}
```

然后使用您的 BIYA 代币创建新的验证器，并进行自委托。最重要的是，您需要决定验证器的质押参数值。

* `--moniker` - 验证器名称
* `--amount` - 验证器初始绑定的 BIYA 数量
* `--commission-max-change-rate` - 验证器的最大佣金变化率百分比（每天）
* `--commission-max-rate` - 验证器的最大佣金率百分比
* `--commission-rate` - 验证器的初始佣金率百分比
* `--min-self-delegation` - 验证器所需的最小自委托

Once you decide on your desired values, set them as follows.

```bash
MONIKER=<my-moniker>
AMOUNT=100000000000000000000biya # to delegate 100 BIYA, as BIYA is represented with 18 decimals.
COMMISSION_MAX_CHANGE_RATE=0.1 # e.g. for a 10% maximum change rate percentage per day
COMMISSION_MAX_RATE=0.1 # e.g. for a 10% maximum commission rate percentage
COMMISSION_RATE=0.1 # e.g. for a 10% initial commission rate percentage
MIN_SELF_DELEGATION_AMOUNT=50000000000000000000 # e.g. for a minimum 50 BIYA self delegation required on the validator
```

Then run the following command to create your validator.

```bash
biyachaind tx staking create-validator \
--moniker=$MONIKER \
--amount=$AMOUNT \
--gas-prices=500000000biya \
--pubkey=$VALIDATOR_PUBKEY \
--from=$VALIDATOR_KEY_NAME \
--keyring-backend=file \
--yes \
--node=tcp://localhost:26657 \
--chain-id=biyachain-888
--commission-max-change-rate=$COMMISSION_MAX_CHANGE_RATE \
--commission-max-rate=$COMMISSION_MAX_RATE \
--commission-rate=$COMMISSION_RATE \
--min-self-delegation=$MIN_SELF_DELEGATION_AMOUNT
```

Extra `create-validator` options to consider:

```
--identity=        		The optional identity signature (ex. UPort or Keybase)
--pubkey=          		The Bech32 encoded PubKey of the validator
--security-contact=		The validator's (optional) security contact email
--website=         		The validator's (optional) website
```

您可以通过检查[质押仪表板](https://prv.hub.biya.io/stake/)，并向下滚动到"验证器"部分来检查验证器是否成功创建。

或者，输入以下 CLI 命令：

```bash
biyachaind q staking validators
```

如果您在验证器列表中看到您的验证器，那么恭喜您，您已正式成为 Equinox Staking 验证器！🎉

### 步骤 4：（可选）向验证器委托额外的 BIYA

为了更深入地了解您未来的委托者将体验的用户体验，您可以完成[质押指南](https://medium.com/biyachain-labs/biyachain-hub-guide-9a14f09f6a7d)中的剩余步骤。

这些步骤将允许您使用 MetaMask 交易体验委托流程。🦊

或者，您始终可以使用 Biya Chain CLI 发送委托交易。

```bash
biyachaind tx staking delegate [validator-addr] [amount] --from $VALIDATOR_KEY_NAME --chain-id=biyachain-888 --keyring-backend=file --yes --node=tcp://localhost:26657
```

### 下一步

接下来，继续设置您的以太坊桥接中继器。这是防止验证器被削减的必要步骤。您应该在设置验证器后立即执行此操作。
