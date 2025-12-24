# gRPC 与 Protobuf

gRPC 是一个现代的开源高性能远程过程调用（RPC）框架，可以在任何环境中运行。它可以高效地连接数据中心内部和跨数据中心的服务，并提供可插拔的负载均衡、跟踪、健康检查和身份验证支持。它还适用于分布式计算的最后一公里，将设备、移动应用程序和浏览器连接到后端服务。

Protobuf 是 gRPC 最常用的 IDL（接口定义语言）。它是您以 proto 文件的形式存储数据和函数契约的地方。

```proto
message Person {
    required string name = 1;
    required int32 id = 2;
    optional string email = 3;
}
```
