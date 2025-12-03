# 状态

Genesis 状态定义了模块的初始状态，用于设置模块。

```go
// GenesisState defines the OCR module's genesis state.
type GenesisState struct {
	// params defines all the parameters of related to OCR.
	Params Params 
	// feed_configs stores all of the supported OCR feeds
	FeedConfigs []*FeedConfig
	// latest_epoch_and_rounds stores the latest epoch and round for each feedId
	LatestEpochAndRounds []*FeedEpochAndRound
	// feed_transmissions stores the last transmission for each feed
	FeedTransmissions []*FeedTransmission
	// latest_aggregator_round_ids stores the latest aggregator round ID for each feedId
	LatestAggregatorRoundIds []*FeedLatestAggregatorRoundIDs
	// reward_pools stores the reward pools
	RewardPools []*RewardPool
	// feed_observation_counts stores the feed observation counts
	FeedObservationCounts []*FeedCounts
	// feed_transmission_counts stores the feed transmission counts
	FeedTransmissionCounts []*FeedCounts
	// pending_payeeships stores the pending payeeships
	PendingPayeeships []*PendingPayeeship
}
```

## Params

Params 是一个模块级别的配置，用于存储系统参数并定义 OCR 模块的整体功能。该模块可以通过治理使用参数更新提案进行修改，治理模块原生支持此功能。

OCR 模块参数存储的结构体。

```go
type Params struct {
	// Native denom for LINK coin in the bank keeper
	LinkDenom string
	// The block number interval at which payouts are made
	PayoutBlockInterval uint64
	// The admin for the OCR module
	ModuleAdmin string
}
```

## FeedConfig

FeedConfig 用于管理 Feed 的配置，每个 Feed 存在一个对应的 FeedConfig。

```go
type FeedConfig struct {
	// signers ith element is address ith oracle uses to sign a report
	Signers []string
	// transmitters ith element is address ith oracle uses to transmit a report via the transmit method
	Transmitters []string
	// f maximum number of faulty/dishonest oracles the protocol can tolerate while still working correctly
	F uint32
	// onchain_config contains properties relevant only for the Cosmos module.
	OnchainConfig *OnchainConfig
	// offchain_config_version version of the serialization format used for "offchain_config" parameter
	OffchainConfigVersion uint64
	// offchain_config serialized data used by oracles to configure their offchain operation
	OffchainConfig []byte
}
```

### FeedConfigInfo

FeedConfigInfo 用于存储每次传输事件中需要更频繁更新的信息。

```go
type FeedConfigInfo struct {
	LatestConfigDigest []byte
	F                  uint32
	N                  uint32
	// config_count ordinal number of this config setting among all config settings
	ConfigCount             uint64
	LatestConfigBlockNumber int64
}
```

### Transmission

Transmission 是用于在存储中保存传输信息的单元。

```go
// Transmission records the median answer from the transmit transaction at
// time timestamp
type Transmission struct {
	Answer                math.LegacyDec
	ObservationsTimestamp int64
	TransmissionTimestamp int64
}
```

### Report

Report 是用于在存储中保存报告信息的单元。

```go
type Report struct {
	ObservationsTimestamp int64
	Observers             []byte
	Observations          []math.LegacyDec
}
```

ReportToSign 保存需要由观察者签名的信息。

```go
type ReportToSign struct {
	ConfigDigest []byte 
	Epoch        uint64
	Round        uint64 
	ExtraHash    []byte
	// Opaque report
	Report []byte
}
```

### OnchainConfig

OnchainConfig 保存需要在链上管理的 Feed 配置的相关配置。

```go
type OnchainConfig struct {
	// chain_id the ID of the Cosmos chain itself.
	ChainId string
	// feed_id is an unique ID for the target of this config
	FeedId string
	// lowest answer the median of a report is allowed to be
	MinAnswer math.LegacyDec
	// highest answer the median of a report is allowed to be
	MaxAnswer math.LegacyDec
	// Fixed LINK reward for each observer
	LinkPerObservation math.Int
	// Fixed LINK reward for transmitter
	LinkPerTransmission math.Int
	// Native denom for LINK coin in the bank keeper
	LinkDenom string
	// Enables unique reports
	UniqueReports bool
	// short human-readable description of observable this feed's answers pertain to
	Description string
	// feed administrator
	FeedAdmin string
	// feed billing administrator
	BillingAdmin string
}
```

### ContractConfig

ContractConfig 保存与合同相关的配置，用于存储 OCR。

```go
type ContractConfig struct {
	// config_count ordinal number of this config setting among all config settings
	ConfigCount uint64
	// signers ith element is address ith oracle uses to sign a report
	Signers []string 
	// transmitters ith element is address ith oracle uses to transmit a report via the transmit method
	Transmitters []string
	// f maximum number of faulty/dishonest oracles the protocol can tolerate while still working correctly
	F uint32
	// onchain_config serialized config that is relevant only for the module.
	OnchainConfig []byte
	// offchain_config_version version of the serialization format used for "offchain_config" parameter
	OffchainConfigVersion uint64
	// offchain_config serialized data used by oracles to configure their offchain operation
	OffchainConfig []byte
}
```

### FeedProperties

FeedProperties 是用于通过 ID 存储 Feed 属性的单元。

```go
type FeedProperties struct {
	// feed_id is an unique ID for the target of this config
	FeedId string
	// f maximum number of faulty/dishonest oracles the protocol can tolerate while still working correctly
	F uint32
	// offchain_config_version version of the serialization format used for "offchain_config" parameter
	OffchainConfigVersion uint64
	// offchain_config serialized data used by oracles to configure their offchain operation
	OffchainConfig []byte
	// lowest answer the median of a report is allowed to be
	MinAnswer math.LegacyDec
	// highest answer the median of a report is allowed to be
	MaxAnswer math.LegacyDec
	// Fixed LINK reward for each observer
	LinkPerObservation math.Int
	// Fixed LINK reward for transmitter
	LinkPerTransmission math.Int
	// Enables unique reports
	UniqueReports bool
	// short human-readable description of observable this feed's answers pertain to
	Description string
}
```

### PendingPayeeship

PendingPayeeship 是一个记录，当某人将支付权委托给另一个地址时存储此记录。当提议的支付方接受后，该记录将被移除。

```go
type PendingPayeeship struct {
	FeedId        string
	Transmitter   string
	ProposedPayee string
}
```
