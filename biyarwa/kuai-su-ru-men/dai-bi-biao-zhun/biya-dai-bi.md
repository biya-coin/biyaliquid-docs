# BIYA 代币

BIYA 是驱动 Biyachain 及其更广泛生态系统的本地资产。BIYA 的每个组成部分都是精心设计的，旨在培养一个繁荣的 Web3 生态系统。作为区块链的本地资产，BIYA 在促进 Biyachain 上的各种操作中发挥着核心作用。作为 Biyachain 定制的 Tendermint 权益证明（PoS）共识框架的重要组成部分，BIYA 对于通过质押保障网络安全至关重要。此外，BIYA 还作为 Biyachain 的治理代币，并作为更广泛 Biyachain 生态系统中的交换媒介。值得注意的是，BIYA 通过利用核心 Biyachain 模块，通过创新的销毁机制和动态供应机制，打造了通缩特性，从而与其他 PoS 链上的本地资产区别开来。

### 基础单位

BIYA 使用 [Atto](https://en.wikipedia.org/wiki/Atto-) 作为基础单位，以保持与以太坊的对等性。

```
1 biya = 1×10⁻¹⁸ BIYA
```

这与以太坊的单位相匹配：

```
1 wei = 1x10⁻¹⁸ ETH
```

### Biyachain 代币经济学与效用

**1. 安全性与质押**

Biyachain 通过质押机制来保障安全性，这是 BIYA 的一个重要应用场景。验证者和委托者可以自由参与 Biyachain 网络的质押过程。验证者在 Biyachain 上运行节点，而委托者可以将 BIYA 分配给其选择的特定节点。被质押的 BIYA 通过惩罚和奖励机制，确保了一个稳健的去中心化环境。

如果验证者存在恶意行为或未能有效履行职责，其被质押的 BIYA 可能会被削减（惩罚）。此外，BIYA 还用于奖励验证者，以激励他们参与交易验证和区块创建。验证者的奖励包括新铸造的 BIYA（区块奖励）以及部分相关交易费用。

BIYA 持有者无需运行节点即可参与质押并获得验证者奖励的一部分。用户可以通过支持的浏览器钱包或直接在 Biyachain Hub 上将 BIYA 委托给验证者。作为回报，用户在锁定 BIYA 后，将按照比例获得验证者的 BIYA 奖励，扣除所选验证者收取的佣金（手续费）。如果被委托的验证者发生惩罚性削减事件，用户的质押 BIYA 也可能会受到影响。这一机制确保了验证者和委托者共同为网络安全做出贡献。

除了保障 Biyachain 链的安全，BIYA 还通过 Electro Chains 扩展其安全服务能力。这些基于 Biyachain 的 Rollup 方案提供了多种技术优势，例如支持多个虚拟机（如 inEVM）。由于这些 Rollup 需要在 Biyachain 上结算，BIYA 便成为这些网络的基础安全层。这个互联的安全框架进一步凸显了 BIYA 在维护 Biyachain 网络完整性和稳定性，以及支持 Electro Chains 生态系统中的关键作用。

**2. 治理**

BIYA 被用于社区主导的治理，涵盖链上所有参数的管理。Biyachain 具有独特的智能合约上传权限层，这意味着要在主网部署智能合约，必须经过质押者社区的投票批准。这使得社区能够直接管理 Biyachain 的所有参数。

在治理方面，BIYA 用于创建提案，并在活跃提案上进行基于代币权重的投票。为防止垃圾提案，Biyachain 要求提案必须达到最低存款要求（以 BIYA 支付）才能进入投票阶段。这一存款门槛可以由提案人独自承担，或由其他用户共同出资补足。如果在最大存款期限内未达到最低存款要求，提案将自动被拒绝，且存款将被销毁（烧毁）。此外，如果提案在投票期结束后未能通过，提案存款也将被烧毁。

提案投票在预设的投票周期内进行，该周期由治理机制设定，并适用于所有治理投票。在投票过程中，只有已质押的 BIYA 才有资格参与投票，因此仅限验证者和委托者可以对活跃提案投票。投票权重基于代币数量计算，即 1 BIYA 等于 1 票。委托者无需主动参与治理即可保持其委托者身份，但他们可以选择直接对提案投票。如果委托者未投票，他们的投票权将在该特定投票事件中自动继承给他们所委托的验证者。

BIYA 可用于治理链上的所有方面，包括：

* 拍卖（Auction）模块参数
* 交易（Exchange）模块的自定义提案和参数
* 保险（Insurance）模块参数
* 预言机（Oracle）模块的自定义提案
* Peggy 模块参数
* Wasmx 模块参数
* 软件升级
* Cosmos-SDK 模块参数，包括 [auth](https://docs.cosmos.network/main/modules/auth#parameters), [bank](https://docs.cosmos.network/main/modules/bank), [crisis](https://docs.cosmos.network/main/modules/crisis), [distribution](https://docs.cosmos.network/main/modules/distribution), [gov](https://docs.cosmos.network/main/modules/gov), [mint](https://docs.cosmos.network/main/modules/mint), [slashing](https://docs.cosmos.network/main/modules/slashing) 和 [staking](https://docs.cosmos.network/main/modules/staking) 模块

完整的治理流程详情可在[此处](https://blog.injective.com/injective-governance-proposal-procedure/)查看。

**3. 交换媒介**

BIYA 作为默认资产，用于在区块链上促进各方之间的商品和服务交易。常见示例包括支付交易费用（Gas 费）、购买/出售 NFT、支付交易手续费或将资产作为抵押品存入。尽管大多数商品和服务可以用任何资产计价，但在 Biyachain 上产生的所有交易费用均以 BIYA 支付。此外，所有利用 Biyachain 共享流动性层的应用程序（通过交易模块）所产生的协议收入，最终都会以 BIYA 形式累积。

**4. 交易 dApp 激励措施**

交易协议实施了全球最低交易费用：做市商（Maker）为 0.1%，吃单者（Taker）为 0.2%。作为激励机制，旨在鼓励交易 dApp 在交易协议上引入交易活动，向共享订单簿提交订单的交易 dApp 将获得其促成订单所产生交易费用的 40% 作为奖励。

**5. 交易费用价值累积**

剩余的 60% 交易费用将进行链上回购和销毁事件，其中所有交易费用的总额将被打包，并通过拍卖出售给最高竞标者，竞标者支付 BIYA。该拍卖所得的 BIYA 将被销毁，从而减少总的 BIYA 供应量。\
有关拍卖机制的更多细节可以在[这里](https://docs.injective.network/injective-zhong-wen-wen-dang/getting-started/wallet/auction)找到。

**6. 衍生品的担保品**

BIYA 可以作为稳定币的替代品，用作 Biyachain 衍生品市场的保证金和担保品。在一些衍生品市场中，BIYA 还可以作为保险池质押的担保品，质押者可以在锁仓的代币上赚取利息。
