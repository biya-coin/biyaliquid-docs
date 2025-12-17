---
sidebar_position: 4
title: 治理提案
---

# 提案

## GrantBandOraclePrivilegeProposal

可以通过 `GrantBandOraclePrivilegeProposal` 将 Band Oracle 权限授予 Band 提供商的中继者账户。

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

可以通过 `RevokeBandOraclePrivilegeProposal` 从 Band 提供商的中继者账户撤销 Band Oracle 权限。

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

可以通过 `GrantPriceFeederPrivilegeProposal` 将给定基础报价对的价格源权限授予中继者。

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

可以通过 `RevokePriceFeederPrivilegeProposal` 从中继者账户撤销价格源权限。

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

此提案用于将 band oracle 请求添加到列表中。当此提案被接受时，biyachain 链会从 bandchain 获取更多价格信息。

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

此提案用于删除请求或更新请求。\
当 `DeleteRequestId` 不为零时，它删除具有该 id 的请求并完成其执行。\
当 `DeleteRequestId` 为零时，它将 id 为 `UpdateOracleRequest.RequestId` 的请求更新为 UpdateOracleRequest。

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

此提案用于启用 Band 链和 Biya Chain 之间的 IBC 连接。\
当提案获得批准时，它将 BandIBCParams 更新为提案中配置的新参数。

```protobuf
message EnableBandIBCProposal {
    option (gogoproto.equal) = false;
    option (gogoproto.goproto_getters) = false;

    string title = 1;
    string description = 2;

    BandIBCParams band_ibc_params = 3 [(gogoproto.nullable) = false];
}
```

`BandIBCParams` 的详细信息可以在 [**状态**](01_state.md) 中查看

## GrantStorkPublisherPrivilegeProposal

可以通过 `GrantStorkPublisherPrivilegeProposal` 向发布者授予 Stork Publisher 权限。

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

可以通过 `RevokeStorkPublisherPrivilegeProposal` 从发布者撤销 Stork Publisher 权限。

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
