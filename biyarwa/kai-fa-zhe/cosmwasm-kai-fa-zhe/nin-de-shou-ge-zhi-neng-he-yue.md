# 您的首个智能合约

在本节中，我们将说明如何设置环境以进行 CosmWasm 智能合约开发。

### 前置条件

在开始之前，请确保已安装 [`rustup`](https://rustup.rs/)，以及最新版本的 `rustc` 和 `cargo`。当前，我们在 Rust v1.58.1+ 版本上进行测试。

此外，还需要安装 `wasm32-unknown-unknown` 目标以及 `cargo-generate` Rust 依赖包。

可以使用以下命令检查版本：

```bash
rustc --version
cargo --version
rustup target list --installed
# if wasm32 is not listed above, run this
rustup target add wasm32-unknown-unknown
# to install cargo-generate, run this
cargo install cargo-generate
```

### 目标

* 创建并交互一个智能合约，该合约可以增加计数器的值，并将其重置为指定值。
* 理解 CosmWasm 智能合约的基础知识，学习如何在 Biyachain 上部署合约，并使用 Biyachain 工具与其交互。

### CosmWasm 合约基础知识

智能合约可以被视为[单例对象](https://en.wikipedia.org/wiki/Singleton_pattern)的一个实例，其内部状态持久化存储在区块链上。用户可以通过发送 JSON 消息来触发状态变更，也可以通过格式化为 JSON 消息的请求来查询合约状态。这些 JSON 消息不同于 Biyachain 区块链消息，例如 `MsgSend` 和 `MsgExecuteContract`。

作为智能合约的开发者，你的任务是定义三个组成合约接口的函数：

* `instantiate()`：构造函数，在合约实例化时调用，用于提供初始状态。
* `execute()`：当用户希望调用智能合约上的方法时执行。
* `query()`：当用户希望从智能合约中获取数据时执行。

在我们的[示例计数器合约](https://github.com/InjectiveLabs/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs)中，将实现一个 `instantiate` 方法、一个 `query` 方法和两个 `execute` 方法。

### 从模版开始

在你的工作目录中，通过运行以下命令，快速启动智能合约，并使用推荐的文件夹结构和构建选项：

```bash
cargo generate --git https://github.com/CosmWasm/cw-template.git --branch 1.0 --name my-first-contract
cd my-first-contract
```

这有助于你快速开始，通过提供智能合约的基本模板和结构。在 `src/contract.rs` 文件中，你会发现标准的 CosmWasm 入口函数 `instantiate()`、`execute()` 和 `query()` 已正确暴露并连接。

### State

{% hint style="info" %}
你可以在 CosmWasm 的[文档](https://book.cosmwasm.com/basics/state.html)中了解更多关于 CosmWasm 状态的信息。
{% endhint %}

State 处理存储和访问智能合约数据的数据库状态。

起始模板具有以下基本状态，一个单例结构体 `State`，包含：

* `count`，一个 32 位整数，`execute()` 消息将通过增加或重置该值进行交互。
* `owner`，`MsgInstantiateContract` 的发送者地址，决定是否允许某些执行消息。

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

Biyachain 智能合约能够通过 Biyachain 的原生 LevelDB（一个基于字节的键值存储）保持持久化状态。因此，任何你希望持久化的数据都应该分配一个唯一的键，用于索引和检索数据。

数据只能以原始字节形式持久化，因此任何结构或数据类型的概念必须通过一对序列化和反序列化函数来表达。例如，对象必须以字节形式存储，因此你需要提供一个将对象编码为字节以便保存到区块链上的函数，以及一个将字节解码回合约逻辑能够理解的数据类型的函数。字节表示的选择由你决定，只要它提供一个干净的双向映射。

幸运的是，CosmWasm 提供了实用的库，例如 [`cosmwasm_storage`](https://crates.io/crates/cosmwasm-storage)，它为数据容器（如 "singleton" 和 "bucket"）提供了方便的高层抽象，自动提供常用类型（如结构体和 Rust 数字）的序列化和反序列化功能。此外，[`cw-storage-plus`](https://docs.cosmwasm.com/docs/smart-contracts/state/cw-plus/) 库可以用于更高效的存储机制。

请注意，`State` 结构体包含了 `count` 和 `owner`。此外，`derive` 属性被应用于自动实现一些有用的特性：

* `Serialize`：提供序列化
* `Deserialize`：提供反序列化
* `Clone`：使结构体可复制
* `Debug`：使结构体可以打印为字符串
* `PartialEq`：提供相等性比较
* `JsonSchema`：自动生成 JSON 架构

`Addr` 指的是一个可读的 Biyachain 地址，以 `biya` 为前缀，例如 `biya1clw20s2uxeyxtam6f7m84vgae92s9eh7vygagt`。

### InstantiateMsg

{% hint style="info" %}
你可以在 CosmWasm 的文档中了解更多关于 `InstantiateMsg` 的信息。
{% endhint %}

`InstantiateMsg` 是在用户通过 `MsgInstantiateContract` 在区块链上实例化合约时提供给合约的。它为合约提供了配置以及初始状态。

在 Biyachain 区块链上，合约代码的上传和合约的实例化被视为两个独立的事件，这与以太坊不同。这样做是为了允许一小部分经过审查的合约原型作为多个实例存在，这些实例共享相同的基础代码，但可以用不同的参数进行配置（想象一个标准的 ERC20 合约和多个使用其代码的代币）。

**示例**

对于你的合约，合约创建者需要在 JSON 消息中提供初始状态。我们可以在下面的消息定义中看到，消息包含一个参数 `count`，表示初始计数值。

```json
{
  "count": 100
}
```

**Message 定义**

```c
// src/msg.rs

use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub count: i32,
}

```

**合约逻辑**

在 `contract.rs` 文件中，你将定义第一个入口函数 `instantiate()`，该函数用于实例化合约并接收 `InstantiateMsg`。

从消息中提取 `count` 并设置初始状态，其中：

* `count` 赋值为消息中的 `count`。
* `owner` 赋值为 `MsgInstantiateContract` 的发送者。

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

### ExecuteMsg

{% hint style="info" %}
你可以在 CosmWasm 的[文档](https://book.cosmwasm.com/basics/execute.html)中了解更多关于 `ExecuteMsg` 的信息。
{% endhint %}

`ExecuteMsg` 是一个 JSON 消息，通过 `MsgExecuteContract` 传递给 `execute()` 函数。与 `InstantiateMsg` 不同，`ExecuteMsg` 可以有多个不同类型的消息，以对应智能合约向用户暴露的不同功能。[`execute()`](https://github.com/InjectiveLabs/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/src/contract.rs#L35)函数会对这些不同类型的消息进行分发，并调用相应的消息处理逻辑。

我们有两个 [ExecuteMsg](https://github.com/InjectiveLabs/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs#L9)：`Increment` 和 `Reset`。

* `Increment` 没有输入参数，将 `count` 值增加 1。
* `Reset` 接受一个 32 位整数作为参数，并将 `count` 值重置为该输入参数。

**示例**

**Increment**

任何用户都可以将当前 `count` 值增加 1。

```json
{
  "increment": {}
}
```

**Reset**

只有 `owner` 可以将 `count` 重置为指定的数值。实现详情请参考以下逻辑。

```json
{
  "reset": {
    "count": 5
  }
}
```

**Message 定义**

对于 `ExecuteMsg`，可以使用 `enum` 来对合约能够识别的不同类型的消息进行多路复用。

`serde` 属性会将枚举的键转换为蛇形（snake case）和小写（lower case），因此在 JSON 序列化和反序列化时，`Increment` 和 `Reset` 会被转换为 `increment` 和 `reset`。

```c
// src/msg.rs

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    Increment {},
    Reset { count: i32 },
}
```

**逻辑**

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

这是你的 `execute()` 方法，它使用 Rust 的模式匹配（pattern matching）来将接收到的 `ExecuteMsg` 路由到相应的处理逻辑。

根据接收到的消息，它会调用 `try_increment()` 或 `try_reset()` 方法进行处理。

```c
pub fn try_increment(deps: DepsMut) -> Result<Response, ContractError> {
    STATE.update(deps.storage, |mut state| -> Result<_, ContractError> {
        state.count += 1;
        Ok(state)
    })?;

    Ok(Response::new().add_attribute("method", "try_increment"))
}
```

首先，它获取对存储的可变引用，以更新存储在键 `state` 位置的项。然后，它通过返回 `Ok` 结果并包含新的 `state` 来更新状态中的 `count`。最后，它返回 `Ok` 结果并附带 `Response`，以确认合约执行成功。

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

`reset` 的逻辑与 `increment` 类似，但不同之处在于：它首先检查消息发送者是否被允许调用 `reset` 方法（在本例中，必须是合约 `owner`）。

### QueryMsg

{% hint style="info" %}
你可以在 CosmWasm 的文档中了解更多关于 [QueryMsg](https://docs.cosmwasm.com/docs/smart-contracts/query) 的信息。
{% endhint %}

`GetCount` [查询消息](https://github.com/InjectiveLabs/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/msg.rs#L16)没有参数，返回 `count` 的值。

实现详情请参考以下逻辑。

**示例**

该模板合约仅支持一种类型的 `QueryMsg`：

**GetCount**

请求:

```json
{
  "get_count": {}
}
```

返回:

```json
{
  "count": 5
}
```

**Message 定义**

为了在合约中支持数据查询，你需要定义查询消息格式（代表请求），并提供查询输出的结构——在这种情况下是 `CountResponse`。你必须这样做，因为 `query()` 会通过结构化的 JSON 将信息发送回用户，因此你需要定义响应的结构。有关更多信息，请参见 "生成 JSON 架构"。

将以下内容添加到你的 `src/msg.rs` 文件中：

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

**逻辑**

`query()` 的逻辑与 `execute()` 类似；然而，由于 `query()` 在没有最终用户发起交易的情况下被调用，因此省略了 `env` 参数，因为不需要该信息。

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

### 单元测试

单元测试应该作为部署合约到链上的第一步保障。它们执行迅速，并且在失败时可以通过 `RUST_BACKTRACE=1` 标志提供有用的回溯信息：

```c
cargo unit-test // run this with RUST_BACKTRACE=1 for helpful backtraces
```

你可以在 `src/contract.rs` 文件中找到[单元测试](https://github.com/InjectiveLabs/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/src/contract.rs#L88)的实现。

### 构建合约

现在我们已经理解并测试了合约，可以运行以下命令来构建合约。这个命令将在我们进入下一步优化合约之前检查任何初步的错误。

```bash
cargo wasm
```

接下来，我们需要优化合约，以便为将代码上传到区块链做准备。

{% hint style="info" %}
你可以阅读更多关于为[生产环境准备 Wasm 字节码](https://github.com/InjectiveLabs/cw-counter/blob/59b9fed82864103eb704a58d20ddb4bf94c69787/Developing.md#preparing-the-wasm-bytecode-for-production)的详细信息。
{% endhint %}

CosmWasm 提供了 [rust-optimizer](https://github.com/CosmWasm/rust-optimizer)，一个优化编译器，可以生成小巧且一致的构建输出。使用该工具最简单的方法是使用已发布的 Docker 镜像——可以在[这里](https://hub.docker.com/r/cosmwasm/rust-optimizer/tags)查看最新的 x86 版本，或者在[这里](https://hub.docker.com/r/cosmwasm/rust-optimizer-arm64/tags)查看最新的 ARM 版本。

在 Docker 正在运行的情况下，运行以下命令将合约代码挂载到 `/code` 并优化输出（如果不想先进入目录，可以使用绝对路径替代 `$(pwd)`）：

```bash
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer:0.12.12
```

如果你使用的是 ARM64 机器，应该使用为 ARM64 构建的 Docker 镜像：

```bash
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer-arm64:0.12.12
```

{% hint style="info" %}
CosmWasm 不建议使用 ARM64 版本的编译器，因为它生成的 Wasm 构件与 Intel/AMD 版本不同。对于发布/生产环境，仅推荐使用 Intel/AMD 优化器构建的合约。有关详细信息，请参见 CosmWasm 的[说明](https://github.com/CosmWasm/rust-optimizer#notice)。
{% endhint %}

{% hint style="warning" %}
在运行命令时，你可能会收到 `Unable to update registry 'crates-io'` 错误。

尝试将以下行添加到合约目录中的 `Cargo.toml` 文件中，然后再次运行该命令：

```toml
[net]
git-fetch-with-cli = true
```

有关更多信息，请参见[The Cargo Book](https://doc.rust-lang.org/cargo/reference/config.html#netgit-fetch-with-cli) 。
{% endhint %}

这会生成一个 `artifacts` 目录，其中包含 `PROJECT_NAME.wasm` 文件，以及 `checksums.txt` 文件，后者包含 Wasm 文件的 Sha256 哈希值。Wasm 文件是确定性编译的（在相同的 git 提交上运行相同 Docker 的任何人都应该获得相同的文件，并且具有相同的 Sha256 哈希值）。

### 安装 `biyachaind`

`biyachaind` 是命令行界面和daemon进程，连接到 Biyachain 并使你能够与 Biyachain 区块链进行交互。

如果你想通过 CLI 在本地与智能合约进行交互，你需要安装 `biyachaind`。你可以按照[ 这里的安装指南 ](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/cosmwasm-developers/your-first-smart-contract/~/overview#install-injectived)来进行安装。

另外，为了简化这个教程，已经准备好了一个 Docker 镜像。

{% hint style="info" %}
如果你是从二进制文件安装 `biyachaind`，则无需使用 Docker 命令。在 [public endpoints section](https://docs.injective.network/injective-zhong-wen-wen-dang/jie-dian/public-endpoints) 部分，你可以找到与 Mainnet 和 Testnet 交互的正确 `--node` 信息。
{% endhint %}

执行此命令将使 Docker 容器无限期地执行。

```bash
docker run --name=biyachain-core-staging" \
-v=<directory_to_which_you_cloned_cw-template>/artifacts:/var/artifacts \
--entrypoint=sh public.ecr.aws/l9h3g6c6/biyachain-core:staging \
-c "tail -F anything"
```

Note: `directory_to_which_you_cloned_cw-template` 必须是一个绝对路径。你可以通过在 `CosmWasm/cw-counter` 目录中运行 `pwd` 命令轻松找到绝对路径。

打开一个新终端并进入 Docker 容器以初始化链：

```bash
docker exec -it biyachain-core-staging sh
```

让我们首先添加 `jq` 依赖，它将在后续步骤中使用：

```bash
# inside the "biyachain-core-staging" container
apk add jq
```

现在我们可以继续进行本地区块链初始化，并添加一个名为 `testuser` 的测试用户（当提示时使用 `12345678` 作为密码）。我们将仅使用该测试用户来生成一个新的私钥，稍后将在测试网中用于签名消息：

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

**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

wash wise evil buffalo fiction quantum planet dial grape slam title salt dry and some more words that should be here
```

请花点时间记下地址，或者将其导出为环境变量，因为接下来你将需要用到它：

```bash
# inside the "biyachain-core-staging" container
export BIYA_ADDRESS= <your biya address>
```

{% hint style="info" %}
你可以使用 [Biyachain 测试水龙头](https://faucet.injective.network/)为你最近生成的测试地址请求测试网资金。
{% endhint %}

现在你已经成功在 Biyachain 测试网上创建了 `testuser`，并且在从测试水龙头请求测试网资金后，账户应该会有一些资金。

为了确认，你可以在 [Biyachain 测试网浏览器](https://testnet.explorer.injective.network/)中搜索你的地址以检查余额。

另外，你也可以通过[查询银行余额](https://sentry.testnet.lcd.injective.network/swagger/#/Query/AllBalances)或使用 `curl` 来验证：

```bash
curl -X GET "https://sentry.testnet.lcd.biyachain.network/cosmos/bank/v1beta1/balances/<your_BIYA_address>" -H "accept: application/json"
```

### 上传 Wasm 合约

现在是时候将你在之前步骤中编译的 `.wasm` 文件上传到 Biyachain 测试网了。请注意，主网的程序流程不同，需要通过[治理提案](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/cosmwasm-developers/guides/mainnet-deployment/~/overview)进行。

```bash
# inside the "biyachain-core-staging" container, or from the contract directory if running biyachaind locally
yes 12345678 | biyachaind tx wasm store artifacts/my_first_contract.wasm \
--from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443
```

**输出:**

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

在 [Biyachain 测试网浏览器](https://testnet.explorer.injective.network/)中检查你的地址，查找与将代码存储到链上的交易相关的 `txhash`。交易类型应该是 `MsgStoreCode`。

你可以在 Biyachain 测试网上的 [Code](https://testnet.explorer.injective.network/codes/) 部分查看所有已存储的代码。

{% hint style="info" %}
有几种方法可以找到你刚刚存储的代码：

1. 在 Biyachain 浏览器的[Code列表](https://testnet.explorer.injective.network/codes/)中查找 `TxHash`，它很可能是最新的。
2. 使用 `biyachaind` 查询交易信息。
{% endhint %}

要查询交易，请使用 `txhash` 并验证合约是否已成功部署。

```sh
biyachaind query tx 912458AA8E0D50A479C8CF0DD26196C49A65FCFBEEB67DF8A2EA22317B130E2C --node=https://testnet.sentry.tm.biyachain.network:443
```

仔细检查输出，我们可以看到上传合约的 `code_id` 为 290。

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
      value: '"inj1h3gepa4tszh66ee67he53jzmprsqc2l9npq3ty"'
    type: cosmwasm.wasm.v1.EventCodeStored
  - attributes:
    - key: action
      value: /cosmwasm.wasm.v1.MsgStoreCode
    - key: module
      value: wasm
    - key: sender
      value: inj1h3gepa4tszh66ee67he53jzmprsqc2l9npq3ty
    type: message
  - attributes:
    - key: code_id
      value: "290"
    type: store_code
```

让我们将 `code_id` 导出为环境变量——我们稍后在实例化合约时需要用到它。你也可以跳过这一步，稍后手动添加，但请记住这个 ID。

```bash
export CODE_ID= <code_id of your stored contract>
```

### 生成 JSON 架构

虽然 Wasm 调用 `instantiate`、`execute` 和 `query` 接受 JSON，但仅有这些信息不足以使用它们。我们需要将预期消息的架构暴露给客户端。

为了利用 JSON 架构的自动生成，你应该为每个需要架构的数据结构进行注册。

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

然后，架构可以通过以下命令生成：

```bash
cargo schema
```

这将生成 5 个文件，保存在 `./schema` 目录中，分别对应合约接受的 3 种消息类型、查询响应消息和内部状态。这些文件采用标准的 JSON Schema 格式，可以被各种客户端工具使用，既可以自动生成编解码器，也可以根据定义的架构验证传入的 JSON。

花点时间生成架构（[可以在这里查看](https://github.com/InjectiveLabs/cw-counter/blob/master/schema/cw-counter.json)）并熟悉它，因为接下来你将需要用到它。

### 实例化合约

现在我们已经将代码上传到 Biyachain，是时候实例化合约并与之交互了。

{% hint style="info" %}
提醒：在 CosmWasm 中，合约代码的上传和合约的实例化被视为两个独立的事件。
{% endhint %}

要实例化合约，请运行以下 CLI 命令，使用你在上一步中获得的 `code_id`，以及 [JSON 编码的初始化参数](https://github.com/InjectiveLabs/cw-counter/blob/ea3b781447a87f052e4b8308d5c73a30481ed61f/schema/cw-counter.json#L7)和标签（该标签是该合约在人类可读列表中的名称）。

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

**输出:**

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
你可以通过以下方式找到合约地址和元数据：

* 在[测试网浏览器](https://www.injscan.com/smart-contracts/)中查看
* 查询 [ContractsByCode](https://k8s.testnet.lcd.injective.network/swagger/#/Query/ContractsByCode) 和 [ContractInfo](https://k8s.testnet.lcd.injective.network/swagger/#/Query/ContractInfo) API
* 通过 CLI 查询

```bash
biyachaind query wasm contract biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 --node=https://testnet.sentry.tm.biyachain.network:443
```
{% endhint %}

#### 查询合约

如我们之前所知，我们唯一的 `QueryMsg` 是 `get_count`。

```bash
GET_COUNT_QUERY='{"get_count":{}}'
biyachaind query wasm contract-state smart biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$GET_COUNT_QUERY" \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

**输出:**

```bash
{"data":{"count":99}}
```

我们看到 `count` 是 99，这是在实例化合约时设置的值。.

{% hint style="info" %}
如果你查询相同的合约，可能会收到不同的响应，因为其他人可能已经与合约交互并增加或重置了 `count`。
{% endhint %}

#### 执行合约

现在让我们通过增加计数器来与合约进行交互。

```bash
INCREMENT='{"increment":{}}'
yes 12345678 | biyachaind tx wasm execute biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$INCREMENT" --from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

如果我们查询合约的 `count`，我们会看到：

```bash
{"data":{"count":100}}
```

{% hint style="info" %}
是的，`12345678` | 自动将密码传递给 `biyachaind tx wasm execute` 的输入，因此你无需手动输入密码。
{% endhint %}

充值计数器：

```bash
RESET='{"reset":{"count":999}}'
yes 12345678 | biyachaind tx wasm execute biya1ady3s7whq30l4fx8sj3x6muv5mx4dfdlcpv8n7 "$RESET" \
--from=$(echo $BIYA_ADDRESS) \
--chain-id="biyachain-888" \
--yes --fees=1000000000000000biya --gas=2000000 \
--node=https://testnet.sentry.tm.biyachain.network:443 \
--output json
```

现在，如果我们再次查询合约，我们会看到 `count` 已经重置为提供的值：

```bash
{"data":{"count":999}}
```

### Cosmos Messages

除了定义自定义智能合约逻辑外，CosmWasm 还允许合约与底层的 Cosmos SDK 功能进行交互。一个常见的用例是使用 Cosmos SDK 的银行模块从合约向指定地址发送 tokens。

#### 示例: Bank Send

`BankMsg::Send` 消息允许合约将 tokens 转移到另一个地址。这在各种场景中都很有用，比如分发奖励或将资金返还给用户。

{% hint style="info" %}
**Note:** 如果你想同时发送资金并执行另一个合约中的函数，不要使用 `BankMsg::Send`。相反，使用 `WasmMsg::Execute` 并设置相应的资金字段。
{% endhint %}

#### 构造 Message

你可以在合约的 `execute` 函数中构造 `BankMsg::Send` 消息。此消息需要指定接收地址和要发送的金额。以下是如何构造该消息的示例：

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

#### 在智能合约中的使用

在你的合约中，你可以向 `ExecuteMsg` 枚举添加一个新变体，以处理银行发送功能。例如：

```rust
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    // ... other messages ...
    SendTokens { recipient: String, amount: Vec<Coin> },
}
```

然后，在 `execute` 函数中，你可以添加一个 case 来处理这个消息：

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

### 测试

像其他智能合约函数一样，你应该添加单元测试，以确保你的银行发送功能按预期工作。这包括测试不同场景，例如发送不同数量的 tokens，并正确处理错误。\
你可以使用 [test-tube](https://github.com/InjectiveLabs/test-tube) 来运行包括本地 Biyachain 链的集成测试。

恭喜你！你已经创建并与第一个 Biyachain 智能合约进行了交互，现在知道如何开始在 Biyachain 上进行 CosmWasm 开发。继续阅读了解如何创建 Web UI 的指南。
