# 主网开发

本指南将帮助您了解在 Biyachain 主网（Mainnet）上部署和实例化 CosmWasm 智能合约的治理流程。

### 提交代码上传提案

在本节中，您将学习如何提交智能合约代码提案并对其进行投票。

Biyachain 网络的参与者可以提议智能合约部署，并在治理中投票使其生效。wasmd 授权设置由链上治理决定，这意味着合约的部署完全由治理决定。因此，治理提案是将合约上传到 Biyachain 主网的第一步。

以下是使用 `biyachaind` 启动治理提案将代码上传到链上的示例用法：

```bash
biyachaind tx wasm submit-proposal wasm-store artifacts/cw_controller.wasm
--title="Proposal Title" \
--summary="Proposal Summary" \
--instantiate-everybody true \
--broadcast-mode=sync \
--chain-id=biyachain-1 \
--node=https://sentry.tm.biyachain.network:443 \
--deposit=100000000000000000000biya \
--gas=20000000 \
--gas-prices=160000000biya \
--from [YOUR_KEY] \
--yes \
--output json
```

命令 `biyachaind tx gov submit-proposal wasm-store` 提交一个 wasm 二进制提案。如果提案获得治理批准，代码将被部署。

让我们了解两个关键的标志：`instantiate-everybody` 和 `instantiate-only-address`，这两个标志设置上传代码的实例化权限。默认情况下，任何人都可以实例化合约。

```bash
--instantiate-everybody boolean # Everybody can instantiate a contract from the code, optional
--instantiate-only-address string # Only this address can instantiate a contract instance from the code
```

### 合约实例化（无治理）

在大多数情况下，你不需要提交另一个治理提案来进行实例化。只需使用 biyachaind tx wasm instantiate 进行实例化即可。你只需要通过治理提案来上传合约。如果合约设置了 `--instantiate-everybody` 标志为 `false`，并且 `--instantiate-only-address` 标志设置为治理模块，才需要通过治理来实例化。`--instantiate-everybody` 的默认值为 `true`，在这种情况下，你可以通过 biyachaind tx wasm instantiate 无需许可地进行实例化。

```bash
biyachaind tx wasm instantiate [code_id_int64] [json_encoded_init_args] --label [text] --admin [address,optional] --amount [coins,optional]  [flags]
```

```bash
Flags:
  -a, --account-number uint      The account number of the signing account (offline mode only)
      --admin string             Address or key name of an admin
      --amount string            Coins to send to the contract during instantiation
      --aux                      Generate aux signer data instead of sending a tx
  -b, --broadcast-mode string    Transaction broadcasting mode (sync|async) (default "sync")
      --chain-id string          The network chain ID
      --dry-run                  ignore the --gas flag and perform a simulation of a transaction, but don't broadcast it (when enabled, the local Keybase is not accessible)
      --fee-granter string       Fee granter grants fees for the transaction
      --fee-payer string         Fee payer pays fees for the transaction instead of deducting from the signer
      --fees string              Fees to pay along with transaction; eg: 10uatom
      --from string              Name or address of private key with which to sign
      --gas string               gas limit to set per-transaction; set to "auto" to calculate sufficient gas automatically. Note: "auto" option doesn't always report accurate results. Set a valid coin value to adjust the result. Can be used instead of "fees". (default 200000)
      --gas-adjustment float     adjustment factor to be multiplied against the estimate returned by the tx simulation; if the gas limit is set manually this flag is ignored  (default 1)
      --gas-prices string        Gas prices in decimal format to determine the transaction fee (e.g. 0.1uatom)
      --generate-only            Build an unsigned transaction and write it to STDOUT (when enabled, the local Keybase only accessed when providing a key name)
  -h, --help                     help for instantiate
      --keyring-backend string   Select keyring's backend (os|file|kwallet|pass|test|memory) (default "os")
      --keyring-dir string       The client Keyring directory; if omitted, the default 'home' directory will be used
      --label string             A human-readable name for this contract in lists
      --ledger                   Use a connected Ledger device
      --no-admin                 You must set this explicitly if you don't want an admin
      --node string              <host>:<port> to tendermint rpc interface for this chain (default "tcp://localhost:26657")
      --note string              Note to add a description to the transaction (previously --memo)
      --offline                  Offline mode (does not allow any online functionality)
  -o, --output string            Output format (text|json) (default "json")
  -s, --sequence uint            The sequence number of the signing account (offline mode only)
      --sign-mode string         Choose sign mode (direct|amino-json|direct-aux), this is an advanced feature
      --timeout-height uint      Set a block timeout height to prevent the tx from being committed past a certain height
      --tip string               Tip is the amount that is going to be transferred to the fee payer on the target chain. This flag is only valid when used with --aux, and is ignored if the target chain didn't enable the TipDecorator
  -y, --yes                      Skip tx broadcasting prompt confirmation
```

一个 biyachaind tx wasm instantiate 的示例如下所示：

```bash
biyachaind tx wasm instantiate \
150 \
'{"bank": "biya1egl894wme0d4d029hlv3kuqs0mc9atep2s89h8"}' \
--label="LABEL" \
--from=biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c \
--chain-id=biyachain-1 \
--yes \
--gas-prices 160000000biya \
--gas=10000000 \
--no-admin \
--node=https://sentry.tm.biyachain.network:443 \
```

### 合约实例化 (有治理)

如上所述，主网合约实例化权限取决于上传代码时使用的标志。默认情况下，设置为无需许可，正如我们在 Genesis wasmd Biyachain 设置中可以验证的那样：

```json
"wasm": {
            "codes": [],
            "contracts": [],
            "gen_msgs": [],
            "params": {
                "code_upload_access": {
                    "address": "",
                    "permission": "Everybody"
                },
                "instantiate_default_permission": "Everybody"
            },
            "sequences": []
        }
```

然而，如果 `--instantiate-everybody` 标志设置为 `false`，那么合约实例化必须通过治理进行。

{% hint style="info" %}
Biyachain 测试网默认是无需许可的，以便允许开发者轻松部署合约。
{% endhint %}

**合约实例化提案**

```bash
 biyachaind tx gov submit-proposal instantiate-contract [code_id_int64] [json_encoded_init_args] --label [text] --title [text] --description [text] --run-as [address] --admin [address,optional] --amount [coins,optional] [flags]
```

```bash
Flags:
  -a, --account-number uint      The account number of the signing account (offline mode only)
      --admin string             Address of an admin
      --amount string            Coins to send to the contract during instantiation
  -b, --broadcast-mode string    Transaction broadcasting mode (sync|async|block) (default "sync")
      --deposit string           Deposit of proposal
      --description string       Description of proposal
      --dry-run                  ignore the --gas flag and perform a simulation of a transaction, but dont broadcast it (when enabled, the local Keybase is not accessible)
      --fee-account string       Fee account pays fees for the transaction instead of deducting from the signer
      --fees string              Fees to pay along with transaction; eg: 10uatom
      --from string              Name or address of private key with which to sign
      --gas string               gas limit to set per-transaction; set to "auto" to calculate sufficient gas automatically (default 200000)
      --gas-adjustment float     adjustment factor to be multiplied against the estimate returned by the tx simulation; if the gas limit is set manually this flag is ignored  (default 1)
      --gas-prices string        Gas prices in decimal format to determine the transaction fee (e.g. 0.1uatom)
      --generate-only            Build an unsigned transaction and write it to STDOUT (when enabled, the local Keybase is not accessible)
  -h, --help                     help for instantiate-contract
      --keyring-backend string   Select keyrings backend (os|file|kwallet|pass|test|memory) (default "os")
      --keyring-dir string       The client Keyring directory; if omitted, the default 'home' directory will be used
      --label string             A human-readable name for this contract in lists
      --ledger                   Use a connected Ledger device
      --no-admin                 You must set this explicitly if you dont want an admin
      --node string              <host>:<port> to tendermint rpc interface for this chain (default "tcp://localhost:26657")
      --note string              Note to add a description to the transaction (previously --memo)
      --offline                  Offline mode (does not allow any online functionality
  -o, --output string            Output format (text|json) (default "json")
      --proposal string          Proposal file path (if this path is given, other proposal flags are ignored)
      --run-as string            The address that pays the init funds. It is the creator of the contract and passed to the contract as sender on proposal execution
  -s, --sequence uint            The sequence number of the signing account (offline mode only)
      --sign-mode string         Choose sign mode (direct|amino-json), this is an advanced feature
      --timeout-height uint      Set a block timeout height to prevent the tx from being committed past a certain height
      --title string             Title of proposal
      --type string              Permission of proposal, types: store-code/instantiate/migrate/update-admin/clear-admin/text/parameter_change/software_upgrade
  -y, --yes                      Skip tx broadcasting prompt confirmation
```

### 合约迁移

迁移是通过它可以替换或“升级”给定智能合约代码的过程。\
在实例化合约时，有一个可选的管理员字段可以设置。如果该字段为空，合约将是不可变的。如果设置了管理员（指向外部账户或治理合约），该账户可以触发迁移。管理员还可以重新分配管理员角色，或者如果需要的话，使合约完全不可变。然而，值得注意的是，在从旧合约迁移到新合约时，新合约需要了解之前如何编码状态。\
关于迁移的技术细节可以在 [CosmWasm 迁移文档](https://docs.cosmwasm.com/docs/smart-contracts/migration)中找到更详细的描述。
