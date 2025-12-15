# 归档设置

本指南将引导您完成创建提供归档数据的节点集群的过程，以及如何使用网关将它们连接在一起。

## 架构

为了使提供归档数据更容易访问，我们将数据分割成更小的段。这些段存储在 `s3://biyachain-snapshots/mainnet/subnode`

| 快照目录 | 区块高度范围 | Biya Chain 版本 | 推荐磁盘大小 |
| ------------ | ------------ | ----------------- | --------------------- |
| `/0073`      | 0 – 73M      | v1.12.1           | 42 TiB                |
| `/6068`      | 60M – 68M    | v1.12.1           | 7 TiB                 |
| `/7380`      | 73M – 80M    | v1.12.1           | 7 TiB                 |
| `/8088`      | 80M – 88M    | v1.13.3           | 7 TiB                 |
| `/8896`      | 88M – 96M    | v1.13.3           | 7 TiB                 |
| `/8898`      | 88M – 98M    | v1.13.3           | 7 TiB                 |
| `/98106`     | 98M – 106M   | v1.13.3           | 7 TiB                 |
| `/98107`     | 98M – 107M   | v1.14.0           | 7.5 TiB               |
| `/66101`     | 66M – 101M   | v1.14.0           | 27 TiB                |
| `/105116`    | 105M – 116M  | v1.15.0           | 7.5 TiB               |

这些段通过网关连接在一起，网关是一个聚合代理，根据区块范围将查询路由到相应的节点。

![Archival Architecture](../.gitbook/assets/archival_architecture.jpg)

## 系统要求

每个托管归档数据切片的节点应满足以下最低要求：

| 组件   | 最低规格 | 说明                                                      |
| ----------- | --------------------- | ---------------------------------------------------------- |
| **CPU**     | AMD EPYC™ 9454P       | 48 核 / 96 线程                                      |
| **内存**  | 128 GB DDR5 ECC       | DDR5-5200 MHz 或更高，ECC 用于数据完整性            |
| **存储** | 7 – 40 TB NVMe Gen 4  | PCIe 4.0 驱动器，可以是单个驱动器或 RAID-0 阵列 |

## 设置步骤

### 在每个托管归档段的节点上：

#### 1. 使用以下命令下载设置所需的归档段历史记录

```bash
aws s3 cp --recursive s3://biyachain-snapshots/mainnet/subnode/<SNAPSHOT_DIR> $BIYA_HOME
```

#### 2. 根据上表下载或设置相应的 biyachain 二进制文件或镜像标签

#### 3. 生成配置文件夹

```bash
biyachaind init $MONIKER --chain-id biyachain-1 --home $BIYA_HOME --overwrite
```

#### 4. 在 app.toml 文件中禁用修剪，在 config.toml 文件中阻止 p2p 并将日志级别设置为 error。

这确保数据不会被修剪，节点保持在停止状态。将日志级别设置为 error 可以减少磁盘操作并提高性能。

```bash
# Disable pruning in app.toml
sed -i 's/^pruning *= *.*/pruning = "nothing"/' $BIYA_HOME/config/app.toml

# Disable p2p and disable create empty blocks on config.toml
awk '
    BEGIN { section = "" }
    /^\[/ {
    section = $0
    }
    section == "[p2p]" {
    if ($1 ~ /^laddr/) $0 = "laddr = \"tcp://0.0.0.0:26656\""
    if ($1 ~ /^max_num_inbound_peers/) $0 = "max_num_inbound_peers = 0"
    if ($1 ~ /^min_num_inbound_peers/) $0 = "min_num_inbound_peers = 0"
    if ($1 ~ /^pex/) $0 = "pex = false"
    if ($1 ~ /^seed_mode/) $0 = "seed_mode = false"
    }
    section == "[consensus]" {
    if ($1 ~ /^create_empty_blocks/) $0 = "create_empty_blocks = false"
    }
    { print }
    ' $BIYA_HOME/config/config.toml > $BIYA_HOME/config/config.tmp && mv $BIYA_HOME/config/config.tmp $BIYA_HOME/config/config.toml

# Set log level to error (less disk writes = better performance)
sed -i 's/^log_level *= *.*/log_level = "error"/' $BIYA_HOME/config/app.toml
```

#### 5. 运行节点

```bash
biyachaind start --home $BIYA_HOME
```

### 网关配置

#### 1. 克隆网关仓库

```bash
git clone https://github.com/decentrio/gateway
```

#### 2. 构建网关

```bash
make build
```

#### 3. 创建配置文件

```yaml
upstream:
  # example node 1 holds blocks 0-80M while node 2 holds blocks 80-88M
  - rpc: "http://$NODE1:$RPC_PORT"
    grpc: "$NODE1:$GRPC_PORT"
    api: "http://$NODE1:$API_PORT"
    blocks: [0,80000000]  
  - rpc: "http://$NODE2:$RPC_PORT"
    grpc: "$NODE2:$GRPC_PORT"
    api: "http://$NODE2:$API_PORT"
    blocks: [80000000,88000000]

  # <OTHER NODES HERE>

  # Archival tip, this serves the latest x blocks, usually set as a pruned node
  - rpc: "http://$PRUNED_NODE:$RPC_PORT"
    grpc: "$PRUNED_NODE:$GRPC_PORT"
    api: "http://$PRUNED_NODE:$API_PORT"
    blocks: [1000]


ports:
  rpc: $RPC_PORT
  api: $API_PORT 
  grpc: $GRPC_PORT
  # Leave these as zero to disable for now
  jsonrpc: 0
  jsonrpc_ws: 0

```

#### 4. 运行网关

```bash
gateway start --config $CONFIG_FILE
```
