# Biyachain Test Tube

`biyachain-test-tube` 是一个 CosmWasm 与 Biyachain 集成的测试库，与 `cw-multi-test` 不同，它允许你将 CosmWasm 合约与链的实际逻辑进行测试，而不是使用模拟。\
dev 分支依赖于当前私有的仓库，但你可以使用发布的版本。请参阅 [CHANGELOG](https://github.com/InjectiveLabs/test-tube/blob/dev/packages/injective-test-tube/CHANGELOG.md) 以获取功能和更新信息。

## 快速入门

为了演示 `biyachain-test-tube` 的工作原理，我们将使用一个简单的示例合约：来自 `cw-plus` 的 [cw-whitelist](https://github.com/CosmWasm/cw-plus/tree/main/contracts/cw1-whitelist)。\
以下是如何设置测试的步骤：

```rust
use cosmwasm_std::Coin;
use biyachain_test_tube::BiyachainTestApp;

// create new biyachain appchain instance.
let app = BiyachainTestApp::new();

// create new account with initial funds
let accs = app
    .init_accounts(
        &[
            Coin::new(1_000_000_000_000, "usdt"),
            Coin::new(1_000_000_000_000, "biya"),
        ],
        2,
    )
    .unwrap();

let admin = &accs[0];
let new_admin = &accs[1];
```

现在我们已经有了 appchain 实例和一些具有初始余额的账户，这些账户可以与 appchain 进行交互。这并不运行 Docker 实例或启动外部进程，它只是将 appchain 的代码作为库加载，以创建一个内存中的实例。\
请注意，`init_accounts` 是一个便捷函数，它创建多个具有相同初始余额的账户。如果你只想创建一个账户，可以改为使用 `init_account`。

```rust
use cosmwasm_std::Coin;
use biyachain_test_tube::BiyachainTestApp;

let app = BiyachainTestApp::new();

let account = app.init_account(&[
    Coin::new(1_000_000_000_000, "usdt"),
    Coin::new(1_000_000_000_000, "biya"),
]);
```

现在，如果我们想测试一个 CosmWasm 合约，我们需要：

1. 构建 wasm 文件
2. 存储代码
3. 实例化合约

然后，我们就可以开始与合约进行交互了。让我们一步步来操作。

```rust
use cosmwasm_std::Coin;
use cw1_whitelist::msg::{InstantiateMsg}; // for instantiating cw1_whitelist contract
use biyachain_test_tube::{Account, Module, BiyachainTestApp, Wasm};

let app = BiyachainTestApp::new();
let accs = app
    .init_accounts(
        &[
            Coin::new(1_000_000_000_000, "usdt"),
            Coin::new(1_000_000_000_000, "biya"),
        ],
        2,
    )
    .unwrap();
let admin = &accs[0];
let new_admin = &accs[1];

// ============= NEW CODE ================

// `Wasm` is the module we use to interact with cosmwasm related logic on the appchain
// it implements `Module` trait which you will see more later.
let wasm = Wasm::new(&app);

// Load compiled wasm bytecode
let wasm_byte_code = std::fs::read("./test_artifacts/cw1_whitelist.wasm").unwrap();
let code_id = wasm
    .store_code(&wasm_byte_code, None, admin)
    .unwrap()
    .data
    .code_id;
```

需要注意的是，在此示例中，它从 [cw-plus release](https://github.com/CosmWasm/cw-plus/releases) 发布中加载 wasm 字节码，以便进行简单演示。你可能需要运行 `cargo wasm`，并在 `target/wasm32-unknown-unknown/release/<contract_name>.wasm` 中找到你的 wasm 文件。

```rust
use cosmwasm_std::Coin;
use cw1_whitelist::msg::{InstantiateMsg, QueryMsg, AdminListResponse};
use biyachain_test_tube::{Account, Module, BiyachainTestApp, Wasm};

let app = BiyachainTestApp::new();
let accs = app
    .init_accounts(
        &[
            Coin::new(1_000_000_000_000, "usdt"),
            Coin::new(1_000_000_000_000, "biya"),
        ],
        2,
    )
    .unwrap();
let admin = &accs[0];
let new_admin = &accs[1];

let wasm = Wasm::new(&app);


let wasm_byte_code = std::fs::read("./test_artifacts/cw1_whitelist.wasm").unwrap();
let code_id = wasm
    .store_code(&wasm_byte_code, None, admin)
    .unwrap()
    .data
    .code_id;

// ============= NEW CODE ================

// instantiate contract with initial admin and make admin list mutable
let init_admins = vec![admin.address()];
let contract_addr = wasm
    .instantiate(
        code_id,
        &InstantiateMsg {
            admins: init_admins.clone(),
            mutable: true,
        },
        None, // contract admin used for migration, not the same as cw1_whitelist admin
        Some("Test label"), // contract label
        &[], // funds
        admin, // signer
    )
    .unwrap()
    .data
    .address;

// query contract state to check if contract instantiation works properly
let admin_list = wasm
    .query::<QueryMsg, AdminListResponse>(&contract_addr, &QueryMsg::AdminList {})
    .unwrap();

assert_eq!(admin_list.admins, init_admins);
assert!(admin_list.mutable);
```

现在，让我们执行合约并验证合约的状态是否正确更新。

```rust
use cosmwasm_std::Coin;
use cw1_whitelist::msg::{InstantiateMsg, QueryMsg, ExecuteMsg, AdminListResponse};
use biyachain_test_tube::{Account, Module, BiyachainTestApp, Wasm};

let app = BiyachainTestApp::new();
let accs = app
    .init_accounts(
        &[
            Coin::new(1_000_000_000_000, "usdt"),
            Coin::new(1_000_000_000_000, "biya"),
        ],
        2,
    )
    .unwrap();
let admin = &accs[0];
let new_admin = &accs[1];

let wasm = Wasm::new(&app);


let wasm_byte_code = std::fs::read("./test_artifacts/cw1_whitelist.wasm").unwrap();
let code_id = wasm
    .store_code(&wasm_byte_code, None, admin)
    .unwrap()
    .data
    .code_id;

// instantiate contract with initial admin and make admin list mutable
let init_admins = vec![admin.address()];
let contract_addr = wasm
    .instantiate(
        code_id,
        &InstantiateMsg {
            admins: init_admins.clone(),
            mutable: true,
        },
        None, // contract admin used for migration, not the same as cw1_whitelist admin
        Some("Test label"), // contract label
        &[], // funds
        admin, // signer
    )
    .unwrap()
    .data
    .address;

let admin_list = wasm
    .query::<QueryMsg, AdminListResponse>(&contract_addr, &QueryMsg::AdminList {})
    .unwrap();

assert_eq!(admin_list.admins, init_admins);
assert!(admin_list.mutable);

// ============= NEW CODE ================

// update admin list and rechec the state
let new_admins = vec![new_admin.address()];
wasm.execute::<ExecuteMsg>(
    &contract_addr,
    &ExecuteMsg::UpdateAdmins {
        admins: new_admins.clone(),
    },
    &[],
    admin,
)
.unwrap();

let admin_list = wasm
    .query::<QueryMsg, AdminListResponse>(&contract_addr, &QueryMsg::AdminList {})
    .unwrap();

assert_eq!(admin_list.admins, new_admins);
assert!(admin_list.mutable);
```

## 调试

在你的合约代码中，如果你想进行调试，可以使用 [`deps.api.debug(..)`](https://docs.rs/cosmwasm-std/latest/cosmwasm_std/trait.Api.html#tymethod.debug)，它会将调试消息打印到标准输出。`wasmd` 默认禁用了这个功能，但 `BiyachainTestApp` 允许输出到标准输出，这样你就可以在运行测试时调试你的智能合约。

## 使用模块包装器

在某些情况下，你可能想直接与 appchain 的逻辑进行交互，以设置环境或查询 appchain 的状态。模块包装器提供了方便的函数来与 appchain 的模块进行交互。\
让我们尝试与 Exchange 模块进行交互：

```rust
use cosmwasm_std::{Addr, Coin};
use biyachain_std::types::biyachain::exchange::v1beta1::{
    MarketStatus, MsgInstantSpotMarketLaunch,
    QuerySpotMarketsRequest, QuerySpotMarketsResponse, SpotMarket,
};
use biyachain_test_tube::{Account, Exchange, BiyachainTestApp};
use test_tube_biya::Module;

let app = BiyachainTestApp::new();
let signer = app
    .init_account(&[
        Coin::new(10_000_000_000_000_000_000_000u128, "biya"),
        Coin::new(100_000_000_000_000_000_000u128, "usdt"),
    ])
    .unwrap();
let trader = app
    .init_account(&[
        Coin::new(10_000_000_000_000_000_000_000u128, "biya"),
        Coin::new(100_000_000_000_000_000_000u128, "usdt"),
    ])
    .unwrap();
let exchange = Exchange::new(&app);

exchange
    .instant_spot_market_launch(
        MsgInstantSpotMarketLaunch {
            sender: signer.address(),
            ticker: "BIYA/USDT".to_owned(),
            base_denom: "biya".to_owned(),
            quote_denom: "usdt".to_owned(),
            min_price_tick_size: "10000".to_owned(),
            min_quantity_tick_size: "100000".to_owned(),
        },
        &signer,
    )
    .unwrap();

exchange
    .instant_spot_market_launch(
        MsgInstantSpotMarketLaunch {
            sender: signer.address(),
            ticker: "BIYA/USDT".to_owned(),
            base_denom: "biya".to_owned(),
            quote_denom: "usdt".to_owned(),
            min_price_tick_size: "10000".to_owned(),
            min_quantity_tick_size: "100000".to_owned(),
        },
        &signer,
    )
    .unwrap_err();

app.increase_time(1u64);

let spot_markets = exchange
    .query_spot_markets(&QuerySpotMarketsRequest {
        status: "Active".to_owned(),
        market_ids: vec![],
    })
    .unwrap();

let expected_response = QuerySpotMarketsResponse {
    markets: vec![SpotMarket {
        ticker: "BIYA/USDT".to_string(),
        base_denom: "biya".to_string(),
        quote_denom: "usdt".to_string(),
        maker_fee_rate: "-100000000000000".to_string(),
        taker_fee_rate: "1000000000000000".to_string(),
        relayer_fee_share_rate: "400000000000000000".to_string(),
        market_id: "0xd5a22be807011d5e42d5b77da3f417e22676efae494109cd01c242ad46630115"
            .to_string(),
        status: MarketStatus::Active.into(),
        min_price_tick_size: "10000".to_string(),
        min_quantity_tick_size: "100000".to_string(),
    }],
};
assert_eq!(spot_markets, expected_response);
```

更多示例可以在[模块](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/modules)目录中找到。

## 版本管理

`biyachain-test-tube` 的版本由其依赖项 biyachain 和 test-tube 的版本以及自身的更改决定。版本表示为 A.B.C 格式，其中：

* **A** 是 biyachain 的主版本号，
* **B** 是 test-tube 的次版本号，
* **C** 是 biyachain-test-tube 本身的修补版本号。

当发布新的 biyachain 版本且包含破坏性更改时，如果 test-tube 也有破坏性更改，我们也会发布这些更改，并递增 `biyachain-test-tube` 的主版本号。这样，可以明确新版本的 `biyachain-test-tube` 不向后兼容之前的版本。

当向 `biyachain-test-tube` 添加向后兼容的新功能时，将递增次版本号。

当修复 bug 或进行其他 `biyachain-test-tube` 特定且向后兼容的更改时，将递增修补版本号。

请查阅升级指南以了解如何升级包，以应对破坏性更改。

需要注意的是，我们跟踪包的版本与依赖项的版本是独立的。
