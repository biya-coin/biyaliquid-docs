# 事件

ocr模块会发出以下事件：

## 处理器

### MsgCreateFeed

| 类型      | 属性键    | 属性值           |
| ------- | ------ | ------------- |
| message | action | MsgCreateFeed |
| message | sender | {sender}      |

### MsgUpdateFeed

| 类型      | 属性键    | 属性值           |
| ------- | ------ | ------------- |
| message | action | MsgUpdateFeed |
| message | sender | {sender}      |

### MsgTransmit

| 类型                   | 属性键                   | 属性值                     |
| -------------------- | --------------------- | ----------------------- |
| EventNewTransmission | FeedId                | {FeedId}                |
| EventNewTransmission | AggregatorRoundId     | {AggregatorRoundId}     |
| EventNewTransmission | Answer                | {Answer}                |
| EventNewTransmission | Transmitter           | {Transmitter}           |
| EventNewTransmission | ObservationsTimestamp | {ObservationsTimestamp} |
| EventNewTransmission | Observations          | {Observations}          |
| EventNewTransmission | Observers             | {Observers}             |
| EventNewTransmission | ConfigDigest          | {ConfigDigest}          |
| EventNewTransmission | EpochAndRound         | {EpochAndRound}         |
| EventTransmitted     | ConfigDigest          | {ConfigDigest}          |
| EventTransmitted     | Epoch                 | {Epoch}                 |
| message              | action                | MsgTransmit             |
| message              | sender                | {sender}                |

### MsgFundFeedRewardPool

| 类型      | 属性键    | 属性值                   |
| ------- | ------ | --------------------- |
| message | action | MsgFundFeedRewardPool |
| message | sender | {sender}              |

### MsgWithdrawFeedRewardPool

| 类型      | 属性键    | 属性值                       |
| ------- | ------ | ------------------------- |
| message | action | MsgWithdrawFeedRewardPool |
| message | sender | {sender}                  |

### MsgSetPayees

| 类型      | 属性键    | 属性值          |
| ------- | ------ | ------------ |
| message | action | MsgSetPayees |
| message | sender | {sender}     |

### MsgTransferPayeeship

| 类型      | 属性键    | 属性值                  |
| ------- | ------ | -------------------- |
| message | action | MsgTransferPayeeship |
| message | sender | {sender}             |

### MsgAcceptPayeeship

| 类型      | 属性键    | 属性值                |
| ------- | ------ | ------------------ |
| message | action | MsgAcceptPayeeship |
| message | sender | {sender}           |

## 提案

### SetConfigProposal

| 类型             | 属性键                       | 属性值                         |
| -------------- | ------------------------- | --------------------------- |
| EventConfigSet | ConfigDigest              | {ConfigDigest}              |
| EventConfigSet | PreviousConfigBlockNumber | {PreviousConfigBlockNumber} |
| EventConfigSet | Config                    | {Config}                    |
| EventConfigSet | ConfigInfo                | {ConfigInfo}                |

### SetBatchConfigProposal

| 类型                | 属性键                       | 属性值                         |
| ----------------- | ------------------------- | --------------------------- |
| EventConfigSet\[] | ConfigDigest              | {ConfigDigest}              |
| EventConfigSet\[] | PreviousConfigBlockNumber | {PreviousConfigBlockNumber} |
| EventConfigSet\[] | Config                    | {Config}                    |
| EventConfigSet\[] | ConfigInfo                | {ConfigInfo}                |

## BeginBlocker
