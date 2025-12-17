# `Oracle`

## 摘要

本规范说明了 oracle 模块，该模块主要由 `exchange` 模块使用以获取外部价格数据。

## 工作流程

1. 新的价格源提供商必须首先通过治理提案获得 oracle 权限，该提案将权限授予一系列中继者。Coinbase 价格预言机例外，因为任何人都可以发送 Coinbase 价格更新，因为它们已经由 Coinbase oracle 私钥专门签名。<br/>
   **授权提案示例**：`GrantBandOraclePrivilegeProposal`、`GrantPriceFeederPrivilegeProposal`
2. 一旦治理提案获得批准，指定的中继者可以通过发送特定于其 oracle 类型的中继消息来发布 oracle 数据。<br/>
   **中继消息示例**：`MsgRelayBandRates`、`MsgRelayPriceFeedPrice`、`MsgRelayCoinbaseMessages` 等
3. 收到中继消息后，oracle 模块检查中继者账户是否具有授权权限，并将最新价格数据持久化到状态中。
4. 其他 Cosmos-SDK 模块然后可以通过查询 oracle 模块来获取特定提供商的最新价格数据。

**注意**：如果出现任何差异，可以通过治理撤销价格源权限 <br />
**撤销提案示例**：`RevokeBandOraclePrivilegeProposal`、`RevokePriceFeederPrivilegeProposal` 等

## Band IBC 集成流程

Cosmos SDK 区块链能够使用 IBC 相互交互，Biya Chain 支持通过 IBC 从 bandchain 获取价格源的功能。

1. 要使用 IBC 与 BandChain 的 oracle 通信，Biya Chain 必须首先使用中继者初始化与 BandChain 上 oracle 模块的通信通道。

2. 建立连接后，会生成一对通道标识符——一个用于 Biya Chain，一个用于 Band。Biya Chain 使用通道标识符将传出的 oracle 请求数据包路由到 Band。同样，Band 的 oracle 模块在发回 oracle 响应时使用通道标识符。

3. 在设置通信通道后，要启用 band IBC 集成，`EnableBandIBCProposal` 的治理提案应该通过。

4. 然后，要通过 IBC 获取的价格列表应由 `AuthorizeBandOracleRequestProposal` 和 `UpdateBandOracleRequestProposal` 确定。

5. 一旦启用 BandIBC，链会定期向 bandchain 发送价格请求 IBC 数据包（`OracleRequestPacketData`），bandchain 通过 IBC 数据包（`OracleResponsePacketData`）响应价格。Band 链在达到阈值数量的数据提供商确认时提供价格，发送请求后需要时间才能获得价格。要在配置的间隔之前请求价格，任何用户都可以广播 `MsgRequestBandIBCRates` 消息，该消息会立即执行。

## 目录

1. [状态](./01_state.md)
2. [Keeper](./02_keeper.md)
3. [消息](./03_messages.md)
4. [提案](./04_proposals.md)
5. [事件](./05_events.md)
6. [改进](./06_future_improvements.md)
