# 安装 biyachaind

## 平台兼容性指南

查看此表以了解支持`biyachaind` CLI运行的平台:

| Platform          | Pre-Built Binaries | Docker | From Source |
| ----------------- | ------------------ | ------ | ----------- |
| macOS (M1/ARM)    | ❌                  | ✅      | ✅           |
| macOS (Intel)     | ❌                  | ✅      | ✅           |
| Windows (x86\_64) | ❌                  | ✅      | ❌           |
| Windows (ARM)     | ❌                  | ✅      | ❌           |
| Linux (x86\_64)   | ✅                  | ✅      | ✅           |
| Linux (ARM)       | ❌                  | ✅      | ✅           |

## 开始使用预购建的二进制文件

目前，唯一支持运行预构建 `biyachaind CLI` 的平台是 Linux x86\_64。预构建的二进制文件可在 [Injective GitHub Releases page](https://github.com/InjectiveLabs/injective-chain-releases/releases). 页面上获取。

```bash
wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/v1.14.1-1740773301/linux-amd64.zip
unzip linux-amd64.zip
```

此 ZIP 文件将包含以下文件：

* **injectived** - Injective daemon 兼 CLI
* **peggo** - Injective 以太坊桥接中继 daemon
* **libwasmvm.x86\_64.so** - WASM 虚拟机支持文件

**注意**：部署和实例化智能合约时不需要 `peggo`，它是为验证者准备的。

```bash
sudo mv injectived /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib
```

确认您的版本与以下输出匹配（如果有更新版本，您的输出可能会略有不同）：

```bash
injectived version

Version v1.14.1 (0fe59376dc)
Compiled at 20250302-2204 using Go go1.23.1 (amd64)
```

继续阅读 [**使用 injectived**](https://docs.injective.network/injective-zhong-wen-wen-dang/toolkits/injectived/using-injectived)，了解如何使用 `injectived CLI` 与 Injective 区块链交互。

## 使用Docker

以下命令将启动一个包含 `injectived CLI` 的容器：

```bash
docker run -it --rm injectivelabs/injective-core:v1.14.1 injectived version

Version v1.14.1 (0fe59376d)
Compiled at 20250302-2220 using Go go1.22.11 (amd64)
```

这兼容大多数平台及 arm64 / x86\_64 架构。\
继续前往 [**使用 injectived**](https://docs.injective.network/injective-zhong-wen-wen-dang/toolkits/injectived/using-injectived)，了解如何使用 `injectived CLI` 与 Injective 区块链交互。

## 使用源代码

以下命令将从源代码构建 `injectived CLI`：

```bash
git clone https://github.com/InjectiveFoundation/injective-core.git
cd injective-core && git checkout v1.14.1
make install
```

这将把 `injectived CLI` 安装到您的 Go 路径中。

```bash
injectived version

Version v1.14.1 (dd7622f)
Compiled at 20250302-2230 using Go go1.24.0 (amd64)
```

（提交哈希可能会有所不同，因为开源存储库是与预构建版本分开发布的）。\
继续阅读 [**使用 injectived**](https://docs.injective.network/injective-zhong-wen-wen-dang/toolkits/injectived/using-injectived)，了解如何使用 `injectived CLI` 与 Injective 区块链交互。
