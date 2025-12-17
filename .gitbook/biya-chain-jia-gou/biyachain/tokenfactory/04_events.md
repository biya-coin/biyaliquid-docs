---
sidebar_position: 4
title: 事件
---

# 事件

tokenfactory 模块发出以下事件：

执行 MsgCreateDenom 时会发出 EventCreateTFDenom 事件，该事件创建一个新的代币工厂代币单位。

```protobuf 
message EventCreateTFDenom {
  string account = 1;
  string denom = 2;
}
```

执行 MsgMint 时会发出 EventMintTFDenom 事件，该事件为接收者铸造新的代币工厂代币单位。

```protobuf
message EventMintTFDenom {
  string recipient_address = 1;
  cosmos.base.v1beta1.Coin amount = 2 [(gogoproto.nullable) = false];
}
```

执行 MsgBurn 时会发出 EventBurnDenom 事件，该事件为用户销毁任何代币单位的指定数量。

```protobuf
message EventBurnDenom {
  string burner_address = 1;
  cosmos.base.v1beta1.Coin amount = 2 [(gogoproto.nullable) = false];
}
``` 

执行 MsgChangeAdmin 时会发出 EventChangeTFAdmin 事件，该事件更改新代币工厂代币单位的管理员地址。

```protobuf
message EventChangeTFAdmin {
  string denom = 1;
  string new_admin_address = 2;
}

``` 

执行 MsgSetDenomMetadata 时会发出 EventSetTFDenomMetadata 事件，该事件为给定的代币工厂代币单位设置代币工厂代币单位元数据。

```protobuf
message EventSetTFDenomMetadata {
  string denom = 1;
  cosmos.bank.v1beta1.Metadata metadata = 2[(gogoproto.nullable) = false];
}
```