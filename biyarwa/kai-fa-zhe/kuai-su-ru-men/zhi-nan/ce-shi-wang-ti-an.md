# 测试网提案

假设您想在测试网上提交一个提案。由于提案的投票时间较短，我们建议将提案的存款金额调低，以避免提案直接进入投票阶段。基本上，存款金额应略低于 `min_deposit` 值。

提交提案后，您应该联系团队：

1. 加入 [Biyachain Discord server](https://discord.gg/injective) 并寻找相关的频道
2. 加入 [Biyachain Developer Telegram channel](https://t.me/+8Y_0HOFLhnRlZDU9).

这是 `GrantProviderPrivilegeProposal` 的示例：

```bash
biyachaind tx oracle grant-provider-privilege-proposal YOUR_PROVIDER \
  YOUR_ADDRESS_HERE \
  --title="TITLE OF THE PROPOSAL" \
  --description="Registering PROVIDER as an oracle provider" \
  --chain-id=biyachain-888 \
  --from=local_key \
  --node=https://testnet.sentry.tm.biyachain.network:443 \
  --gas-prices=160000000biya \
  --gas=20000000 \
  --deposit="40000000000000000000inj" <-- use this amount
```
