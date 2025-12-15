---
description: OLP 仪表板
---

# 性能跟踪

有关市场分配、预期/已获得奖励、每个市场的分数和资格的当前和历史信息可以在 [Biyachain 交易门户](https://trading.biyachain.network/)的 [OLP 仪表板](https://trading.biyachain.network/program/liquidity)上找到。&#x20;

快照数据可以在[分数选项卡](https://trading.biyachain.network/program/liquidity/scores)下找到。也可以在[分数选项卡](https://trading.biyachain.network/program/liquidity/scores)下载 CSV 文件，以同时查看所有地址和所有市场的分数——这些信息可能对希望从广泛层面查看数据的市场参与者有帮助。

当前和之前周期的 OLP 数据也可以通过编程方式查询：&#x20;

{% code title="周期和市场：" overflow="wrap" fullWidth="false" %}
```
curl -s -X POST https://glp.rest.biyachain.network/biyachain_dmm_v2_rpc.biyachaindmmV2RPC/GetEpochs
```
{% endcode %}

{% code title="每个地址的奖励：" overflow="wrap" fullWidth="false" %}
```
curl -s -d '{"epochId":"epoch_231128_231225"}' -X POST https://glp.rest.biyachain.network/biyachain_dmm_v2_rpc.biyachaindmmV2RPC/GetEpochScores
```
{% endcode %}

{% code title="市场中的奖励：" overflow="wrap" %}
```
curl -X POST -d '{"epochId": "epoch_240123_240219", "marketId":"0x4ca0f92fc28be0c9761326016b5a1a2177dd6375558365116b5bdda9abc229ce", "page": {"perPage": 200}}' https://glp.rest.biyachain.network/biyachain_dmm_v2_rpc.biyachaindmmV2RPC/GetTotalScores
```
{% endcode %}

{% code title="地址的快照：" overflow="wrap" %}
```
curl -X POST -d '{"epochId": "epoch_240123_240219", "accountAddress": "<INSERT MM ADDRESS>", "marketId":"0x4ca0f92fc28be0c9761326016b5a1a2177dd6375558365116b5bdda9abc229ce", "page": {"perPage": 200}}' https://glp.rest.biyachain.network/biyachain_dmm_v2_rpc.biyachaindmmV2RPC/GetTotalScoresHistory
```
{% endcode %}
