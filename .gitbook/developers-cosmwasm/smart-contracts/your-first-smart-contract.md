# 您的第一个 CosmWasm 智能合约

在本节中，我们将解释如何为 CosmWasm 智能合约开发设置您的环境。

## 先决条件

在开始之前，请确保您已安装 [`rustup`](https://rustup.rs/) 以及最新版本的 `rustc` 和 `cargo`。目前，我们在 Rust v1.58.1+ 上进行测试。

您还需要安装 `wasm32-unknown-unknown` 目标以及 `cargo-generate` Rust crate。

您可以通过以下命令检查版本：

```bash
rustc --version
cargo --version
rustup target list --installed
# if wasm32 is not listed above, run this
rustup target add wasm32-unknown-unknown
# to install cargo-generate, run this
cargo install cargo-generate
```

## 目标

* 创建并与一个智能合约交互，该合约可以增加计数器并将其重置为给定值
* 了解 CosmWasm 智能合约的基础知识，学习如何在 Biya Chain 上部署它，并使用 Biya Chain 工具与其交互

## CosmWasm 合约基础

智能合约可以被视为[单例对象](https://en.wikipedia.org/wiki/Singleton_pattern)的实例，其内部状态持久化在区块链上。用户可以通过向智能合约发送 JSON 消息来触发状态更改，用户还可以通过发送格式化为 JSON 消息的请求来查询其状态。这些 JSON 消息与 Biya Chain 区块链消息（如 `MsgSend` 和 `MsgExecuteContract`）不同。

作为智能合约编写者，您的工作是定义组成智能合约接口的 3 个函数：

* `instantiate()`：构造函数，在合约实例化期间调用以提供初始状态
* `execute()`：当用户想要调用智能合约上的方法时被调用
* `query()`：当用户想要从智能合约中获取数据时被调用

在我们的[示例计数器合约](https://github.com/biya-coin/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs)中，我们将实现一个 `instantiate`、一个 `query` 和两个 `execute` 方法。

## 从模板开始

在您的工作目录中，通过运行以下命令快速启动您的智能合约，使用推荐的文件夹结构和构建选项：

```bash
cargo generate --git https://github.com/CosmWasm/cw-template.git --branch 1.0 --name my-first-contract
cd my-first-contract
```

这通过为智能合约提供基本的样板代码和结构来帮助您入门。在 [`src/contract.rs`](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs) 文件中，您会发现标准的 CosmWasm 入口点 [`instantiate()`](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs#L15)、[`execute()`](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs#L35) 和 [`query()`](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs#L72) 已正确公开并连接。

## 状态

{% hint style="info" %}
您可以在他们的[文档](https://book.cosmwasm.com/basics/state.html)中了解更多关于 CosmWasm 状态的信息。
{% endhint %}

`State` 处理存储和访问智能合约数据的数据库状态。

[起始模板](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/state.rs)具有以下基本状态，一个单例结构 `State` 包含：

* `count`，一个 32 位整数，`execute()` 消息将通过增加或重置它来与之交互。
* `owner`，`MsgInstantiateContract` 的发送者 `address`，它将确定是否允许某些执行消息。

```c
// src/state.rs
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use cosmwasm_std::Addr;
use cw_storage_plus::Item;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct State {
    pub count: i32,
    pub owner: Addr,
}

pub const STATE: Item<State> = Item::new("state");
```

Biya Chain 智能合约能够通过 Biya Chain 的原生 LevelDB（一个基于字节的键值存储）保持持久状态。因此，您希望持久化的任何数据都应该分配一个唯一的键，该键可用于索引和检索数据。

数据只能作为原始字节持久化，因此任何结构或数据类型的概念都必须表示为一对序列化和反序列化函数。例如，对象必须存储为字节，因此您必须提供将对象编码为字节以将其保存在区块链上的函数，以及将字节解码回合约逻辑可以理解的数据类型的函数。字节表示的选择取决于您，只要它提供干净的双向映射即可。

幸运的是，CosmWasm 提供了实用程序 crate，例如 [`cosmwasm-storage`](https://crates.io/crates/cosmwasm-storage)，它为数据容器（如"单例"和"桶"）提供了方便的高级抽象，自动为常用类型（如结构和 Rust 数字）提供序列化和反序列化。此外，[`cw-storage-plus`](https://cosmwasm.cosmos.network/smart-contracts/state/cw-plus/) crate 可用于更高效的存储机制。

注意 `State` 结构如何同时保存 `count` 和 `owner`。此外，`derive` 属性被应用于自动实现一些有用的 trait：

* `Serialize`：提供序列化
* `Deserialize`：提供反序列化
* `Clone`：使结构可复制
* `Debug`：使结构能够打印为字符串
* `PartialEq`：提供相等比较
* `JsonSchema`：自动生成 JSON 模式

`Addr` 指的是以 `biya` 为前缀的人类可读的 Biya Chain 地址，例如 `biya1clw20s2uxeyxtam6f7m84vgae92s9eh7vygagt`。

## InstantiateMsg

{% hint style="info" %}
您可以在他们的[文档](https://github.com/CosmWasm/docs/blob/archive/dev-academy/develop-smart-contract/01-intro.md#instantiatemsg)中了解更多关于 CosmWasm InstantiateMsg 的信息
{% endhint %}

当用户通过 `MsgInstantiateContract` 在区块链上实例化合约时，`InstantiateMsg` 会提供给合约。这为合约提供了其配置以及初始状态。

在 Biya Chain 区块链上，合约代码的上传和合约的实例化被视为单独的事件，这与以太坊不同。这是为了允许一小组经过审查的合约原型作为共享相同基础代码的多个实例存在，但使用不同的参数进行配置（想象一个规范的 ERC20，以及使用其代码的多个代币）。

### 示例

对于您的合约，合约创建者应该在 JSON 消息中提供初始状态。我们可以在下面的消息定义中看到，该消息包含一个参数 `count`，它表示初始计数。

```json
{
  "count": 100
}
```

### Message Definition

```c
// src/msg.rs

use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub count: i32,
}

```

### 合约逻辑

在 `contract.rs` 中，您将定义您的第一个入口点 `instantiate()`，或合约被实例化并传递其 `InstantiateMsg` 的地方。从消息中提取计数并设置您的初始状态，其中：

* `count` 被分配来自消息的计数
* `owner` 被分配给 `MsgInstantiateContract` 的发送者

```c
// src/contract.rs
#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    let state = State {
        count: msg.count,
        owner: info.sender.clone(),
    };
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;
    STATE.save(deps.storage, &state)?;

    Ok(Response::new()
        .add_attribute("method", "instantiate")
        .add_attribute("owner", info.sender)
        .add_attribute("count", msg.count.to_string()))
}
```

## ExecuteMsg

{% hint style="info" %}
您可以在他们的[文档](https://book.cosmwasm.com/basics/execute.html)中了解更多关于 CosmWasm ExecuteMsg 的信息。
{% endhint %}

`ExecuteMsg` 是通过 `MsgExecuteContract` 传递给 `execute()` 函数的 JSON 消息。与 `InstantiateMsg` 不同，`ExecuteMsg` 可以作为几种不同类型的消息存在，以考虑智能合约可以向用户公开的不同类型的函数。[`execute()` 函数](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs#L35)将这些不同类型的消息解复用到其适当的消息处理程序逻辑。

我们有[两个 ExecuteMsg](https://github.com/biya-coin/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs#L9)：`Increment` 和 `Reset`。

* `Increment` 没有输入参数，将 count 的值增加 1。
* `Reset` 接受一个 32 位整数作为参数，并将 `count` 的值重置为输入参数。

### 示例

**Increment**

任何用户都可以将当前计数增加 1。

```json
{
  "increment": {}
}
```

#### Reset

只有所有者可以将计数重置为特定数字。有关实现详细信息，请参见下面的逻辑。

```json
{
  "reset": {
    "count": 5
  }
}
```

### 消息定义

对于 `ExecuteMsg`，可以使用 `enum` 来复用您的合约可以理解的不同类型的消息。`serde` 属性以蛇形命名法和小写重写您的属性键，因此在跨 JSON 序列化和反序列化时，您将拥有 `increment` 和 `reset` 而不是 `Increment` 和 `Reset`。

```c
// src/msg.rs

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    Increment {},
    Reset { count: i32 },
}
```

### Logic

```c
// src/contract.rs

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::Increment {} => try_increment(deps),
        ExecuteMsg::Reset { count } => try_reset(deps, info, count),
    }
}
```

这是您的 `execute()` 方法，它使用 Rust 的模式匹配将接收到的 `ExecuteMsg` 路由到适当的处理逻辑，根据接收到的消息分派 `try_increment()` 或 `try_reset()` 调用。

```c
pub fn try_increment(deps: DepsMut) -> Result<Response, ContractError> {
    STATE.update(deps.storage, |mut state| -> Result<_, ContractError> {
        state.count += 1;
        Ok(state)
    })?;

    Ok(Response::new().add_attribute("method", "try_increment"))
}
```

首先，它获取对存储的可变引用以更新位于键 `state` 的项。然后，它通过返回带有新状态的 `Ok` 结果来更新状态的计数。最后，它通过返回带有 `Response` 的 `Ok` 结果来终止合约的执行，并确认成功。

```c
// src/contract.rs

pub fn try_reset(deps: DepsMut, info: MessageInfo, count: i32) -> Result<Response, ContractError> {
    STATE.update(deps.storage, |mut state| -> Result<_, ContractError> {
        if info.sender != state.owner {
            return Err(ContractError::Unauthorized {});
        }
        state.count = count;
        Ok(state)
    })?;
    Ok(Response::new().add_attribute("method", "reset"))
}
```

重置的逻辑与增加非常相似——除了这次，它首先检查消息发送者是否被允许调用重置函数（在这种情况下，它必须是合约所有者）。

## QueryMsg

{% hint style="info" %}
您可以在他们的[文档](https://docs.cosmwasm.com/docs/smart-contracts/query)中了解更多关于 CosmWasm QueryMsg 的信息
{% endhint %}

`GetCount` [查询消息](https://github.com/biya-coin/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs#L16)没有参数并返回 `count` 值。

有关实现详细信息，请参见下面的逻辑。

### 示例

模板合约仅支持一种类型的 `QueryMsg`：

**GetCount**

请求：

```json
{
  "get_count": {}
}
```

应该返回：

```json
{
  "count": 5
}
```

### 消息定义

要在合约中支持数据查询，您必须定义 `QueryMsg` 格式（表示请求），以及提供查询输出的结构——在本例中为 `CountResponse`。您必须这样做，因为 `query()` 将通过结构化 JSON 将信息发送回用户，因此您必须使响应的形状已知。有关更多信息，请参见生成 JSON 模式。

将以下内容添加到您的 `src/msg.rs`：

```c
// src/msg.rs
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    // GetCount returns the current count as a json-encoded number
    GetCount {},
}

// Define a custom struct for each query response
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct CountResponse {
    pub count: i32,
}
```

### 逻辑

`query()` 的逻辑与 `execute()` 的逻辑类似；但是，由于 `query()` 是在最终用户不进行交易的情况下调用的，因此省略了 `env` 参数，因为不需要任何信息。

```c
// src/contract.rs

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetCount {} => to_binary(&query_count(deps)?),
    }
}

fn query_count(deps: Deps) -> StdResult<CountResponse> {
    let state = STATE.load(deps.storage)?;
    Ok(CountResponse { count: state.count })
}
```

## 单元测试

在将代码部署到链上之前，应该将单元测试作为第一道保证。它们执行速度快，并且可以使用 `RUST_BACKTRACE=1` 标志在失败时提供有用的回溯：

```c
cargo unit-test // run this with RUST_BACKTRACE=1 for helpful backtraces
```

您可以在 `src/contract.rs` 找到[单元测试实现](https://github.com/biya-coin/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/contract.rs#L88)

## 构建合约

现在我们已经理解并测试了合约，我们可以运行以下命令来构建合约。这将在我们在下一步优化合约之前检查任何初步错误。

```bash
cargo wasm
```

接下来，我们必须优化合约，以便准备将代码上传到链上。

{% hint style="info" %}
阅读有关[为生产准备 Wasm 字节码](https://github.com/biya-coin/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/Developing.md#preparing-the-wasm-bytecode-for-production)的更多详细信息
{% endhint %}

CosmWasm 有 [rust-optimizer](https://github.com/CosmWasm/rust-optimizer)，这是一个优化编译器，可以产生小而一致的构建输出。使用该工具的最简单方法是使用已发布的 Docker 镜像——在[这里](https://hub.docker.com/r/cosmwasm/rust-optimizer/tags)查看最新的 x86 版本，或在[这里](https://hub.docker.com/r/cosmwasm/rust-optimizer-arm64/tags)查看最新的 ARM 版本。在 Docker 运行的情况下，运行以下命令将合约代码挂载到 `/code` 并优化输出（如果您不想先 `cd` 到目录，可以使用绝对路径而不是 `$(pwd)`）：

```bash
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer:0.12.12
```

如果您使用的是 ARM64 机器，则应使用为 ARM64 构建的 docker 镜像：

```bash
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer-arm64:0.12.12
```

{% hint style="info" %}
CosmWasm 不建议使用 ARM64 版本的编译器，因为它产生的 Wasm 工件与 Intel/AMD 版本不同。对于发布/生产，仅建议使用使用 Intel/AMD 优化器构建的合约。有关 CosmWasm 的说明，请参见[此处](https://github.com/CosmWasm/rust-optimizer#notice)。
{% endhint %}

{% hint style="warning" %}
在运行命令时，您可能会收到 `` Unable to update registry `crates-io` `` 错误。尝试将以下行添加到位于合约目录中的 `Cargo.toml` 文件中，然后再次运行命令：

```toml
[net]
git-fetch-with-cli = true
```

有关更多信息，请参见 [The Cargo Book](https://doc.rust-lang.org/cargo/reference/config.html#netgit-fetch-with-cli)。
{% endhint %}

这会生成一个 `artifacts` 目录，其中包含 `PROJECT_NAME.wasm` 以及 `checksums.txt`，其中包含 Wasm 文件的 Sha256 哈希。Wasm 文件是确定性编译的（在同一 git 提交上运行相同 docker 的任何其他人应该获得具有相同 Sha256 哈希的相同文件）。

## 安装 `biyachaind`

`biyachaind` 是连接到 Biya Chain 并使您能够与 Biya Chain 区块链交互的命令行界面和守护进程。

如果您想使用 CLI 在本地与您的智能合约交互，您必须安装 `biyachaind`。为此，您可以按照此处的安装指南 [#install-biyachaind](#install-biyachaind "mention")。

或者，已准备好 Docker 镜像以使本教程更容易。

{% hint style="info" %}
如果您从二进制文件安装 `biyachaind`，请忽略 docker 命令。
在[公共端点部分](../../infra/public-endpoints.md)中，您可以找到正确的 --node 信息以与主网和测试网交互。
{% endhint %}

执行此命令将使 docker 容器无限期执行。

```bash
docker run --name="biyachain-core-staging" \
-v=<directory_to_which_you_cloned_cw-template>/artifacts:/var/artifacts \
--entrypoint=sh public.ecr.aws/l9h3g6c6/biyachain-core:staging \
-c "tail -F anything"
```

注意：`directory_to_which_you_cloned_cw-template` 必须是绝对路径。通过从 CosmWasm/cw-counter 目录内运行 `pwd` 命令可以轻松找到绝对路径。

打开一个新终端并进入 Docker 容器以初始化链：

```bash
docker exec -it biyachain-core-staging sh
```

让我们从添加 `jq` 依赖项开始，稍后会需要它：

```bash
# inside the "biyachain-core-staging" container
apk add jq
```

现在我们可以继续进行本地链初始化并添加一个名为 `testuser` 的测试用户（提示时使用 12345678 作为密码）。我们将仅使用测试用户生成一个新的私钥，该私钥稍后将用于在测试网上签署消息：

```sh
# inside the "biyachain-core-staging" container
biyachaind keys add testuser
```

**输出**

```
- name: testuser
  type: local
  address: biya1exjcp8pkvzqzsnwkzte87fmzhfftr99kd36jat
  pubkey: '{"@type":"/biyachain.crypto.v1beta1.ethsecp256k1.PubKey","key":"Aqi010PsKkFe9KwA45ajvrr53vfPy+5vgc3aHWWGdW6X"}'
  mnemonic: ""

**重要** 将此助记词短语写在安全的地方。
如果您忘记密码，这是恢复您帐户的唯一方法。

wash wise evil buffalo fiction quantum planet dial grape slam title salt dry and some more words that should be here
```

花点时间写下地址或将其导出为环境变量，因为您需要它才能继续：

```bash
# inside the "biyachain-core-staging" container
export BIYA_ADDRESS= <your biya address>
```

{% hint style="info" %}
您可以使用 [Biya Chain 测试水龙头](https://faucet.biyachain.network/)为您最近生成的测试地址请求测试网资金。
{% endhint %}

现在您已成功在 Biya Chain 测试网上创建了 `testuser`。从水龙头请求 `testnet` 资金后，它也应该持有一些资金。

要确认，请在 [Biya Chain 测试网浏览器](https://testnet.prv.scan.biya.io/zh/transactions/)上搜索您的地址以检查您的余额。

或者，您可以通过[查询银行余额](https://sentry.testnet.lcd.biyachain.network/swagger/#/Query/AllBalances)或使用 curl 进行验证：

```bash
curl -X GET "https://sentry.testnet.lcd.biyachain.network/cosmos/bank/v1beta1/balances/<your_BIYA_address>" -H "accept: application/json"
```

## 上传 Wasm 合约

现在是时候将您在前面步骤中编译的 `.wasm` 文件上传到 Biya Chain 测试网了。请注意，主网的流程不同，[需要治理提案。](../mainnet-deployment-guide.md)

```bash
# inside the "biyachain-core-staging" container, or from the contract directory if running biyachaind locally
yes 12345678 | biyachaind tx wasm store artifacts/my_first_contract.wasm \
--from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443
```

**输出：**

```bash
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
txhash: 912458AA8E0D50A479C8CF0DD26196C49A65FCFBEEB67DF8A2EA22317B130E2C
```

在 [Biya Chain 测试网浏览器](https://testnet.prv.scan.biya.io/zh/transactions)上检查您的地址，并查找从链上存储代码返回的 `txhash` 的交易。交易类型应为 `MsgStoreCode`。

您可以在 [Code](https://testnet.prv.scan.biya.io/zh/transactions/smart-contracts/code/) 下查看 Biya Chain 测试网上所有存储的代码。

{% hint style="info" %}
有不同的方法可以找到您刚刚存储的代码：

* 在 Biya Chain 浏览器的[代码列表](https://testnet.prv.scan.biya.io/zh/transactions/smart-contracts/code/)中查找 TxHash；它很可能是最近的。
* 使用 `biyachaind` 查询交易信息。
{% endhint %}

要查询交易，请使用 `txhash` 并验证合约已部署。

```sh
biyachaind query tx 912458AA8E0D50A479C8CF0DD26196C49A65FCFBEEB67DF8A2EA22317B130E2C --node=https://testnet.sentry.tm.biyachain.network:443
```

更仔细地检查输出，我们可以看到上传合约的 `code_id` 为 `290`：

```bash
- events:
  - attributes:
    - key: access_config
      value: '{"permission":"Everybody","address":""}'
    - key: checksum
      value: '"+OdoniOsDJ1T9EqP2YxobCCwFAqNdtYA4sVGv7undY0="'
    - key: code_id
      value: '"290"'
    - key: creator
      value: '"biya1h3gepa4tszh66ee67he53jzmprsqc2l9npq3ty"'
    type: cosmwasm.wasm.v1.EventCodeStored
  - attributes:
    - key: action
      value: /cosmwasm.wasm.v1.MsgStoreCode
    - key: module
      value: wasm
    - key: sender
      value: biya1h3gepa4tszh66ee67he53jzmprsqc2l9npq3ty
    type: message
  - attributes:
    - key: code_id
      value: "290"
    type: store_code
```

让我们将您的 `code_id` 导出为环境变量——我们需要它来实例化合约。您可以跳过此步骤并稍后手动添加，但请记下 ID。

```bash
export CODE_ID= <code_id of your stored contract>
```

## 生成 JSON 模式

虽然 Wasm 调用 `instantiate`、`execute` 和 `query` 接受 JSON，但这还不足以使用它们。我们需要向客户端公开预期消息的模式。

为了使用 JSON 模式自动生成，您应该注册每个需要模式的数据结构。

```c
// examples/schema.rs

use std::env::current_dir;
use std::fs::create_dir_all;

use cosmwasm_schema::{export_schema, remove_schemas, schema_for};

use my_first_contract::msg::{CountResponse, HandleMsg, InitMsg, QueryMsg};
use my_first_contract::state::State;

fn main() {
    let mut out_dir = current_dir().unwrap();
    out_dir.push("schema");
    create_dir_all(&out_dir).unwrap();
    remove_schemas(&out_dir).unwrap();

    export_schema(&schema_for!(InstantiateMsg), &out_dir);
    export_schema(&schema_for!(ExecuteMsg), &out_dir);
    export_schema(&schema_for!(QueryMsg), &out_dir);
    export_schema(&schema_for!(State), &out_dir);
    export_schema(&schema_for!(CountResponse), &out_dir);
}
```

然后可以使用以下命令生成模式

```bash
cargo schema
```

这将在 `./schema` 中输出 5 个文件，对应于合约接受的 3 种消息类型、查询响应消息和内部 `State`。

这些文件采用标准 JSON 模式格式，应该可以被各种客户端工具使用，要么自动生成编解码器，要么只是根据定义的模式验证传入的 JSON。

花一分钟生成模式（[在此处查看](https://github.com/biya-coin/cw-counter/blob/master/schema/cw-counter.json)）并熟悉它，因为您在接下来的步骤中需要它。

## 实例化合约

现在我们已经在 Biya Chain 上有了代码，是时候实例化合约以与之交互了。

{% hint style="info" %}
提醒：在 CosmWasm 上，合约代码的上传和合约的实例化被视为单独的事件
{% endhint %}

要实例化合约，请使用您在上一步中获得的 code_id 运行以下 CLI 命令，以及 [JSON 编码的初始化参数](https://github.com/biya-coin/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/schema/cw-counter.json#L7)和标签（列表中此合约的人类可读名称）。

```bash
INIT='{"count":99}'
yes 12345678 | biyachaind tx wasm instantiate $CODE_ID $INIT \
--label="CounterTestInstance" \
--from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya \
--gas=2000000 \
--no-admin \
--node=https://testnet.sentry.tm.biyachain.network:443
```

**输出：**

```bash
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
txhash: 01804F525FE336A5502E3C84C7AE00269C7E0B3DC9AA1AB0DDE3BA62CF93BE1D
```

{% hint style="info" %}
您可以通过以下方式找到合约地址和元数据：

* 在[测试网浏览器](https://www.biyascan.com/smart-contracts/)上查看
* 查询 [ContractsByCode](https://k8s.testnet.lcd.biyachain.network/swagger/#/Query/ContractsByCode) 和 [ContractInfo](https://k8s.testnet.lcd.biyachain.network/swagger/#/Query/ContractInfo) API
* 通过 CLI 查询

```bash
biyachaind query wasm contract biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 --node=https://testnet.sentry.tm.biyachain.network:443
```
{% endhint %}

## 查询合约

正如我们之前所知，我们唯一的 QueryMsg 是 `get_count`。

```bash
GET_COUNT_QUERY='{"get_count":{}}'
biyachaind query wasm contract-state smart biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$GET_COUNT_QUERY" \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

**输出：**

```bash
{"data":{"count":99}}
```

我们看到 `count` 为 99，正如我们实例化合约时设置的那样。

{% hint style="info" %}
如果您查询同一合约，您可能会收到不同的响应，因为其他人可能已经与合约交互并增加或重置了计数。
{% endhint %}

## 执行合约

现在让我们通过增加计数器来与合约交互。

```bash
INCREMENT='{"increment":{}}'
yes 12345678 | biyachaind tx wasm execute biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$INCREMENT" --from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

如果我们查询合约的计数，我们会看到：

```bash
{"data":{"count":100}}
```

{% hint style="info" %}
**yes 12345678 |** 自动将密码传递（管道）到 **biyachaind tx wasm execute** 的输入，因此您无需手动输入。
{% endhint %}

要重置计数器：

```bash
RESET='{"reset":{"count":999}}'
yes 12345678 | biyachaind tx wasm execute biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$RESET" \
--from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

现在，如果我们再次查询合约，我们会看到计数已重置为提供的值：

```bash
{"data":{"count":999}}
```

## Cosmos 消息

除了定义自定义智能合约逻辑外，CosmWasm 还允许合约与底层 Cosmos SDK 功能交互。一个常见的用例是使用 Cosmos SDK 的 bank 模块从合约向指定地址发送代币。

### 示例：Bank Send

`BankMsg::Send` 消息允许合约将代币转移到另一个地址。这在各种场景中都很有用，例如分发奖励或向用户返还资金。

{% hint style="info" %}
**注意：** 如果您想同时发送资金并在另一个合约上执行函数，请不要使用 BankMsg::Send。相反，使用 WasmMsg::Execute 并设置相应的 funds 字段。
{% endhint %}

### 构造消息

您可以在合约的 `execute` 函数中构造 `BankMsg::Send` 消息。此消息需要指定接收者地址和要发送的金额。以下是如何构造此消息的示例：

```rust
use cosmwasm_std::{BankMsg, Coin, Response, MessageInfo};

pub fn try_send(
    info: MessageInfo,
    recipient_address: String,
    amount: Vec<Coin>,
) -> Result<Response, ContractError> {
    let send_message = BankMsg::Send {
        to_address: recipient_address,
        amount,
    };

    let response = Response::new().add_message(send_message);
    Ok(response)
}
```

### 在智能合约中使用

在您的合约中，您可以向 ExecuteMsg 枚举添加一个新变体来处理此 bank send 功能。例如：

```rust
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    // ... other messages ...
    SendTokens { recipient: String, amount: Vec<Coin> },
}
```

然后，在 `execute` 函数中，您可以添加一个 case 来处理此消息：

```rust
#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        // ... other message handling ...
        ExecuteMsg::SendTokens { recipient, amount } => try_send(info, recipient, amount),
    }
}
```

## 测试

与其他智能合约函数一样，您应该添加单元测试以确保您的 bank send 功能按预期工作。这包括测试不同的场景，例如发送各种代币金额和正确处理错误。

您可以使用 [test-tube](https://github.com/biya-coin/test-tube) 运行包含本地 Biya Chain 链的集成测试。

恭喜！您已经创建并与您的第一个 Biya Chain 智能合约交互，现在知道如何开始在 Biya Chain 上进行 CosmWasm 开发。继续阅读"为您的合约创建前端"以获取有关创建 Web UI 的指南。
