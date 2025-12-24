# 本地开发

本指南将帮助您开始在计算机上运行的本地 Biya Chain 网络上部署 `cw20` 智能合约。

我们将使用来自 [CosmWasm 的规范和合约集合](https://github.com/CosmWasm/cw-plus) 的 `cw20-base` 合约,该合约专为在真实网络上的生产使用而设计。`cw20-base` 是 `cw20` 兼容合约的基本实现,可以导入到您想要构建的任何自定义合约中。它包含 cw20 规范的直接但完整的实现以及所有扩展。`cw20-base` 可以按原样部署或由其他合约导入。

### 先决条件

按照以下说明安装 Go、Rust 和其他 Cosmwasm 依赖项:

1. [Go](https://docs.cosmwasm.com/docs/getting-started/installation#go)
2. [Rust](https://docs.cosmwasm.com/docs/getting-started/installation#rust)

在开始之前,请确保已安装 [`rustup`](https://rustup.rs/) 以及最新版本的 `rustc` 和 `cargo`。目前,我们在 Rust v1.58.1+ 上进行测试。

您还需要安装 `wasm32-unknown-unknown` 目标以及 `cargo-generate` Rust crate。

您可以通过以下命令检查版本:

```bash
rustc --version
cargo --version
rustup target list --installed
# if wasm32 is not listed above, run this
rustup target add wasm32-unknown-unknown
# to install cargo-generate, run this
cargo install cargo-generate
```

### biyachaind

确保您已在本地安装 `biyachaind`。您可以按照 [install-biyachaind.md](../developers/biyachaind/install.md "mention") 指南在本地运行 `biyachaind` 和其他先决条件。

安装 `biyachaind` 后,您还应该 [启动本地链实例](..//developers/biyachaind/install.md#start-biyachaind)。

### 编译 CosmWasm 合约

在此步骤中,我们将获取所有 CW 生产模板合约,并使用 [CosmWasm Rust Optimizer](https://github.com/CosmWasm/rust-optimizer) Docker 镜像编译它们,该镜像用于编译多个合约(称为 `workspace-optimizer`)——请参阅 [这里](https://hub.docker.com/r/cosmwasm/workspace-optimizer/tags) (x86) 或 [这里](https://hub.docker.com/r/cosmwasm/workspace-optimizer-arm64/tags) (ARM) 获取最新版本。此过程可能需要一些时间和 CPU 资源。

```bash
git clone https://github.com/CosmWasm/cw-plus
cd cw-plus
```

Non ARM (Non-Apple silicon) devices:

```bash
docker run --rm -v "$(pwd)":/code \
--mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
cosmwasm/workspace-optimizer:0.12.12
```

Alternatively for Apple Silicon devices (M1, M2, etc.) please use:

```bash
docker run --rm -v "$(pwd)":/code \
--mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
cosmwasm/workspace-optimizer-arm64:0.12.12
```

docker 脚本构建并优化仓库中的所有 CW 合约,编译的合约位于 `artifacts` 目录下。现在我们可以部署 `cw20_base.wasm` 合约(如果在 ARM 设备上编译,则为 `cw20_base-aarch64.wasm`)。

### 将 CosmWasm 合约上传到链

```bash
# inside the CosmWasm/cw-plus repo 
yes 12345678 | biyachaind tx wasm store artifacts/cw20_base.wasm --from=genesis --chain-id="biyachain-1" --yes --gas-prices=500000000biya --gas=20000000
```

**Output:**

```
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: 4CFB63A47570C4CFBE8E669273B26BEF6EAFF922C07480CA42180C52219CE784
```

然后通过 `txhash` 查询交易以验证合约确实已部署。

```bash
biyachaind query tx 4CFB63A47570C4CFBE8E669273B26BEF6EAFF922C07480CA42180C52219CE784
```

**Output:**

```bash
code: 0
codespace: ""
data: 0A460A1E2F636F736D7761736D2E7761736D2E76312E4D736753746F7265436F64651224080112205F8201CF5E2D7E6C15DB11ADF03D62DDDDC92B8D4FAE98C4F3C1C37F378E15D9
events:
- attributes:
  - index: true
    key: YWNjX3NlcQ==
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204LzE=
  type: tx
- attributes:
  - index: true
    key: c2lnbmF0dXJl
    value: R29McmoxaDBtelNWN085SUNScStLbDdCVmdocDB6aU5EQ0Jwc1dFS1I1TlNXZkR2V1ZJejF0TEpGb0ZwSzlhNkFIQVdSVkZRNjExYitwSHdpY04wN1FFPQ==
  type: tx
- attributes:
  - index: true
    key: c3BlbmRlcg==
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204
  - index: true
    key: YW1vdW50
    value: MTAwMDAwMDAwMDAwMDAwMDBpbmo=
  type: coin_spent
- attributes:
  - index: true
    key: cmVjZWl2ZXI=
    value: aW5qMTd4cGZ2YWttMmFtZzk2MnlsczZmODR6M2tlbGw4YzVsNnM1eWU5
  - index: true
    key: YW1vdW50
    value: MTAwMDAwMDAwMDAwMDAwMDBpbmo=
  type: coin_received
- attributes:
  - index: true
    key: cmVjaXBpZW50
    value: aW5qMTd4cGZ2YWttMmFtZzk2MnlsczZmODR6M2tlbGw4YzVsNnM1eWU5
  - index: true
    key: c2VuZGVy
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204
  - index: true
    key: YW1vdW50
    value: MTAwMDAwMDAwMDAwMDAwMDBpbmo=
  type: transfer
- attributes:
  - index: true
    key: c2VuZGVy
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204
  type: message
- attributes:
  - index: true
    key: ZmVl
    value: MTAwMDAwMDAwMDAwMDAwMDBpbmo=
  - index: true
    key: ZmVlX3BheWVy
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204
  type: tx
- attributes:
  - index: true
    key: YWN0aW9u
    value: L2Nvc213YXNtLndhc20udjEuTXNnU3RvcmVDb2Rl
  type: message
- attributes:
  - index: true
    key: bW9kdWxl
    value: d2FzbQ==
  - index: true
    key: c2VuZGVy
    value: aW5qMTByZHN4ZGdyOGw4czBndnU4cnluaHUyMm5ueGtmeXRnNThjd204
  type: message
- attributes:
  - index: true
    key: Y29kZV9jaGVja3N1bQ==
    value: NWY4MjAxY2Y1ZTJkN2U2YzE1ZGIxMWFkZjAzZDYyZGRkZGM5MmI4ZDRmYWU5OGM0ZjNjMWMzN2YzNzhlMTVkOQ==
  - index: true
    key: Y29kZV9pZA==
    value: MQ==
  type: store_code
- attributes:
  - index: true
    key: YWNjZXNzX2NvbmZpZw==
    value: eyJwZXJtaXNzaW9uIjoiRXZlcnlib2R5IiwiYWRkcmVzcyI6IiIsImFkZHJlc3NlcyI6W119
  - index: true
    key: Y2hlY2tzdW0=
    value: Ilg0SUJ6MTR0Zm13VjJ4R3Q4RDFpM2QzSks0MVBycGpFODhIRGZ6ZU9GZGs9Ig==
  - index: true
    key: Y29kZV9pZA==
    value: IjEi
  - index: true
    key: Y3JlYXRvcg==
    value: ImluajEwcmRzeGRncjhsOHMwZ3Z1OHJ5bmh1MjJubnhrZnl0ZzU4Y3dtOCI=
  type: cosmwasm.wasm.v1.EventCodeStored
gas_used: "2158920"
gas_wanted: "20000000"
height: "47"
info: ""
logs:
- events:
  - attributes:
    - key: access_config
      value: '{"permission":"Everybody","address":"","addresses":[]}'
    - key: checksum
      value: '"X4IBz14tfmwV2xGt8D1i3d3JK41PrpjE88HDfzeOFdk="'
    - key: code_id
      value: '"1"'
    - key: creator
      value: '"biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8"'
    type: cosmwasm.wasm.v1.EventCodeStored
  - attributes:
    - key: action
      value: /cosmwasm.wasm.v1.MsgStoreCode
    - key: module
      value: wasm
    - key: sender
      value: biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8
    type: message
  - attributes:
    - key: code_checksum
      value: 5f8201cf5e2d7e6c15db11adf03d62ddddc92b8d4fae98c4f3c1c37f378e15d9
    - key: code_id
      value: "1"
    type: store_code
  log: ""
  msg_index: 0
raw_log: '[{"events":[{"type":"cosmwasm.wasm.v1.EventCodeStored","attributes":[{"key":"access_config","value":"{\"permission\":\"Everybody\",\"address\":\"\",\"addresses\":[]}"},{"key":"checksum","value":"\"X4IBz14tfmwV2xGt8D1i3d3JK41PrpjE88HDfzeOFdk=\""},{"key":"code_id","value":"\"1\""},{"key":"creator","value":"\"biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8\""}]},{"type":"message","attributes":[{"key":"action","value":"/cosmwasm.wasm.v1.MsgStoreCode"},{"key":"module","value":"wasm"},{"key":"sender","value":"biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8"}]},{"type":"store_code","attributes":[{"key":"code_checksum","value":"5f8201cf5e2d7e6c15db11adf03d62ddddc92b8d4fae98c4f3c1c37f378e15d9"},{"key":"code_id","value":"1"}]}]}]'
timestamp: "2023-03-06T15:48:30Z"
tx:
  '@type': /cosmos.tx.v1beta1.Tx
  auth_info:
    fee:
      amount:
      - amount: "10000000000000000"
        denom: biya
      gas_limit: "20000000"
      granter: ""
      payer: ""
    signer_infos:
    - mode_info:
        single:
          mode: SIGN_MODE_DIRECT
      public_key:
        '@type': /biyachain.crypto.v1beta1.ethsecp256k1.PubKey
        key: Ay+cc/lvd4Mn4pbgFkN87vWDaCXuXjVJYJGsdhrD09vk
      sequence: "1"
  body:
    extension_options: []
    memo: ""
    messages:
    - '@type': /cosmwasm.wasm.v1.MsgStoreCode
      instantiate_permission: null
      sender: biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8
      wasm_byte_code: YOUR_WASM_BYTE_HERE
    non_critical_extension_options: []
    timeout_height: "0"
  signatures:
  - GoLrj1h0mzSV7O9ICRq+Kl7BVghp0ziNDCBpsWEKR5NSWfDvWVIz1tLJFoFpK9a6AHAWRVFQ611b+pHwicN07QE=
txhash: 4CFB63A47570C4CFBE8E669273B26BEF6EAFF922C07480CA42180C52219CE784
```

更仔细地检查输出,我们可以看到合约的 `code_id` 为 1

```bash
logs:
- events:
  - attributes:
    - key: access_config
      value: '{"permission":"Everybody","address":"","addresses":[]}'
    - key: checksum
      value: '"X4IBz14tfmwV2xGt8D1i3d3JK41PrpjE88HDfzeOFdk="'
    - key: code_id
      value: '"1"'
    - key: creator
      value: '"biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8"'
    type: cosmwasm.wasm.v1.EventCodeStored
  - attributes:
    - key: action
      value: /cosmwasm.wasm.v1.MsgStoreCode
    - key: module
      value: wasm
    - key: sender
      value: biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8
    type: message
  - attributes:
    - key: code_checksum
      value: 5f8201cf5e2d7e6c15db11adf03d62ddddc92b8d4fae98c4f3c1c37f378e15d9
    - key: code_id
      value: "1"
    type: store_code
  log: ""
  msg_index: 0
```

我们已经上传了合约代码,但我们仍然需要实例化合约。

### 实例化合约

在实例化合约之前,让我们看一下 CW-20 合约的 `instantiate` 函数签名。

```rust
#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    mut deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
```

值得注意的是,它包含 `InstantiateMsg` 参数,其中包含代币名称、符号、小数位数和其他详细信息。

```rust
#[derive(Serialize, Deserialize, JsonSchema, Debug, Clone, PartialEq)]
pub struct InstantiateMsg {
    pub name: String,
    pub symbol: String,
    pub decimals: u8,
    pub initial_balances: Vec<Cw20Coin>,
    pub mint: Option<MinterResponse>,
    pub marketing: Option<InstantiateMarketingInfo>,
}
```

实例化合约的第一步是选择一个地址来提供我们的初始 CW20 代币分配。在我们的例子中,我们可以只使用创世地址,因为我们已经设置了密钥,但您可以随意生成新的地址和密钥。

{% hint style="warning" %}
确保您拥有所选地址的私钥——否则您将无法测试从该地址转移代币。此外,所选地址必须是链上的有效地址(该地址必须在过去某个时间点收到过资金),并且必须有余额来支付执行合约时的 gas 费用。
{% endhint %}

要找到创世地址,请运行:

```bash
yes 12345678 | biyachaind keys show genesis
```

**Output:**

```bash
- name: genesis
  type: local
  address: biya10cfy5e6qt2zy55q2w2ux2vuq862zcyf4fmfpj3
  pubkey: '{"@type":"/biyachain.crypto.v1beta1.ethsecp256k1.PubKey","key":"ArtVkg9feLXjD4p6XRtWxVpvJUDhrcqk/5XYLsQI4slb"}'
  mnemonic: ""
```

使用 `code_id` `1` 以及 JSON 编码的初始化参数(使用您选择的地址)和标签(列表中此合约的人类可读名称)运行 CLI 命令以实例化合约:

```bash
CODE_ID=1
INIT='{"name":"Albcoin","symbol":"ALB","decimals":6,"initial_balances":[{"address":"biya10cfy5e6qt2zy55q2w2ux2vuq862zcyf4fmfpj3","amount":"69420"}],"mint":{"minter":"biya10cfy5e6qt2zy55q2w2ux2vuq862zcyf4fmfpj3"},"marketing":{}}'
yes 12345678 | biyachaind tx wasm instantiate $CODE_ID $INIT --label="Albcoin Token" --from=genesis --chain-id="biyachain-1" --yes --gas-prices=500000000biya --gas=20000000 --no-admin
```

现在可以在 `http://localhost:10337/swagger/#/Query/ContractsByCode` 上获取实例化合约的地址

并且可以在 `http://localhost:10337/swagger/#/Query/ContractInfo` 上或通过 CLI 查询获取合约信息元数据

```bash
CONTRACT=$(biyachaind query wasm list-contract-by-code $CODE_ID --output json | jq -r '.contracts[-1]')
biyachaind query wasm contract $CONTRACT
```

**Output:**

```bash
biyachaind query wasm contract $CONTRACT
address: biya14hj2tavq8fpesdwxxcu44rty3hh90vhujaxlnz
contract_info:
  admin: ""
  code_id: "1"
  created:
    block_height: "95"
    tx_index: "0"
  creator: biya10rdsxdgr8l8s0gvu8rynhu22nnxkfytg58cwm8
  extension: null
  ibc_port_id: ""
  label: Albcoin Token
```

### 查询合约

可以使用以下命令查询整个合约状态:

```bash
biyachaind query wasm contract-state all $CONTRACT
```

**Output:**

```bash
models:
- key: 000762616C616E6365696E6A31306366793565367174327A793535713277327578327675713836327A63796634666D66706A33
  value: IjY5NDIwIg==
- key: 636F6E74726163745F696E666F
  value: eyJjb250cmFjdCI6ImNyYXRlcy5pbzpjdzIwLWJhc2UiLCJ2ZXJzaW9uIjoiMS4wLjEifQ==
- key: 6D61726B6574696E675F696E666F
  value: eyJwcm9qZWN0IjpudWxsLCJkZXNjcmlwdGlvbiI6bnVsbCwibG9nbyI6bnVsbCwibWFya2V0aW5nIjpudWxsfQ==
- key: 746F6B656E5F696E666F
  value: eyJuYW1lIjoiQWxiY29pbiIsInN5bWJvbCI6IkFMQiIsImRlY2ltYWxzIjo2LCJ0b3RhbF9zdXBwbHkiOiI2OTQyMCIsIm1pbnQiOnsibWludGVyIjoiaW5qMTBjZnk1ZTZxdDJ6eTU1cTJ3MnV4MnZ1cTg2MnpjeWY0Zm1mcGozIiwiY2FwIjpudWxsfX0=
pagination:
  next_key: null
  total: "0"
```

也可以使用以下命令查询单个用户的代币余额:

```bash
BALANCE_QUERY='{"balance": {"address": "biya10cfy5e6qt2zy55q2w2ux2vuq862zcyf4fmfpj3"}}'
biyachaind query wasm contract-state smart $CONTRACT "$BALANCE_QUERY" --output json
```

**Output:**

```bash
{"data":{"balance":"69420"}}
```

### 转移代币

```bash
TRANSFER='{"transfer":{"recipient":"biya1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz","amount":"420"}}'
yes 12345678 | biyachaind tx wasm execute $CONTRACT "$TRANSFER" --from genesis --chain-id="biyachain-1" --yes --gas-prices=500000000biya --gas=20000000
```

然后使用以下命令确认余额转移成功:

```bash
# first address balance query
BALANCE_QUERY='{"balance": {"address": "biya10cfy5e6qt2zy55q2w2ux2vuq862zcyf4fmfpj3"}}'
biyachaind query wasm contract-state smart $CONTRACT "$BALANCE_QUERY" --output json
```

**Output:**

```bash
{"data":{"balance":"69000"}}
```

并确认接收者收到了资金:

```bash
# recipient's address balance query
BALANCE_QUERY='{"balance": {"address": "biya1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz"}}'
biyachaind query wasm contract-state smart $CONTRACT "$BALANCE_QUERY" --output json
```

**Output:**

```bash
{"data":{"balance":"420"}}
```

## 测试网开发

以下是 `local` 和 `testnet` 开发/部署之间的主要区别

* 您可以使用我们的 [Biya Chain 测试网水龙头](https://testnet.faucet.biyachain.network) 将测试网资金发送到您的地址,
* 您可以使用 [Biya Chain 测试网浏览器](https://testnet.prv.scan.biya.io/zh/transactions/smart-contracts/code/) 查询您的交易并获取更多详细信息,
* 当您使用 `biyachaind` 时,您必须使用 `node` 标志 `--node=https://testnet.sentry.tm.biyachain.network:443` 指定 `testnet` rpc
* 不要使用 `biyachain-1` 作为 `chainId`,您应该使用 `biyachain-888`,即 `chain-id` 标志现在应该是 `--chain-id="biyachain-888"`
* 您可以使用 [Biya Chain 测试网浏览器](https://testnet.prv.scan.biya.io/zh/transactions/smart-contracts/code/) 查找有关已上传智能合约的 `codeId` 的信息或查找您实例化的智能合约

您可以阅读更多关于 `biyachaind` 以及如何使用它对 `testnet` 进行查询/发送交易的信息 [using-biyachaind.md](../developers/biyachaind/use.md "mention")。
