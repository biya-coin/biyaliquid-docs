# 测试网提案

假设您想在 `testnet` 上提交提案。由于提案的投票时间很短，我们建议降低提案的存款，以免提案直接进入投票阶段。基本上，它应该略低于 `min_deposit` 值。

以下是 `GrantProviderPrivilegeProposal` 的示例

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
  --deposit="40000000000000000000biya" <-- use this amount
```
