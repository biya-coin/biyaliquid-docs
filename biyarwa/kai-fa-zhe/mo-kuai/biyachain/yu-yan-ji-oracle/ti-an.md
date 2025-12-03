# 提案

## GrantProviderPrivilegeProposal

可以通过`GrantBandOraclePrivilegeProposal`将oracle提供者权限授予您的账户。在治理提案通过后，您将能够使用您的提供者中继价格源数据。

```protobuf
// Grant Privileges
message GrantProviderPrivilegeProposal {
  option (amino.name) = "oracle/GrantProviderPrivilegeProposal";
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  option (cosmos_proto.implements_interface) = "cosmos.gov.v1beta1.Content";

  string title = 1;
  string description = 2;
  string provider = 3;
  repeated string relayers = 4;
}
```

您可以根据以下示例提交您的提案：

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
  --deposit="40000000000000000000biya"
```

为了成功通过测试网的提案，`YOUR_DEPOSIT` 应略低于 `min_deposit` 值（例如，40000000000000000000biya）。之后，您应该联系Biyachain开发团队。开发团队将补充您的存款至 `min_deposit` 并为您的提案投票。

## RevokeProviderPrivilegeProposal

可以通过`RevokeProviderPrivilegeProposal`撤销您账户的oracle提供者权限。

```protobuf
// Revoke Privileges
message RevokeProviderPrivilegeProposal {
  option (amino.name) = "oracle/RevokeProviderPrivilegeProposal";
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  option (cosmos_proto.implements_interface) = "cosmos.gov.v1beta1.Content";

  string title = 1;
  string description = 2;
  string provider = 3;
  repeated string relayers = 5;
}
```

## GrantBandOraclePrivilegeProposal

可以通过`GrantBandOraclePrivilegeProposal`将Band Oracle权限授予Band提供者的中继者账户。

```protobuf
// Grant Privileges
message GrantBandOraclePrivilegeProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    repeated string relayers = 3;
}
```

## RevokeBandOraclePrivilegeProposal

可以通过`RevokeBandOraclePrivilegeProposal`从Band提供者的中继者账户撤销Band Oracle权限。

```protobuf
// Revoke Privileges
message RevokeBandOraclePrivilegeProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    repeated string relayers = 3;
}
```

## GrantPriceFeederPrivilegeProposal

可以通过`GrantPriceFeederPrivilegeProposal`将给定基础报价对的价格源权限授予中继者。

```protobuf
// Grant Privileges
message GrantPriceFeederPrivilegeProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    string base = 3;
    string quote = 4;
    repeated string relayers = 5;
}
```

## RevokePriceFeederPrivilegeProposal

可以通过`RevokePriceFeederPrivilegeProposal`从中继者账户撤销价格源权限。

```protobuf
// Revoke Privileges
message RevokePriceFeederPrivilegeProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    string base = 3;
    string quote = 4;
    repeated string relayers = 5;
}
```

## AuthorizeBandOracleRequestProposal

该提案用于将一个Band oracle请求添加到列表中。当提案被接受时，Biyachain链将从bandchain获取更多的价格信息。

```protobuf
message AuthorizeBandOracleRequestProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    BandOracleRequest request = 3 [(gogoproto.nullable) = false];
}
```

## UpdateBandOracleRequestProposal

该提案用于删除或更新请求。当`DeleteRequestId`不为零时，它将删除具有该ID的请求并完成其执行。当`DeleteRequestId`为零时，它将使用`UpdateOracleRequest.RequestId`更新该ID的请求为`UpdateOracleRequest`。

```protobuf
message UpdateBandOracleRequestProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;
    uint64 delete_request_id = 3;
    BandOracleRequest update_oracle_request = 4;
}
```

## EnableBandIBCProposal

该提案用于启用Band链和Biyachain链之间的IBC连接。当提案被批准时，它将更新`BandIBCParams`为提案中配置的新值。

```protobuf
message EnableBandIBCProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;

    BandIBCParams band_ibc_params = 3 [(gogoproto.nullable) = false];
}
```

`BandIBCParams` 的详细信息可以在[状态](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/modules/injective/oracle/01_state/~/overview)中查看。

## GrantStorkPublisherPrivilegeProposal

可以通过`GrantStorkPublisherPrivilegeProposal`从发布者授予Stork发布者权限。

```protobuf
// Grant Privileges
message GrantStorkPublisherPrivilegeProposal {
  option (amino.name) = "oracle/GrantStorkPublisherPrivilegeProposal";
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  option (cosmos_proto.implements_interface) = "cosmos.gov.v1beta1.Content";

  string title = 1;
  string description = 2;

  repeated string stork_publishers = 3;
}
```

## RevokeStorkPublisherPrivilegeProposal

可以通过`RevokeStorkPublisherPrivilegeProposal`从发布者撤销Stork发布者权限。

```protobuf
// Revoke Privileges
message RevokeStorkPublisherPrivilegeProposal {
  option (amino.name) = "oracle/RevokeStorkPublisherPrivilegeProposal";
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  option (cosmos_proto.implements_interface) = "cosmos.gov.v1beta1.Content";

  string title = 1;
  string description = 2;

  repeated string stork_publishers = 3;
}
```
