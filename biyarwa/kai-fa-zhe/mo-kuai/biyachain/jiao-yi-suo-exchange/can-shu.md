# 参数

交易模块包含以下参数：

| 键                                           | 类型             | 示例                 |
| ------------------------------------------- | -------------- | ------------------ |
| SpotMarketInstantListingFee                 | sdk.Coin       | 100biya            |
| DerivativeMarketInstantListingFee           | sdk.Coin       | 1000biya           |
| DefaultSpotMakerFeeRate                     | math.LegacyDec | 0.1%               |
| DefaultSpotTakerFeeRate                     | math.LegacyDec | 0.2%               |
| DefaultDerivativeMakerFeeRate               | math.LegacyDec | 0.1%               |
| DefaultDerivativeTakerFeeRate               | math.LegacyDec | 0.2%               |
| DefaultInitialMarginRatio                   | math.LegacyDec | 5%                 |
| DefaultMaintenanceMarginRatio               | math.LegacyDec | 2%                 |
| DefaultFundingInterval                      | int64          | 3600               |
| FundingMultiple                             | int64          | 3600               |
| RelayerFeeShareRate                         | math.LegacyDec | 40%                |
| DefaultHourlyFundingRateCap                 | math.LegacyDec | 0.0625%            |
| DefaultHourlyInterestRate                   | math.LegacyDec | 0.000416666%       |
| MaxDerivativeOrderSideCount                 | int64          | 20                 |
| BiyaRewardStakedRequirementThreshold        | sdk.Coin       | 25biya             |
| TradingRewardsVestingDuration               | int64          | 1209600            |
| LiquidatorRewardShareRate                   | math.LegacyDec | 0.05%              |
| BinaryOptionsMarketInstantListingFee        | sdk.Coin       | 10biya             |
| AtomicMarketOrderAccessLevel                | string         | SmartContractsOnly |
| SpotAtomicMarketOrderFeeMultiplier          | math.LegacyDec | 2x                 |
| DerivativeAtomicMarketOrderFeeMultiplier    | math.LegacyDec | 2x                 |
| BinaryOptionsAtomicMarketOrderFeeMultiplier | math.LegacyDec | 2x                 |
| MinimalProtocolFeeRate                      | math.LegacyDec | 0.00001%           |
| IsInstantDerivativeMarketLaunchEnabled      | bool           | false              |
