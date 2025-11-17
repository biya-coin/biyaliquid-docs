# 拍卖

## 销毁拍卖

BIYA 的完全多功能性通过一系列协同运作的机制得以实现。基于 Biyachain 对供应动态的创新方法，该资产通过一个精心设计的系统展现出通缩特性，旨在将 BIYA 从流通中移除。这个过程通过 Biyachain 的新颖销毁拍卖系统得以实现，该系统有效地减少了总供应量。

<figure><img src="https://lh7-rt.googleusercontent.com/docsz/AD_4nXcoU3ZEtvL328l94crrvGcsgOVRVe1nd1WeRKvumzwivCgmsfI-E0oQ4aGxUK-NsJ12nIwsAspfurBU3nqi9ON7VizZMoWVxK-3f7ROSaBTd16dPwL77el0JyUeWcErIfYZ1q1RAxZ-bLVYvizc4uduSF1v?key=SrpUIxF4ydd4ZLyJCcX74Q" alt="" width="563"><figcaption></figcaption></figure>

销毁拍卖定期举行，邀请参与者竞标一篮子代币，这些代币来自参与应用程序生成的部分收入以及个人用户的直接贡献。拍卖以英式拍卖方式进行，竞标使用 BIYA。最高出价者将在拍卖结束时获得整个代币篮子。获胜的 BIYA 出价将被销毁，从总供应量中移除。\
销毁拍卖由 Biyachain 的两个原生模块实现：交易和拍卖。这些模块是 Biyachain 核心功能的一部分，作为即插即用的金融原语，供任何在 Biyachain 上构建的项目使用。

**强化和参与的历史**

BIYA 2.0 于 2023 年发布，使得任何应用程序都可以向拍卖基金贡献，不仅限于使用交易模块的应用程序。Biyachain 于 2024 年 4 月发布的 BIYA 销毁升级扩展了该功能的访问权限，允许个人用户进行贡献。因此，任何项目或用户都可以直接向 Biyachain 销毁拍卖贡献，这反过来可以提高销毁拍卖的整体价值和效果。\
销毁拍卖每周举行，结束时间为 UTC-4:00 9:00。参与者可以通过 Biyachain Hub 或直接与区块链交互进行参与。[Biyachain Hub](https://hub.injective.network/auction/) 和 [Biyachain Explorer](https://explorer.injective.network/) 提供了销毁拍卖至今销毁的总 BIYA 的实时跟踪。

### 交易所模块

交易所模块是 Biyachain 与其他区块链的主要区别之一。这个技术工具为 Biyachain 上的共享流动性环境提供支持，并推动销毁拍卖的运作。订单簿管理、交易执行、订单匹配和结算的整个过程都通过该模块的逻辑在链上完成。\
销毁拍卖的关键设计特性是为使用交易模块的应用程序内置的收入共享结构。在此结构中，部分累积的收入被分配给拍卖模块，以便纳入当前的销毁拍卖事件，而剩余部分则由使用该模块的应用程序保留，用于支持其交易服务。

### 拍卖模块

拍卖模块为销毁拍卖的运作提供了两个关键服务：代币收集和拍卖协调。对于代币收集，该模块定期从交易模块收集代币，将它们汇集到一个拍卖基金中。值得注意的是，拍卖基金还接收来自未使用交易模块但选择参与的应用程序的代币，以及来自个人用户的贡献。拍卖过程本身涉及多个由拍卖模块管理的任务，包括协调竞标过程、确定赢家、交付获胜资产以及销毁获胜的 BIYA 出价。
