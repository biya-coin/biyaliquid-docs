# 策略开发指南

## 配置指南

Biya Chain Trader 使用 YAML 配置文件来定义行为、组件和策略参数。

需要关注的最重要配置部分是：

* `LogLevel`
* `Components` 部分下 `Initializer` 中的 `Network` 和 `MarketTickers`
* `Strategies` 部分

以下是配置结构的详细说明：

### 顶层参数

```yaml
Exchange: Helix                # 要使用的交易所
LogLevel: INFO                 # 日志级别（DEBUG、INFO、WARNING、ERROR）
```

### Components 部分

`Components` 部分配置框架组件：

```yaml
Components:
  # Chain initialization and market setup
  Initializer:
    Network: mainnet           # Network to connect to (mainnet or testnet)
    MarketTickers:             # Market tickers to track (will be converted to IDs)
      - BIYA/USDT PERP
      - ETH/USDT
    BotName: MyBot

  # Chain listening configuration
  ChainListener:
    ReconnectionDelay: 5       # Seconds to wait before reconnection attempts
    LargeGapThreshold: 50      # Sequence gap threshold for orderbook snapshot requests

  # Transaction broadcasting configuration
  MessageBroadcaster:
    ErrorCodesJson: config/error_codes.json   # Error code lookup for tx validation
    GranteePool:               # For authz transaction mode
      MaxPendingTxs: 5         # Maximum pending transactions per grantee
      ErrorThreshold: 3        # Consecutive errors before blocking a grantee
      BlockDuration: 300       # Seconds to block a grantee after errors
      RotationInterval: 1      # Seconds between grantee rotations
    RefreshInterval: 300       # Seconds between grant refresh checks
    Batch:                     # Transaction batching settings
      MaxBatchSize: 15         # Maximum messages per batch
      MinBatchSize: 3          # Minimum messages to trigger immediate send
      MaxGasLimit: 5000000     # Maximum gas per batch
      MaxBatchDelay: 0.5       # Maximum seconds to wait for batch completion
```

{% hint style="info" %}
**注意**：大多数用户只需要关注 `Network` 并在 `MarketTickers` 中包含他们想要监听的所有市场。他们不需要修改这些高级组件设置。默认值适用于大多数用例。
{% endhint %}

### Strategies 部分

`Strategies` 部分定义每个交易策略：

```yaml
Strategies:
  SimpleStrategy:                                    # Strategy identifier (your choice)
    # Required parameters
    Name: "SimpleStrategy"                           # Strategy name (used in logs)
    Class: "SimpleStrategy"                          # [REQUIRED] Python class name to instantiate
    MarketIds:                                       # [REQUIRED] Markets to trade on
      - "0x9b9980167ecc3645ff1a5517886652d94a0825e54a77d2057cbbe3ebee015963"  # BIYA/USDT PERP
    AccountAddresses:                                # [REQUIRED] Accounts to use
      - "biya1youractualaccount..."                   # (Must match private key in env)
    TradingAccount: "biya1youractualaccount..."       # [REQUIRED] Account for placing orders (Must match private key in env)

    # Optional parameters
    FeeRecipient: "biya1feerecipient..."   # Address to receive trading fees (if applicable)
    CIDPrefix: "simple_strat"              # Prefix for client order IDs
    SubaccountIds: ["0x123..."]            # Specific subaccounts to use (otherwise all available)

    # Risk management configuration [Optional]
    # You don't have to include them if you don't have your specific risk model
    Risk: "BasicRiskModel"                 # Risk model to apply (if using risk management)
    RiskConfig:                            # Risk thresholds
      DrawdownWarning: 0.1                 # 10% drawdown warning threshold
      DrawdownCritical: 0.2                # 20% drawdown critical threshold
      MarginWarning: 0.7                   # 70% margin usage warning
      MarginCritical: 0.8                  # 80% margin usage critical
```

**必需的策略参数：**

* `Class`：必须与您的 Python 类名完全匹配
* `MarketIds`：此策略要交易的市场 ID 列表（使用十六进制格式）
* `AccountAddresses`：此策略用于交易的账户列表
* `TradingAccount`：用于订单执行的账户（必须在 `AccountAddresses` 中）\[有关更多详细信息，请参阅[交易模式配置](https://www.notion.so/Trading-Mode-Configuration-1bb7a004ab758056affdefc2c99aca08?pvs=21)]

**推荐参数：**

* `CIDPrefix`：客户端订单 ID 的前缀（帮助识别您的订单）
* `Name`：用于日志和监控的可读名称

**自定义参数：**

* 您可以添加策略需要的任何自定义参数
* 策略名称下的所有参数都将在 `self.config` 中可用
* 为了清晰起见，将相关参数分组到 `Parameters` 部分下

### 交易模式配置

该框架支持两种交易模式：

#### 直接执行模式

```yaml
Strategies:
  SimpleStrategy:
    # Other parameters...
    TradingAccount: "biya1youraccount..."   # Account that will sign and broadcast transactions
```

#### 授权（Authz）模式

```yaml
Strategies:
  SimpleStrategy:
    # 其他参数...
    Granter: "biya1granteraccount..."   # 授予执行交易权限的账户
    Grantees:                          # 可以代表授权者执行交易的账户
      - "biya1grantee1..."
      - "biya1grantee2..."
```

{% hint style="info" %}
**注意**：您必须为直接执行指定 `TradingAccount`，或为授权模式指定 `Granter` 和 `Grantees`。框架在初始化期间强制执行此要求。
{% endhint %}

### RetryConfig 部分

`RetryConfig` 部分控制网络操作的重试行为：

```yaml
RetryConfig:
  # Global retry settings
  DefaultRetry:
    max_attempts: 3            # Maximum retry attempts
    base_delay: 1.0            # Base delay between retries (seconds)
    max_delay: 32.0            # Maximum delay cap (seconds)
    jitter: true               # Add randomness to delay
    timeout: 30.0              # Operation timeout (seconds)
    error_threshold: 10        # Errors before circuit breaking
    error_window: 60           # Error counting window (seconds)

  # Component-specific retry settings (override defaults)
  ChainListener:
    max_attempts: 5            # More retries for chain listener
    base_delay: 2.0
    max_delay: 45.0
  MessageBroadcaster:
    max_attempts: 3
    base_delay: 1.0
    max_delay: 30.0
```

{% hint style="info" %}
**注意**：RetryConfig 具有合理的默认值，通常不需要自定义，除非您遇到特定的连接问题。
{% endhint %}

***

现在我们了解了整体结构，准备开发自定义策略了！

## 策略开发指南

Biya Chain Trader 中的策略遵循基于 `Strategy` 基类的一致结构。本节解释如何构建有效的策略。

### 策略类结构

您的策略类继承自基础 `Strategy` 类：

```python
from src.core.strategy import Strategy, StrategyResult
from src.utils.enums import UpdateType, Side

class SimpleStrategy(Strategy):
    def __init__(self, logger, config):
		"""
        Initialize strategy with logger and configuration.

        Args:
            logger: Logger instance for strategy logging
            config: Strategy configuration dictionary
                Required keys:
                - MarketIds: List of market IDs to trade
                - AccountAddresses: List of account addresses to use
                Optional keys:
                - Name: Strategy name
                - Parameters: Strategy-specific parameters
                - RiskConfig: Risk management parameters
        """
        super().__init__(logger, config)

    def on_initialize(self, accounts, markets):
        """
        Initialize strategy-specific state and parameters.
        Called once before strategy starts processing updates.

        Args:
            accounts: Dictionary of account_address -> Account
            markets: Dictionary of market_id -> Market
        """
        pass

    async def _execute_strategy(self, update_type, processed_data):
        """
        Strategy-specific execution logic.

       Args:
          update_type: Type of update being processed
          processed_data: Update-specific data dictionary after handler processing
              Common fields:
              - market_id: Market identifier
              - account_address: Account address (for account updates)
              - subaccount_id: Subaccount identifier (for position/trade updates)

        Returns:
            StrategyResult:
            - orders
            - cancellations
            - margin updates
        """
        pass
```

#### 策略构造函数（`__init__`）

您的策略类可以包含调用父类构造函数的构造函数：

```python
def __init__(self, logger, config):
    super().__init__(logger, config)

    # Custom initialization that doesn't require markets or accounts
    self.custom_parameter = 42

    # Optional: Custom handler overrides
    self.handlers[UpdateType.OnOrderbook] = MyCustomOrderbookHandler(
        self.logger, self.config, self.metrics
    )

    # Optional: Custom performance metrics overrides
    self.my_metrics = MyCustomPerformanceMetrics(self.logger)
```

基类构造函数处理：

1. 参数验证和提取
2. 设置标准指标和处理器（有关编写自己的处理器的更多信息，请参阅 \[block link]）
3. 初始化状态跟踪容器
4. 设置交易模式（直接或 authz）

{% hint style="info" %}
**重要**：`__init__` 方法无法访问市场数据或账户信息。对于需要这些资源的操作，请使用 `on_initialize`。
{% endhint %}

基础 `__init__` 提供的可用属性：

| **Property**             | **Description**                                       | **Source**                                                             | **Required**   |
| ------------------------ | ----------------------------------------------------- | ---------------------------------------------------------------------- | -------------- |
| `self.name`              | Strategy name used in log                             | From config `Name`                                                     | YES            |
| `self.logger`            | Logger instance                                       | For strategy-specific logging                                          | YES            |
| `self.config`            | Complete strategy configuration                       | Corresponding strategy subsection under `Strategies` section in config | YES            |
| `self.market_ids`        | List of market IDs interested in this strategy        | From config `MarketIds`                                                | YES            |
| `self.account_addresses` | List of account addresses interested in this strategy | From config `AccountAddresses`                                         | YES            |
| `self.subaccount_ids`    | List of subaccount IDs                                | From config `SubaccountIds`                                            | NO             |
| `self.markets`           | Dictionary of market\_id → `Market` objects           | Populated during initialization                                        | NO             |
| `self.accounts`          | Dictionary of account\_address → `Account` objects    | Populated during initialization                                        | NO             |
| `self.trading_mode`      | "direct" or "authz”                                   | Based on config                                                        | YES            |
| `self.fee_recipient`     | Fee recipient address                                 | From config `FeeRecipient`                                             | NO             |
| `self.cid_prefix`        | Client order ID prefix                                | From config `CIDPrefix`                                                | NO             |
| `self.metrics`           | Performance tracking                                  | For recording metrics and alerts                                       | YES \[DEFAULT] |
| `self.handlers`          | Event handlers dictionary                             | UpdateType → Handler objects                                           | YES \[DEFAULT] |

#### 初始化方法（`on_initialize`）

`on_initialize` 方法在框架启动期间调用一次，在加载市场和账户之后。

**目的**：初始化策略状态和参数 **参数**：

* `accounts`：account\_address → `Account` 对象的字典
* `markets`：market\_id → `Market` 对象的字典

**返回**：\[可选] 带有初始订单的 `StrategyResult`（如果有）

```python
def on_initialize(self, accounts, markets):
    # Now you have access to all market and account data

    # Example: Access market metadata
    for market_id in self.market_ids:
        market = markets[market_id]
        self.logger.info(f"Market {market_id} tick sizes: "
                         f"price={market.min_price_tick}, "
                         f"quantity={market.min_quantity_tick}")

    # Example: Initialize parameters that need market info
    self.avg_prices = {
        market_id: markets[market_id].orderbook.tob()[0]
        for market_id in self.market_ids
        if markets[market_id].orderbook.tob()[0]
    }

    # Example: Place initial orders
    if self.config.get("PlaceInitialOrders", False):
        result = StrategyResult()
        # Add initial orders...
        return result

    return None  # No initial orders
```

此方法是策略初始化序列的一部分：

1. 框架加载此策略所需的市场和账户
2. 使用加载的数据调用您的 `on_initialize` 方法
3. 任何返回的订单都会立即提交
4. 策略进入运行状态

{% hint style="info" %}
**提示**：使用 `on_initialize` 进行需要市场或账户数据的参数初始化，并下达策略所需的任何初始订单。有关 `Account` 和 `Market` 的数据结构信息，请参见下文。
{% endhint %}

#### 策略逻辑（`_execute_strategy`）方法

`_execute_strategy` 方法是"策略执行（`execute`）方法"的一部分。基类 `execute` 方法处理完整的执行流程：

1. **初始化检查**：如果需要，初始化策略
2. **状态更新**：更新策略的账户和市场引用
3. **数据处理**：通过适当的处理器处理原始更新数据
4. **策略执行**：使用处理后的数据调用您的 `_execute_strategy` 方法
5. **订单丰富**：向订单添加默认值（费用接收者、客户端 ID）

您很少需要覆盖此方法。相反，专注于实现 `_execute_strategy`，您的自定义交易逻辑在其中：

**目的**：分析市场数据并生成交易信号 **参数**：

* `update_type`：正在处理的更新类型 \[有关更多信息，请参阅[更新类型和相应的数据字段](https://www.notion.so/Update-Types-and-Corresponding-Data-Fields-1bb7a004ab7580c1a32ed133b770937a?pvs=21)]
* `processed_data`：带有相关字段的处理器处理的数据字典

**返回**：带有订单/取消的 `StrategyResult` 或 `None`

```python
async def _execute_strategy(self, update_type, processed_data):
    # Only respond to orderbook updates
    if update_type != UpdateType.OnOrderbook:
        return None

    # Get market data
    market_id = processed_data["market_id"]
    market = self.markets[market_id]

    # Get current prices
    bid, ask = market.orderbook.tob()
    if not bid or not ask:
        self.logger.warning(f"Incomplete orderbook for {market_id}")
        return None

    # Implement your strategy logic
    spread = (ask - bid) / bid
    if spread < self.min_spread_threshold:
        self.logger.info(f"Spread too narrow: {spread:.2%}")
        return None

    # Get subaccount for orders
    subaccount_id = self.config.get("SubaccountIds", [""])[0]
    if not subaccount_id:
        return None

    # Check current position to avoid exceeding limits
    position = self.get_position(subaccount_id, market_id)
    current_size = Decimal("0")
    if position:
        current_size = position.get("quantity", Decimal("0"))

    # Determine order parameters
    result = StrategyResult()

    # Create a new order
    if current_size < self.max_position:
        buy_order = Order(
            market_id=market_id,
            subaccount_id=subaccount_id,
            order_side=Side.BUY,
            price=bid,
            quantity=self.order_size,
            market_type=market.market_type # Required field as of v0.5.1
        )
        result.orders.append(buy_order)
        self.logger.info(f"Creating BUY order at {bid}: {self.order_size}")

    # Cancel existing orders if needed
    for order_hash in self.active_orders:
        result.cancellations.append({
            "market_id": market_id,
            "subaccount_id": subaccount_id,
            "order_hash": order_hash
        })

    return result
```

在 `_execute_strategy` 中您可以：

* 按更新类型过滤以处理特定事件
* 访问当前市场数据和账户状态
* 在下单前检查现有持仓
* 根据市场条件实现自定义交易逻辑
* 创建新订单并取消现有订单
* 更新衍生品市场的持仓保证金
* 记录策略决策以进行监控和调试

框架将根据您返回的 `StrategyResult` 处理交易创建、模拟和广播等执行细节。

#### 最佳实践

1. **在 `on_initialize` 中初始化所有参数**
   * 从 `self.config` 获取参数
   * 为缺失的参数设置默认值
   * 初始化内部状态变量
2. **过滤更新类型**
   * 只处理您的策略关心的更新类型
   * 始终检查 processed\_data 中的必需字段
3. **验证市场数据**
   * 在使用前检查买价/卖价是否存在
   * 在基于持仓做出决策之前验证持仓是否存在
4. **遵守市场约束**
   * 将价格和数量舍入到市场刻度大小
   * 检查最小订单大小和名义要求
5. **正确处理交易账户**
   * 确保交易账户在 AccountAddresses 中
   * 为订单指定正确的 subaccount\_id
6. **实施适当的日志记录**
   * 记录策略决策和重要事件
   * 使用适当的日志级别（info、warning、error）
7. **设置自定义参数**
   * 使用 `Parameters` 部分设置特定于策略的值
   * 记录预期参数

本指南应该为您使用框架创建和配置有效的交易策略提供坚实的基础。

### 自定义处理器

框架在将数据传递给您的策略之前通过专门的处理器处理更新。您可以创建自定义处理器以更好地控制数据处理。

#### 处理器基类

所有处理器都继承自 `UpdateHandler` 基类：

```python
class UpdateHandler(ABC):
    def __init__(self, logger, config, metrics):
        self.logger = logger
        self.config = config
        self.metrics = metrics

    async def process(self, **update_data) -> Dict:
        """Process update data and return processed result"""
        try:
            return await self._process_update(**update_data)
        except Exception as e:
            self.logger.error(f"Error processing update: {e}")
            return None

    @abstractmethod
    async def _process_update(self, **kwargs) -> Dict:
        """Process specific update type. To be implemented by subclasses."""
        pass
```

#### 创建自定义处理器

要创建自定义处理器：

1. 继承适当的处理器基类
2. 覆盖 `_process_update` 方法
3. 在策略的构造函数中注册您的处理器

```python
from src.core.handlers import OrderbookHandler

class MyCustomOrderbookHandler(OrderbookHandler):
    async def _process_update(self, **update_data):
        # Get basic processed data
        processed_data = await super()._process_update(**update_data)
        if not processed_data:
            return None

        # Add custom metrics
        market = update_data.get("market")
        bid, ask = market.orderbook.tob()

        if bid and ask:
            # Calculate custom metrics
            spread = ask - bid
            spread_pct = (ask - bid) / bid

            # Add to processed data
            processed_data["spread"] = spread
            processed_data["spread_pct"] = spread_pct

            # Record in metrics system
            self.metrics.add_custom_metric(f"{market.market_id}_spread", spread_pct)

        return processed_data
```

#### 注册自定义处理器

在策略构造函数中注册您的自定义处理器：

```python
def __init__(self, logger, config):
    super().__init__(logger, config)

    # Replace default handlers with custom implementations
    self.handlers[UpdateType.OnOrderbook] = MyCustomOrderbookHandler(
        self.logger, self.config, self.metrics
    )
    self.handlers[UpdateType.OnPosition] = MyCustomPositionHandler(
        self.logger, self.config, self.metrics
    )
```

#### 可用的处理器类型

框架提供了这些可以扩展的处理器类型：

| **Handler Class**  | **Update Type**            | **Purpose**                  |
| ------------------ | -------------------------- | ---------------------------- |
| `OrderbookHandler` | `UpdateType.OnOrderbook`   | Process orderbook updates    |
| `OracleHandler`    | `UpdateType.OnOraclePrice` | Process oracle price updates |
| `PositionHandler`  | `UpdateType.OnPosition`    | Process position updates     |
| `BalanceHandler`   | `UpdateType.OnBankBalance` | Process balance updates      |
| `DepositHandler`   | `UpdateType.OnDeposit`     | Process deposit updates      |
| `TradeHandler`     | `UpdateType.OnSpotTrade`   | Process trade execution      |
| `OrderHandler`     | `UpdateType.OnSpotOrder`   | Process order updates        |

## 关键数据结构

### 更新类型和相应的数据字段

框架处理您的策略可以响应的这些主要事件类型：

| **Update Type**                | **Description**            | **Key Data Fields**                                                                                                                                                            |
| ------------------------------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `UpdateType.OnOrderbook`       | Orderbook updates          | <p>- market_id: str<br>- market: Market object with updated orderbook<br>- sequence: int<br>- block_time: Optional[str]</p>                                                    |
| `UpdateType.OnOraclePrice`     | Oracle price updates       | <p>- market_id: str<br>- symbol: str<br>- price: Decimal<br>- timestamp: int</p>                                                                                               |
| `UpdateType.OnBankBalance`     | Account balance updates    | <p>- account_address: str<br>- account: Account object<br>- balance: BankBalance object</p>                                                                                    |
| `UpdateType.OnDeposit`         | Subaccount deposit updates | <p>- account_address: str<br>- subaccount_id: str<br>- account: Account object<br>- deposit: Deposit object</p>                                                                |
| `UpdateType.OnPosition`        | Position changes           | <p>- market_id: str<br>- account_address: str<br>- subaccount_id: str<br>- account: Account object<br>- position: Position object</p>                                          |
| `UpdateType.OnSpotTrade`       | Spot trade execution       | <p>- market_id: str<br>- subaccount_id: str<br>- account: Account object<br>- trade: Order object representing the trade<br>- order: Original Order object that was filled</p> |
| `UpdateType.OnDerivativeTrade` | Derivative trade execution | <p>- market_id: str<br>- subaccount_id: str<br>- account: Account object<br>- trade: Order object representing the trade<br>- order: Original Order object that was filled</p> |
| `UpdateType.OnSpotOrder`       | Spot order updates         | <p>- market_id: str<br>- subaccount_id: str<br>- account: Account object<br>- order: Order object</p>                                                                          |
| `UpdateType.OnDerivativeOrder` | Derivative order updates   | <p>- market_id: str<br>- subaccount_id: str<br>- account: Account object<br>- order: Order object</p>                                                                          |

### 策略结果

当您的策略决定采取行动时，返回一个 `StrategyResult` 对象，包含：

| **Field**        | **Description**                                               | **Content**                                                                                                                                                 |
| ---------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `orders`         | List of new orders to create                                  | `[Order(...), Order(...)]`                                                                                                                                  |
| `cancellations`  | List of orders to cancel                                      | `[{"market_id": "0x123...", "subaccount_id": "0x456...", "order_hash": "0x789..."}]`                                                                        |
| `margin_updates` | List of margin adjustments                                    | `[{"action": "increase", "market_id": "0x123...", "source_subaccount_id": "0x456...", "destination_subaccount_id": "0x456...", "amount": Decimal("50.0")}]` |
| `liquidations`   | List of positions to be liquidated due to insufficient margin | `[{"market_id": "0x123...", "subaccount_id": "0x456...", "executor_subaccount_id": "0x789...", "price": price, "quantity": quantity, "margin": margin}]`    |

### Market

| **Property**         | **Type**                                               | **Description**                          | **Note**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| -------------------- | ------------------------------------------------------ | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `market_id`          | `str`                                                  | Unique market identifier                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `market_type`        | `MarketType` object                                    | Market type (SPOT, DERIVATIVE or BINARY) | Required as of v0.5.1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `market`             | `BinaryOptionMarket \| DerivativeMarket \| SpotMarket` | Market object from `pybiyachain`         | <p>SpotMarket: <a href="https://api.biyachain.exchange/#chain-exchange-for-spot-spotmarkets">https://api.biyachain.exchange/#chain-exchange-for-spot-spotmarkets</a><br>DerivativeMarket: <a href="https://api.biyachain.exchange/#chain-exchange-for-derivatives-derivativemarkets">https://api.biyachain.exchange/#chain-exchange-for-derivatives-derivativemarkets</a><br>BinaryOptionMarket: <a href="https://api.biyachain.exchange/#chain-exchange-for-binary-options-binaryoptionsmarkets">https://api.biyachain.exchange/#chain-exchange-for-binary-options-binaryoptionsmarkets</a></p> |
| `orderbook`          | `Orderbook` object                                     | Current market orderbook                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `oracle_price`       | `Decimal`                                              | Current market oracle price              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `min_price_tick`     | `Decimal`                                              | Minimum price increment                  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `min_quantity_tick`  | `Decimal`                                              | Minimum quantity increment               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `base_oracle_price`  | `Decimal`                                              | Base token oracle price                  | Optional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `quote_oracle_price` | `Decimal`                                              | Quote token oracle price                 | Optional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `oracle_timestamp`   | `int`                                                  | Oracle price timestamp                   | Optional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `mark_price`         | `Decimal`                                              | Mark price for derivative                | Optional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

### Orderbook

| **Property** | **Type**             | **Description**                            | **Note**                                |
| ------------ | -------------------- | ------------------------------------------ | --------------------------------------- |
| `sequence`   | `str`                | Orderbook sequence number                  |                                         |
| `bids`       | `List[L2PriceLevel]` | List of bid price levels                   | `L2PriceLevel` : `price` and `quantity` |
| `asks`       | `List[L2PriceLevel]` | List of ask price levels                   | `L2PriceLevel` : `price` and `quantity` |
| `tob`        | `Tuple`              | Top of book (bid, ask) prices              |                                         |
| `is_health`  | `bool`               | Indicates if orderbook is in healthy state | `False` when sequence is 0              |

### Account

| **Property**      | **Type**                 | **Description**                    | **Note**                                |
| ----------------- | ------------------------ | ---------------------------------- | --------------------------------------- |
| `private_key`     | `PrivateKey`             | Biya Chain private key              | Not directly accessible                 |
| `public_key`      | `PublicKey`              | Corresponding public key           |                                         |
| `address`         | `Address`                | Account address object             | Contains sequence information           |
| `account_address` | `str`                    | Bech32 address string              | Format: "biya1..."                       |
| `bank_balances`   | `Dict[str, BankBalance]` | Token balances in account          | Key: denom                              |
| `balances`        | `Dict[str, Balance]`     | Alternative balance representation | Key: denom                              |
| `subaccounts`     | `Dict[str, SubAccount]`  | Subaccounts owned by this account  | Key: subaccount\_id                     |
| `sequence`        | `int`                    | Transaction sequence number        | Property that accesses address.sequence |

### BankBalance

| **Property** | **Type**  | **Description**    | **Note**                  |
| ------------ | --------- | ------------------ | ------------------------- |
| `denom`      | `str`     | Token denomination | e.g., "biya", "peggy0x..." |
| `amount`     | `Decimal` | Token amount       | Human-readable format     |

### Balance

| **Property** | **Type**  | **Description**    | **Note**                   |
| ------------ | --------- | ------------------ | -------------------------- |
| `denom`      | `str`     | Token denomination | e.g., "biya", "peggy0x..."  |
| `total`      | `Decimal` | Total balance      |                            |
| `available`  | `Decimal` | Available balance  | Total minus locked amounts |

### SubAccount

| **Property**        | **Type**                      | **Description**              | **Note**                           |
| ------------------- | ----------------------------- | ---------------------------- | ---------------------------------- |
| `subaccount_id`     | `str`                         | Unique subaccount identifier | Format: "0x..."                    |
| `portfolio`         | `Dict[str, Deposit]`          | Token deposits in subaccount | Key: denom                         |
| `positions`         | `Dict[str, Position]`         | Trading positions            | Key: market\_id                    |
| `open_bid_orders`   | `Dict[str, Dict[str, Order]]` | Open buy orders              | market\_id -> {order\_hash: Order} |
| `open_ask_orders`   | `Dict[str, Dict[str, Order]]` | Open sell orders             | market\_id -> {order\_hash: Order} |
| `traded_bid_orders` | `Dict[str, Dict[str, Order]]` | Filled buy orders            | market\_id -> {order\_hash: Order} |
| `traded_ask_orders` | `Dict[str, Dict[str, Order]]` | Filled sell orders           | market\_id -> {order\_hash: Order} |

### Deposit

| **Property**        | **Type**  | **Description**          | **Note**                       |
| ------------------- | --------- | ------------------------ | ------------------------------ |
| `denom`             | `str`     | Token denomination       | e.g., "biya", "peggy0x..."      |
| `total_balance`     | `Decimal` | Total deposit amount     |                                |
| `available_balance` | `Decimal` | Available deposit amount | Total minus margins and locked |

### Position

| **Property**               | **Type**  | **Description**              | **Note**   |
| -------------------------- | --------- | ---------------------------- | ---------- |
| `subaccount_id`            | `str`     | Owner subaccount ID          |            |
| `market_id`                | `str`     | Market identifier            |            |
| `quantity`                 | `Decimal` | Position size                |            |
| `entry_price`              | `Decimal` | Average entry price          |            |
| `margin`                   | `Decimal` | Total margin amount          |            |
| `cumulative_funding_entry` | `Decimal` | Cumulative funding at entry  |            |
| `is_long`                  | `bool`    | Long (true) or short (false) |            |
| `unrealized_pnl`           | `Decimal` | Unrealized profit/loss       | Default: 0 |
| `total_volume`             | `Decimal` | Total trading volume         | Default: 0 |
| `trades_count`             | `int`     | Number of trades             | Default: 0 |
| `mark_price`               | `Decimal` | Current market price         | Optional   |
| `liquidation_price`        | `Decimal` | Liquidation threshold        | Optional   |
| `margin_ratio`             | `Decimal` | Current margin ratio         | Optional   |

### Order

| **Property**     | **Type**      | **Description**             | **Note**                      |
| ---------------- | ------------- | --------------------------- | ----------------------------- |
| `market_id`      | `str`         | Market identifier           |                               |
| `subaccount_id`  | `str`         | Subaccount identifier       |                               |
| `order_side`     | `Side`        | Buy or sell                 | Side.BUY or Side.SELL         |
| `price`          | `Decimal`     | Order price                 |                               |
| `quantity`       | `Decimal`     | Order quantity              |                               |
| `order_hash`     | `str`         | Unique order identifier     | Optional, set by chain        |
| `fillable`       | `Decimal`     | Remaining unfilled quantity | Optional                      |
| `filled`         | `Decimal`     | Filled quantity             | Optional                      |
| `status`         | `OrderStatus` | Order status                | BOOKED, PARTIAL\_FILLED, etc. |
| `order_type`     | `str`         | Order type                  | Default: "LIMIT"              |
| `margin`         | `Decimal`     | Margin amount (derivatives) | Optional                      |
| `leverage`       | `Decimal`     | Leverage multiple           | Optional                      |
| `trigger_price`  | `Decimal`     | For conditional orders      | Optional                      |
| `market_type`    | `MarketType`  | SPOT, DERIVATIVE, BINARY    | Optional                      |
| `fee_recipient`  | `str`         | Fee recipient address       | Default: ""                   |
| `cid`            | `str`         | Client order ID             | Optional                      |
| `created_at`     | `datetime`    | Creation timestamp          | Optional                      |
| `updated_at`     | `datetime`    | Last update timestamp       | Optional                      |
| `position_delta` | `Dict`        | Position change data        | Optional for derivatives      |
| `payout`         | `Decimal`     | Expected payout             | Optional for derivatives      |
| `tx_hash`        | `str`         | Transaction hash            | Optional                      |
| `error_code`     | `str`         | Error code if failed        | Optional                      |
| `error_message`  | `str`         | Error details               | Optional                      |

### OrderStatus (Enum)

| **Value**        | **Description**           |
| ---------------- | ------------------------- |
| `BOOKED`         | Order accepted and active |
| `PARTIAL_FILLED` | Partially filled          |
| `FILLED`         | Completely filled         |
| `CANCELLED`      | Cancelled by user         |
| `EXPIRED`        | Expired (time-based)      |

### Side (Enum)

| **Value** | **Description** |
| --------- | --------------- |
| `BUY`     | Buy order       |
| `SELL`    | Sell order      |

### MarketType (Enum)

| **Value**    | **Description**       |
| ------------ | --------------------- |
| `SPOT`       | Spot market           |
| `DERIVATIVE` | Derivatives market    |
| `BINARY`     | Binary options market |

