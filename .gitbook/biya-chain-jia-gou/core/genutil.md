# `x/genutil`

## 概念

`genutil` 包包含各种创世实用功能，用于区块链应用程序中。即：

* 创世交易相关（gentx）
* 收集和创建 gentx 的命令
* gentx 的 `InitChain` 处理
* 创世文件创建
* 创世文件验证
* 创世文件迁移
* CometBFT 相关初始化
    * 将应用创世转换为 CometBFT 创世

## 创世

Genutil 包含定义应用创世的数据结构。
应用创世由共识创世（例如 CometBFT 创世）和应用相关的创世数据组成。

```go reference
https://github.com/cosmos/cosmos-sdk/blob/v0.50.0-rc.0/x/genutil/types/genesis.go#L24-L34
```

然后可以将应用创世转换为共识引擎的正确格式：

```go reference
https://github.com/cosmos/cosmos-sdk/blob/v0.50.0-rc.0/x/genutil/types/genesis.go#L126-L136
```

```go reference
https://github.com/cosmos/cosmos-sdk/blob/v0.50.0-rc.0/server/start.go#L397-L407
```

## 客户端

### CLI

genutil 命令在 `genesis` 子命令下可用。

#### add-genesis-account

将创世账户添加到 `genesis.json`。了解更多信息[请点击这里](https://docs.cosmos.network/main/run-node/run-node#adding-genesis-accounts)。

#### collect-gentxs

收集创世交易并输出 `genesis.json` 文件。

```shell
simd genesis collect-gentxs
```

这将创建一个新的 `genesis.json` 文件，其中包含所有验证器的数据（我们有时称其为"超级创世文件"以区别于单验证器创世文件）。

#### gentx

生成携带自委托的创世交易。

```shell
simd genesis gentx [key_name] [amount] --chain-id [chain-id]
```

这将为您的链创建创世交易。这里的 `amount` 应至少为 `1000000000stake`。
如果您提供的数量太多或太少，在启动节点时会遇到错误。

#### migrate

将创世迁移到指定的目标（SDK）版本。

```shell
simd genesis migrate [target-version]
```

:::tip
`migrate` 命令是可扩展的，接受 `MigrationMap`。此映射是目标版本到创世迁移函数的映射。
当不使用默认 `MigrationMap` 时，建议仍调用与链的 SDK 版本对应的默认 `MigrationMap`，并在其前后添加您自己的创世迁移。
:::

#### validate-genesis

验证默认位置或作为参数传递的位置的创世文件。

```shell
simd genesis validate-genesis
```

:::warning
验证创世仅验证创世在**当前应用二进制文件**中是否有效。要验证来自应用先前版本的创世，请使用 `migrate` 命令将创世迁移到当前版本。
:::
