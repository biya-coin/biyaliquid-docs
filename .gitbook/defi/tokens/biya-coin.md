# BIYA 币

BIYA 是为 Biya Chain 及其更广泛生态系统提供动力的原生资产。BIYA 的每个组成部分都经过精心设计，以培育繁荣的 Web3 生态系统。作为区块链的原生资产，BIYA 在促进 Biya Chain 上的各种操作方面发挥着核心作用。作为 Biya Chain 的 Tendermint 权益证明（PoS）共识框架自定义实现的重要组成部分，BIYA 对于通过质押保护网络安全至关重要。此外，BIYA 还作为 Biya Chain 的治理代币，并在更广泛的 Biya Chain 生态系统中充当交换手段。值得注意的是，BIYA 通过利用核心 Biya Chain 模块，通过创新的销毁和动态供应机制来设计通缩特性，从而区别于 PoS 链上的其他原生资产。

### 基础单位

BIYA 使用 [Atto](https://en.wikipedia.org/wiki/Atto-) 作为基础单位，以保持与 Ethereum 的平价。

```
1 biya = 1×10⁻¹⁸ BIYA
```

这与 Ethereum 的单位匹配：

```
1 wei = 1x10⁻¹⁸ ETH
```

### Biya Chain 代币经济学和用途

#### 1. 安全和质押

Biya Chain 通过质押来保护，这是 BIYA 的重要用例。验证者和委托者可以通过质押自由参与 Biya Chain 网络。验证者在 Biya Chain 上运行节点，委托者可以将 BIYA 分配给特定选择的节点。质押的 BIYA 实现了强大的去中心化环境，通过惩罚和奖励系统确保安全。

验证者质押的 BIYA 在恶意行为或未能有效履行职责的情况下会受到惩罚。此外，BIYA 用于奖励验证者参与交易验证和区块创建。验证者的奖励包括新铸造的 BIYA（区块奖励）和相关的交易费用的一部分。

BIYA 持有者也可以参与质押，而不必运行节点即可获得验证者奖励的份额。为此，用户将 BIYA 委托给验证者，可以通过支持的浏览器钱包完成，或直接通过 Biya Chain Hub 完成。作为锁定 BIYA 的回报，用户获得验证者 BIYA 奖励的份额，减去所选验证者收取的费用（佣金），按比例分配。如果委托的验证者发生惩罚事件，用户质押的 BIYA 也会受到惩罚。这确保了验证者和委托者都致力于为网络的整体安全做出贡献。

除了保护 Biya Chain 链之外，BIYA 还通过 Electro Chains 将其安全服务能力扩展到更广泛的生态系统。这些基于 Biya Chain 的 rollup 提供了许多技术优势，例如支持多个虚拟机，如 inEVM 所见。由于这些 rollup 结算到 Biya Chain，BIYA 为这些网络提供基础安全层。这种相互关联的安全框架强调了 BIYA 在维护 Biya Chain 网络以及 Electro Chains 多样化生态系统的完整性和稳健性方面的关键作用。

#### 2. 治理

BIYA 用于社区主导的链上所有参数的治理。Biya Chain 独特地还为智能合约上传设置了许可层，这意味着质押者社区必须投票才能在主网上实例化智能合约。这使社区能够直接治理 Biya Chain 整体的所有参数。

对于治理，BIYA 用于提案创建和对活跃提案的代币加权投票。作为防止垃圾邮件的措施，Biya Chain 要求最低存款（以 BIYA 支付），提案才能进入投票阶段。此存款阈值可以由提案者完全满足，也可以由其他用户向提案存款贡献 BIYA 累计满足。如果在最大存款期限到期时未达到最低存款金额，提案将被自动拒绝，存款将被销毁。此外，如果提案在投票期到期时未通过，提案存款将被销毁。

提案投票在预设的投票期内进行，该投票期通过治理设置并统一应用于所有治理投票。在投票过程中，只有质押的 BIYA 才有资格参与投票。因此，只有验证者和委托者可以对活跃提案进行投票。投票权是代币加权的，这意味着 1 BIYA 等于 1 票。委托者不需要积极参与治理来维持其地位。但是，他们可以选择直接对提案进行投票。如果委托者不投票，他们的投票权将自动由他们委托的验证者继承，用于该特定投票事件。

BIYA 用于治理链的所有方面，包括：

* 拍卖模块参数
* 交易所模块自定义提案和参数
* 保险模块参数
* 预言机模块自定义提案
* Peggy 模块参数
* Wasmx 模块参数
* 软件升级
* Cosmos-SDK 模块参数，包括 [auth](https://docs.cosmos.network/main/modules/auth#parameters)、[bank](https://docs.cosmos.network/main/modules/bank)、[crisis](https://docs.cosmos.network/main/modules/crisis)、[distribution](https://docs.cosmos.network/main/modules/distribution)、[gov](https://docs.cosmos.network/main/modules/gov)、[mint](https://docs.cosmos.network/main/modules/mint)、[slashing](https://docs.cosmos.network/main/modules/slashing) 和 [staking](https://docs.cosmos.network/main/modules/staking) 模块。

有关治理过程的完整详细信息可以在[此处](https://blog.biyachainprotocol.com/biyachain-governance-proposal-procedure)找到。

#### 3. 交换媒介

BIYA 用作默认资产，以促进区块链上各方之间商品和服务的买卖。常见的例子包括支付交易费用（gas）、买卖 NFT、支付交易费用或将资产作为抵押品存入。虽然大多数商品和服务可以用任何资产计价，但在 Biya Chain 上产生的所有交易费用都以 BIYA 支付。此外，通过交易所模块利用 Biya Chain 共享流动性层的应用程序产生的所有协议收入都累积在 BIYA 中。

#### 4. 交易所 dApp 激励

交易所协议实施全球最低交易费用，做市商为 0.1%，接受者为 0.2%。作为鼓励交易所 dApp 在交易所协议上获取交易活动的激励机制，将订单发起到共享订单簿的交易所 dApp 会获得其发起的所有订单产生的交易费用的 40% 作为奖励。

#### 5. 交易所费用价值累积

剩余的 60% 交易所费用将进行链上回购和销毁事件，其中聚合的交易所费用篮子被拍卖给出价最高者以换取 BIYA。此次拍卖的 BIYA 收益随后被销毁，从而通缩 BIYA 的总供应量。

有关拍卖机制的更多详细信息可以在[此处](/broken/pages/LWtYyWv8zLexjuh6ezp4)找到。

#### 6. 衍生品支持抵押品

BIYA 可以用作稳定币的替代品，作为 Biya Chain 衍生品市场的保证金和抵押品。在某些衍生品市场中，BIYA 还可以用作保险池质押的支持抵押品，质押者可以赚取锁定代币的利息。
