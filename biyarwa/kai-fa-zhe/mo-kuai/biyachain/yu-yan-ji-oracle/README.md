# 预言机(Oracle)

## 摘要

本规范指定了oracle模块，该模块主要由交易模块使用，以获取外部价格数据。

## 工作流

1. 新的价格源提供者必须首先通过治理提案获得oracle权限，该提案授予一组中继者权限。唯一的例外是Coinbase价格oracle，因为任何人都可以发送Coinbase价格更新，因为这些更新已经由Coinbase oracle私钥独占签名。 **示例授权提案**：`GrantBandOraclePrivilegeProposal、GrantPriceFeederPrivilegeProposal`
2. 一旦治理提案获得批准，指定的中继者可以通过发送特定于其oracle类型的中继消息来发布oracle数据。\
   **示例中继消息**：`MsgRelayBandRates、MsgRelayPriceFeedPrice、MsgRelayCoinbaseMessages`等
3. 收到中继消息后，oracle模块会检查中继者账户是否具有授权权限，并将最新的价格数据持久化到状态中。
4. 其他Cosmos-SDK模块可以通过查询oracle模块来获取特定提供者的最新价格数据。

**注意**：如果出现任何不一致，价格源权限可以通过治理撤销。\
**示例撤销提案**：`RevokeBandOraclePrivilegeProposal、RevokePriceFeederPrivilegeProposal`等

## Band IBC集成流程

Cosmos SDK区块链可以通过IBC进行相互交互，而Biyachain支持通过IBC从BandChain获取价格源数据。

1. 为了通过IBC与BandChain的oracle通信，Biyachain Chain必须首先使用中继者初始化与BandChain上oracle模块的通信通道。
2. 一旦建立连接，将生成一对通道标识符——一个用于Biyachain Chain，一个用于Band。通道标识符用于Biyachain Chain将外发的oracle请求数据包路由到Band。同样，Band的oracle模块在发送oracle响应时也使用该通道标识符。
3. 在设置好通信通道后，为了启用Band IBC集成，应该通过治理提案EnableBandIBCProposal。
4. 然后，应该通过AuthorizeBandOracleRequestProposal和UpdateBandOracleRequestProposal确定要通过IBC获取的价格列表。
5. 一旦启用BandIBC，链会定期发送价格请求IBC数据包（OracleRequestPacketData）到bandchain，而bandchain会通过IBC数据包（OracleResponsePacketData）返回价格。\
   Band链会在足够数量的数据提供者确认后提供价格，并且在发送请求后获取价格需要一定时间。为了在配置的间隔之前请求价格，任何用户都可以广播MsgRequestBandIBCRates消息，这会立即执行。

## 目录

1. [状态](zhuang-tai.md)
2. [**Keeper**](keeper.md)
3. [消息](xiao-xi.md)
4. [提案](ti-an.md)
5. [事件](shi-jian.md)
