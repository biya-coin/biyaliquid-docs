# 入门指南

Biya Chain Trader 内置了"简单策略"，以帮助快速原型设计并熟悉代码库。

**它的功能：**

* 监控 BIYA、BTC、ETH 的订单簿
* 在市场价格略低处下买单
* 在市场价格略高处下卖单
* 维持价差以获得盈利
* 遵守持仓限制以进行风险控制

**最适合：**在熟悉 Biya Chain Trader 的同时进行可预测和稳定的交易。**不建议用于生产环境。**

**示例日志：**

```
[INFO] Placing BUY order: 0.1 BIYA at $3.45 (spread: 0.5%)
[INFO] Placing SELL order: 0.1 BIYA at $3.47 (spread: 0.5%)
[INFO] Order filled: BUY 0.1 BIYA at $3.45
```

## 自定义您的策略

### 订单大小

```yaml
OrderSize: 0.5
MaxPosition: 2.0
```

### 更多市场

```yaml
MarketTickers:
  - BIYA/USDT PERP
  - BTC/USDT PERP
  - ETH/USDT PERP
  - APT/USDT PERP
  - AVAX/USDT PERP
  - SOL/USDT PERP
```

### 价差

```yaml
SpreadThreshold: 0.01   # 保守
SpreadThreshold: 0.002  # 激进
```

## 常见配置

### 保守做市商

```yaml
OrderSize: 0.05
MaxPosition: 0.5
SpreadThreshold: 0.01
```

### 激进做市商

```yaml
OrderSize: 0.5
MaxPosition: 5.0
SpreadThreshold: 0.002
```

### 多市场策略

```yaml
MarketTickers:
  - BIYA/USDT PERP
  - BTC/USDT PERP
  - ETH/USDT PERP
  - APT/USDT PERP
  - AVAX/USDT PERP
  - SOL/USDT PERP
  - TON/USDT PERP
  - ATOM/USDT PERP
```

## 监控您的机器人

```bash
tail -f logs/my_bot.log
grep "Order filled" logs/my_bot.log
grep "ERROR" logs/my_bot.log
```

### 关键消息

* ✅ 订单成功下达
* 💰 订单已成交
* ⚠️ 达到持仓限制
* ❌ 余额不足

### 性能指标

* 总盈亏
* 胜率
* 成交率
* 平均价差

## 风险管理

* 设置持仓限制（`MaxPosition`）
* 监控持仓并在需要时手动止损
* 保持足够的 USDT 用于保证金、费用和缓冲

## 故障排除

**未找到私钥**

```bash
echo $MyBot_GRANTER_biyachain_PRIVATE_KEY
```

* **余额不足** → 添加 USDT / 减少 `OrderSize`
* **未找到市场** → 仔细检查代码/ID
* **机器人停止工作**

```bash
grep "ERROR" logs/my_bot.log | tail -10
python main.py MyBot config.yaml --log_path logs/my_bot.log --network mainnet
```

## 高级功能

* 通过 `AccountAddresses` 使用**多个账户**
* **自定义订单类型**（限价、市价、仅减仓）
* 使用 Redis/Valkey 的**外部信号**

## 下一步

了解如何为 Biya Chain Trader 开发您自己的[自定义策略](biyachain-trader-strategy-development-guide.md)。
