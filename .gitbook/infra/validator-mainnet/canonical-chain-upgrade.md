# 规范链升级

## 验证发布版本

### GitHub 上的发布

如果您想通过 Docker 验证 `biyachaind` 或 `peggo` 版本号，
请按照 [`verify-biyachain-release`](https://github.com/biyachain-dev/snippets-biya/tree/main/verify-biyachain-release) 代码片段中的说明进行操作。

如果您使用的是 Linux 以外的操作系统，
并希望独立验证每个发布版本中的二进制文件，这很有用。

例如，对于 `v1.16.1`，它应该产生以下输出：

```text
biyachaind version
Version v1.16.1 (8be67e82d)
Compiled at 20250802-1910 using Go go1.23.9 (amd64)
peggo version
Version v1.16.1 (8be67e82d)
Compiled at 20250802-1913 using Go go1.23.9 (amd64)
```

### Docker 上的发布

这些更直接，因为每个二进制文件只需要一个命令。

对于 `biyachaind`，使用以下命令：

```shell
docker run -it --rm biya-coin/biyachain-core:v1.16.1 biyachaind version
```

这应该产生类似的输出：

```text
Version v1.16.1 (8be67e8)
Compiled at 20250802-1909 using Go go1.23.9 (arm64)
```

对于 `peggo`，使用以下命令：

```shell
docker run -it --rm biya-coin/biyachain-core:v1.16.1 peggo version
```

这应该产生类似的输出：

```text
Version v1.16.1 (8be67e8)
Compiled at 20250802-1911 using Go go1.23.9 (arm64)
```

请注意，您应该将上述命令中的 `v1.16.1` 替换为您想要的 Biyachain 发布版本号。

### 检查匹配

请注意，上述命令的输出除了版本号（例如 `v1.16.1`）外，还包含以下内容：

- 二进制发布哈希（例如 `8be67e82d`）
- 编译时间戳（例如 `20250802-1910`）
- 编译器（例如 `Go go1.23.9 (amd64)`）

您可以验证这些**匹配** GitHub 上 [Biyachain 链发布](https://github.com/biya-coin/biyachain-chain-releases/releases) 页面中声明的值。

## 规范链升级历史

***

### Version 10002-rc1

November 8th, 2021, 14:00 UTC

Block number: [4,352,000](https://prv.scan.biya.io/zh/transactions/block/4352000)

Released Artifacts: [Biyachain Chain 10002-rc1 release](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.1.0-1636178708)

Following [proposal #65](https://prv.hub.biya.io/proposals/65)

***

### Version 10002-rc2

November 15th, 2021

Block number: [4,594,100](https://prv.scan.biya.io/zh/transactions/block/4594100)

Released Artifacts: [Biyachain Chain 10002-rc2 release](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.1.1-1636733798)

Following [proposal #70](https://prv.hub.biya.io/proposals/70)

***

### Version 10003-rc1

Thursday, December 30th, 2021

Block number: [6,159,200](https://prv.scan.biya.io/zh/transactions/block/6159200)

Released Artifacts: [Mainnet-10003-rc1-1640627705](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.1.1-1640627705)

Following [proposal #93](https://prv.hub.biya.io/proposals/93)

***

### Version 10004-rc1

Tuesday, January 25th, 2022

Block number: [7067700](https://prv.scan.biya.io/zh/transactions/block/7067700)

Released Artifacts: [Mainnet-10004-rc1-v1.4.0-1642928125](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.4.0-1642928125)

Following [proposal #106](https://prv.hub.biya.io/proposals/106)

***

### Version 10004-rc1-patch

Sunday, February 20th, 2022

Block number: [7941974](https://prv.scan.biya.io/zh/transactions/block/7941974)

Released Artifacts: [Mainnet-10004-rc1-v1.4.0-1645352045](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.4.0-1645352045)

***

### Version 10005-rc1

Monday, April 11th, 2022

Block number: [9614200](https://prv.scan.biya.io/zh/transactions/block/9614200)

Released Artifacts: [Mainnet-v1.5.0-1649280277](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.5.0-1649280277)

***

### Version 10006-rc1

Tuesday, July 5th, 2022

Block number: [12569420](https://prv.scan.biya.io/zh/transactions/block/12569420)

Released Artifacts: [Mainnet-v1.6.0-1656650662](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.6.0-1656650662)

***

### Version 10007-rc1

Thursday, September 1st, 2022

Block number: [14731000](https://prv.scan.biya.io/zh/transactions/block/14731000)

Released Artifacts: [Mainnet-v1.7.0-1661881062](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.7.0-1661881062)

***

### Version 10008 - Camelot

Monday, November 21st, 2022

Block number: [19761600](https://prv.scan.biya.io/zh/transactions/block/19761600)

Released Artifacts: [Mainnet-10008-1668679102](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.8.0-1668679102)

***

### Version 10009

Tuesday, January 18th, 2022

Block number: [24204000](https://prv.scan.biya.io/zh/transactions/block/24204000/)

Released Artifacts: [Mainnet-10009-1673970775](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.9.0-1673970775)

***

### v1.10

Friday, March 17th, 2023

Block number: [28864000](https://prv.scan.biya.io/zh/transactions/block/28864000/)

Released Artifacts: [Mainnet-v1.10-1678709842](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.10-1678709842)

***

### v1.11

Thursday, June 1st, 2023

Block number: [34775000](https://prv.scan.biya.io/zh/transactions/block/34775000/)

Released Artifacts: [v1.11-1685225746](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.11-1685225746)

***

### v1.12.0 - Volan

Thursday, January 11th, 2024

Block number: [57076000](https://prv.scan.biya.io/zh/transactions/block/57076000/)

Released Artifacts: [Mainnet-v1.12.0-1704530206](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.12.0-1704530206)

***

### v1.12.1

Monday, January 22nd, 2024

Block number: n/a

Released Artifacts: [Mainnet-v1.12.1-1705909076](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.12.1-1705909076)

***

### v1.13.0 - Altaris

Thursday, August 1st, 2024

Block number: [80319200](https://prv.scan.biya.io/zh/transactions/block/80319200/)

Released Artifacts: [Mainnet-v1.13.0-1722157491](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.13.0-1722157491)

***

### v1.13.2

Tuesday, August 20th, 2024

Block number: [82830000](https://prv.scan.biya.io/zh/transactions/block/82830000/)

Released Artifacts: [Mainnet-v1.13.2-1723753267](https://github.com/biya-coin/biyachain-chain-releases/releases/tag/v1.13.2-1723753267)
