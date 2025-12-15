# 使用 Go 程序化与节点交互

{% hint style="info" %}
以下示例使用 Go，但 Python 和 TS SDK 也可用于程序化与节点/Biyachain 交互。

* [TypeScript 示例](../developers-native/examples/README.md)
* [Python 示例](https://github.com/biya-coin/sdk-python/tree/master/examples)
{% endhint %}

以下代码片段展示了如何在 Go 程序中使用 gRPC 查询状态。思路是创建 gRPC 连接，并使用 Protobuf 生成的客户端代码查询 gRPC 服务器。

```go
import (
    "context"
    "fmt"

	"google.golang.org/grpc"

    sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/tx"
)

func queryState() error {
    myAddress, err := sdk.AccAddressFromBech32("biya...")
    if err != nil {
        return err
    }

    // Create a connection to the gRPC server.
    grpcConn := grpc.Dial(
        "127.0.0.1:9090", // your gRPC server address.
        grpc.WithInsecure(), // The SDK doesn't support any transport security mechanism.
    )
    defer grpcConn.Close()

    // This creates a gRPC client to query the x/bank service.
    bankClient := banktypes.NewQueryClient(grpcConn)
    bankRes, err := bankClient.Balance(
        context.Background(),
        &banktypes.QueryBalanceRequest{Address: myAddress, Denom: "biya"},
    )
    if err != nil {
        return err
    }

    fmt.Println(bankRes.GetBalance()) // Prints the account balance

    return nil
}
```

#### **使用 Go 查询历史状态**

通过向 gRPC 请求添加区块高度元数据来查询历史区块。

```go
import (
    "context"
    "fmt"

    "google.golang.org/grpc"
    "google.golang.org/grpc/metadata"

    grpctypes "github.com/cosmos/cosmos-sdk/types/grpc"
	"github.com/cosmos/cosmos-sdk/types/tx"
)

func queryState() error {
    // --snip--

    var header metadata.MD
    bankRes, err = bankClient.Balance(
        metadata.AppendToOutgoingContext(context.Background(), grpctypes.GRPCBlockHeightHeader, "12"), // Add metadata to request
        &banktypes.QueryBalanceRequest{Address: myAddress, Denom: denom},
        grpc.Header(&header), // Retrieve header from response
    )
    if err != nil {
        return err
    }
    blockHeight = header.Get(grpctypes.GRPCBlockHeightHeader)

    fmt.Println(blockHeight) // Prints the block height (12)

    return nil
}
```

