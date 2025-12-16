# 安装 biyachaind

## 平台兼容性指南

查看下表以了解支持运行 `biyachaind` CLI 的平台:

| 平台 | 预构建二进制文件 | Docker | 从源代码构建 |
|----------|-------------------|--------|------------|
| macOS (M1/ARM) | ❌ | ✅ | ✅ |
| macOS (Intel) | ❌ | ✅ | ✅ |
| Windows (x86_64) | ❌ | ✅ | ❌ |
| Windows (ARM) | ❌ | ✅ | ❌ |
| Linux (x86_64) | ✅ | ✅ | ✅ |
| Linux (ARM) | ❌ | ✅ | ✅ |


## 使用预构建二进制文件开始

目前，唯一支持运行预构建 `biyachaind` CLI 的平台是 Linux x86_64。预构建的二进制文件可在 [Biyachain GitHub 发布页面](https://github.com/BiyachainLabs/biyachain-chain-releases/releases) 获取。

```bash
wget https://github.com/BiyachainLabs/biyachain-chain-releases/releases/download/v1.14.1-1740773301/linux-amd64.zip
unzip linux-amd64.zip
```

此压缩文件将包含以下文件:

* **`biyachaind`** - Biyachain 守护进程及命令行工具
* **`peggo`** - Biyachain 以太坊桥接中继守护进程
* **`libwasmvm.x86_64.so`** - WASM 虚拟机支持文件

注意: 部署和实例化智能合约不需要 `peggo`,它是为验证者准备的。

```bash
sudo mv biyachaind /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib
```

确认您的版本与以下输出匹配 (如果有更新版本,输出可能略有不同):

```bash
biyachaind version

Version v1.14.1 (0fe59376dc)
Compiled at 20250302-2204 using Go go1.23.1 (amd64)
```

继续查看 [使用 Biyachaind](./shi-yong-biyachaind.md) 了解如何使用 `biyachaind` CLI 与 Biyachain 区块链交互。

## 使用 Docker 开始

以下命令将启动一个包含 `biyachaind` CLI 的容器:

```bash
docker run -it --rm biya-coin/biyachain-core:v1.14.1 biyachaind version

Version v1.14.1 (0fe59376d)
Compiled at 20250302-2220 using Go go1.22.11 (amd64)
```

这与大多数平台以及 arm64 / x86_64 架构兼容。


继续查看 [使用 Biyachaind](./shi-yong-biyachaind.md) 了解如何使用 `biyachaind` CLI 与 Biyachain 区块链交互。


## 从源代码开始

以下命令将从源代码构建 `biyachaind` CLI:

```bash
git clone https://github.com/BiyachainFoundation/biyachain-core.git
cd biyachain-core && git checkout v1.14.1
make install
```

这将把 `biyachaind` CLI 安装到您的 go 路径。

```bash
biyachaind version

Version v1.14.1 (dd7622f)
Compiled at 20250302-2230 using Go go1.24.0 (amd64)
```

(提交哈希可能不同,因为开源仓库与预构建版本是分别发布的)。

继续查看 [使用 Biyachaind](./shi-yong-biyachaind.md) 了解如何使用 `biyachaind` CLI 与 Biyachain 区块链交互。
