---
sidebar_position: 5
title: 惩罚
---

# 惩罚

### 安全考虑

**Validator Set**（验证者集）是具有背后权益的实际密钥集，它们会因双重签名或其他不当行为而受到惩罚。我们通常认为链的安全性就是 _Validator Set_ 的安全性。这在每条链上都不同，但这是我们的黄金标准。即使 IBC 提供的安全性也不会超过两个相关 Validator Set 的最小值。

**Eth bridge relayer**（Eth 桥接中继者）是由验证者集与主 `biyachaind` 守护进程一起运行的二进制文件。它纯粹作为代码组织的问题而存在，负责签署 Ethereum 交易，以及观察 Ethereum 上的事件并将它们带入 Biya Chain 状态。它使用 Ethereum 密钥签署发往 Ethereum 的交易，并使用 Biya Chain 账户密钥签署来自 Ethereum 的事件。我们可以为由 _Validator Set_ 运行的任何 _Eth Signer_ 的任何错误签名消息添加惩罚条件，并能够提供与 _Validator Set_ 相同的安全性，只是由不同的模块检测恶意证据并决定惩罚多少。如果我们能够证明由 _Validator Set_ 的任何 _Eth Signer_ 签署的交易是非法的或恶意的，那么我们可以在 Biya Chain 端进行惩罚，并可能提供 _Validator Set_ 100% 的安全性。请注意，这还可以访问 3 周的解绑期，以允许证据进行惩罚，即使它们立即解绑。

以下是我们在 Peggy 中使用的各种惩罚条件。

## PEGGYSLASH-01: 签署虚假验证者集或交易批次证据

此惩罚条件旨在阻止验证者对从未在 Biya Chain 上存在的验证者集和 nonce 进行签名。它通过证据机制工作，任何人都可以提交包含验证者对虚假验证者集签名的消息。这旨在产生这样的效果：如果形成验证者卡特尔以提交虚假验证者集，一个叛逃者可以导致他们全部受到惩罚。

```go
// This call allows anyone to submit evidence that a
// validator has signed a valset, batch, or logic call that never
// existed. Subject contains the batch, valset, or logic call.
type MsgSubmitBadSignatureEvidence struct {
	Subject   *types1.Any 
	Signature string      
	Sender    string      
}
```

**实施考虑：**

此惩罚条件最棘手的部分是确定验证者集从未在 Biya Chain 上存在。为了节省空间，我们需要清理旧的验证者集。我们可以在 KV 存储中保留验证者集哈希到 true 的映射，并使用它来检查验证者集是否曾经存在。这比存储整个验证者集更高效，但其增长仍然是无界的。可能可以使用其他加密方法来减少此映射的大小。从此映射中修剪非常旧的条目可能是可以的，但任何修剪都会降低此惩罚条件的威慑力。

此惩罚条件的实施版本存储所有过去事件的哈希映射，这比存储整个批次或验证者集更小，并且不需要频繁访问。一个可能但目前未实施的效率优化是在给定时间段后从此列表中删除哈希。但这需要存储有关每个哈希的更多元数据。

目前中继者中未实施自动证据提交。当签名在 Ethereum 上可见时，惩罚已经太晚，无法防止桥接劫持或资金盗窃。此外，由于无论如何都需要验证者集的 66% 来执行此操作，相同的控制多数可以简单地拒绝证据。此惩罚条件最常见的设想情况是打破试图接管桥接的验证者卡特尔，通过使他们更难相互信任并实际协调此类盗窃。

盗窃将涉及交换可惩罚的 Ethereum 签名，并为组内任何叛逃者手动提交此消息开辟可能性。

目前这被实现为状态中不断增长的哈希数组。

## PEGGYSLASH-02: 未能签署交易批次

当验证者在 Peggy 模块创建交易批次后的 `SignedBatchesWindow` 内未签署交易批次时，会触发此惩罚条件。这可以防止两种不良情况：

1. 验证者根本懒得在其系统上保持正确的二进制文件运行，
2. 超过 1/3 的验证者卡特尔解绑然后拒绝签署更新，阻止任何批次获得足够的签名以提交到 Peggy Ethereum 合约。

## PEGGYSLASH-03: 未能签署验证者集更新

当验证者未签署由 Peggy 模块生成的验证者集更新时，会触发此惩罚条件。这可以防止两种不良情况：

1. 验证者根本懒得在其系统上保持正确的二进制文件运行，
2. 超过 1/3 的验证者卡特尔解绑然后拒绝签署更新，阻止任何验证者集更新获得足够的签名以提交到 Peggy Ethereum 合约。如果他们阻止验证者集更新的时间超过 Biya Chain 解绑期，他们将不再因提交虚假验证者集更新和交易批次而受到惩罚（PEGGYSLASH-01 和 PEGGYSLASH-03）。

为了处理情况 2，PEGGYSLASH-03 还需要惩罚那些不再验证但仍处于解绑期的验证者，最多 `UnbondSlashingValsetsWindow` 个区块。这意味着当验证者离开验证者集时，他们需要保持其设备运行至少 `UnbondSlashingValsetsWindow` 个区块。这对 Biya Chain 来说是不寻常的，可能不会被验证者接受。

`UnbondSlashingValsetsWindow` 的当前值是 25,000 个区块，大约 12-14 小时。我们根据以下逻辑确定这是一个安全值。只要每个离开验证者集的验证者至少签署一个不包含他们的验证者集更新，那么保证中继者可以产生一系列验证者集更新，将链上的当前状态转换为当前状态。

应该注意的是，如果可以在共识代码内执行 Ethereum 签名，那么 PEGGYSLASH-02 和 PEGGYSLASH-03 都可以在不损失安全性的情况下消除。这是对 Tendermint 的一个相当有限的功能补充，将使 Peggy 更不容易受到惩罚。

## PEGGYSLASH-04: 提交错误的 Eth oracle 声明（目前禁用）

Ethereum oracle 代码（目前主要包含在 attestation.go 中）是 Peggy 的关键部分。它允许 Peggy 模块了解 Ethereum 上发生的事件，例如存款和已执行的批次。PEGGYSLASH-04 旨在惩罚那些为从未在 Ethereum 上发生的事件提交声明的验证者。

**实施考虑**

我们了解事件是否在 Ethereum 上发生的唯一方法是通过 Ethereum 事件 oracle 本身。因此，为了实施此惩罚条件，我们惩罚那些在相同 nonce 下提交了与超过 2/3 验证者观察到的事件不同事件的声明的验证者。

尽管意图良好，但此惩罚条件可能不建议用于 Peggy 的大多数应用。这是因为它将安装它的 Biya Chain 的功能与 Ethereum 链的正确功能联系在一起。如果 Ethereum 链发生严重分叉，诚实行事的不同验证者可能在相同的事件 nonce 下看到不同的事件，并在没有自己过错的情况下受到惩罚。广泛的不公平惩罚将对 Biya Chain 的社会结构造成严重破坏。

也许 PEGGYSLASH-04 根本不需要：

此惩罚条件的真正效用是，如果超过 2/3 的验证者形成卡特尔以在某个 nonce 下全部提交虚假事件，其中一些可以叛离卡特尔并在该 nonce 下提交真实事件。如果有足够的叛离卡特尔成员使真实事件被观察到，那么剩余的卡特尔成员将受到此条件的惩罚。然而，这在大多数情况下需要超过 1/2 的卡特尔成员叛离。

如果卡特尔叛离者不够，那么两个事件都不会被观察到，Ethereum oracle 将停止。这比 PEGGYSLASH-04 实际触发的情况更可能发生。

此外，在成功卡特尔的情况下，PEGGYSLASH-04 将针对诚实验证者触发。这可能使形成的卡特尔更容易威胁不想加入的验证者。

## PEGGYSLASH-05: 未能提交 Eth oracle 声明（目前禁用）

这与 PEGGYSLASH-04 类似，但它针对不提交已观察到的 oracle 声明的验证者触发。与 PEGGYSLASH-04 相比，PEGGYSLASH-05 旨在惩罚那些完全停止参与 oracle 的验证者。

**实施考虑**

不幸的是，PEGGYSLASH-05 与 PEGGYSLASH-04 有相同的缺点，因为它将 Biya Chain 的正确操作与 Ethereum 链联系在一起。此外，它可能不会激励太多正确行为。为了避免触发 PEGGYSLASH-05，验证者只需要复制接近被观察到的声明。这种声明复制可以通过提交-揭示方案来防止，但对于"懒惰的验证者"来说，简单地使用公共 Ethereum 全节点或区块浏览器仍然很容易，对安全性有类似的影响。因此，PEGGYSLASH-05 的真正用处可能很小。

PEGGYSLASH-05 还引入了重大风险。主要是围绕 Ethereum 链上的分叉。例如，最近 OpenEthereum 未能正确处理 Berlin 硬分叉，由此产生的节点"故障"对自动化工具完全无法检测。它没有崩溃，所以没有重启要执行，区块仍在产生，尽管非常缓慢。如果这发生在 Peggy 运行且 PEGGYSLASH-05 激活时，它将导致那些验证者从集合中移除。可能对链造成非常混乱的时刻，因为数十个验证者因很少或没有自己的过错而被移除。

没有 PEGGYSLASH-04 和 PEGGYSLASH-05，Ethereum 事件 oracle 只有在超过 2/3 的验证者自愿提交正确声明时才会继续运行。尽管反对 PEGGYSLASH-04 和 PEGGYSLASH-05 的论据令人信服，但我们必须决定是否对此事实感到满意。或者，我们必须对 Biya Chain 可能因 Ethereum 生成的因素而完全停止感到满意。
