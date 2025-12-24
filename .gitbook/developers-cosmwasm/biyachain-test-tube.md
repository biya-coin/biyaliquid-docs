# Biya Chain Test Tube

`biyachain-test-tube` 是一个 CosmWasm x Biya Chain 集成测试库,与 `cw-multi-test` 不同,它允许您针对链的实际逻辑而不是模拟来测试您的 CosmWasm 合约。

`dev` 分支依赖于当前的私有仓库,但您可以使用已发布的版本。请参阅 [`CHANGELOG`](https://github.com/biya-coin/test-tube/blob/dev/packages/biyachain-test-tube/CHANGELOG.md) 了解功能和更新信息。

### 入门指南

为了演示 `biyachain-test-tube` 的工作原理,让我们使用一个简单的示例合约:来自 `cw-plus` 的 [cw-whitelist](https://github.com/CosmWasm/cw-plus/tree/main/contracts/cw1-whitelist)。

以下是如何设置测试:

```rust
use cosmwasm_std::Coin;
use biyachain_test_tube::BiyachainTestApp;

// 创建新的 biyachain 应用链实例
let app = BiyachainTestApp::new();

// 创建具有初始资金的新账户
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

现在我们有了应用链实例和具有一些初始余额的账户,可以与应用链交互。这不会运行 Docker 实例或生成外部进程,它只是将应用链的代码作为库加载以创建内存实例。

请注意,`init_accounts` 是一个便捷函数,用于创建具有相同初始余额的多个账户。如果您只想创建一个账户,可以使用 `init_account` 代替。

```rust
use cosmwasm_std::Coin;
use biyachain_test_tube::BiyachainTestApp;

let app = BiyachainTestApp::new();

let account = app.init_account(&[
    Coin::new(1_000_000_000_000, "usdt"),
    Coin::new(1_000_000_000_000, "biya"),
]);
```

现在如果我们想测试一个 cosmwasm 合约,我们需要:

* 构建 wasm 文件
* 存储代码
* 实例化

然后我们就可以开始与我们的合约交互了。让我们开始吧。

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

// ============= 新代码 ================

// `Wasm` 是我们用来与应用链上 cosmwasm 相关逻辑交互的模块
// 它实现了 `Module` trait,稍后您会看到更多内容
let wasm = Wasm::new(&app);

// 加载编译的 wasm 字节码
let wasm_byte_code = std::fs::read("./test_artifacts/cw1_whitelist.wasm").unwrap();
let code_id = wasm
    .store_code(&wasm_byte_code, None, admin)
    .unwrap()
    .data
    .code_id;
```

请注意,在此示例中,为了简单演示,它从 [cw-plus release](https://github.com/CosmWasm/cw-plus/releases) 加载 wasm 字节码。您可能想要运行 `cargo wasm` 并在 `target/wasm32-unknown-unknown/release/<contract_name>.wasm` 中找到您的 wasm 文件。

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

// ============= 新代码 ================

// 使用初始管理员实例化合约并使管理员列表可变
let init_admins = vec![admin.address()];
let contract_addr = wasm
    .instantiate(
        code_id,
        &InstantiateMsg {
            admins: init_admins.clone(),
            mutable: true,
        },
        None, // 用于迁移的合约管理员,与 cw1_whitelist 管理员不同
        Some("Test label"), // 合约标签
        &[], // 资金
        admin, // 签名者
    )
    .unwrap()
    .data
    .address;

// 查询合约状态以检查合约实例化是否正常工作
let admin_list = wasm
    .query::<QueryMsg, AdminListResponse>(&contract_addr, &QueryMsg::AdminList {})
    .unwrap();

assert_eq!(admin_list.admins, init_admins);
assert!(admin_list.mutable);
```

现在让我们执行合约并验证合约的状态是否正确更新。

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

// ============= 新代码 ================

// 更新管理员列表并重新检查状态
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

### 调试

在您的合约代码中,如果您想要调试,可以使用 [`deps.api.debug(..)`](https://docs.rs/cosmwasm-std/latest/cosmwasm_std/trait.Api.html#tymethod.debug),它会将调试消息打印到标准输出。`wasmd` 默认禁用此功能,但 `BiyachainTestApp` 允许标准输出,以便您在运行测试时可以调试智能合约。

### 使用模块包装器

在某些情况下,您可能希望直接与应用链逻辑交互以设置环境或查询应用链的状态。模块包装器提供了与应用链模块交互的便捷函数。

让我们尝试与 `Exchange` 模块交互:

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

更多示例可以在 [modules](https://github.com/biya-coin/test-tube/tree/dev/packages/biyachain-test-tube/src/module) 目录中找到。

### 版本控制

biyachain-test-tube 的版本由其依赖项(biyachain 和 test-tube)的版本以及其自身的更改决定。版本以 A.B.C 格式表示,其中:

* A 是 biyachain 的主版本号,
* B 是 test-tube 的次版本号,
* C 是 biyachain-test-tube 自身的补丁号。

当发布新版本的 biyachain 并包含破坏性更改时,我们也会发布来自 test-tube 的破坏性更改(如果有),并增加 biyachain-test-tube 的主版本号。这样可以清楚地表明新版本的 biyachain-test-tube 与以前的版本不向后兼容。

当向 biyachain-test-tube 添加向后兼容的新功能时,次版本号将递增。

当修复错误或进行其他 `biyachain-test-tube` 特定且向后兼容的更改时,补丁号将递增。

如果有破坏性更改,请查看升级指南以升级包。

重要的是要注意,我们独立于依赖项的版本来跟踪包的版本。
