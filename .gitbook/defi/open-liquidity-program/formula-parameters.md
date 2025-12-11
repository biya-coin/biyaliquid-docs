---
description: OLP 公式参数值
---

# 公式参数

<table><thead><tr><th width="166.11067708333334" align="center">参数</th><th align="center">定义</th><th align="center">值（可能更改）</th></tr></thead><tbody><tr><td align="center"><span class="math">a</span></td><td align="center"><a href="scoring.md#liquidity-score">流动性分数</a> 指数</td><td align="center">0.4</td></tr><tr><td align="center"><span class="math">b</span></td><td align="center"><a href="scoring.md#uptime-score">正常运行时间分数</a> 指数</td><td align="center">3</td></tr><tr><td align="center"><span class="math">c</span></td><td align="center"><a href="scoring.md#volume">交易量</a> 指数</td><td align="center">0.8</td></tr><tr><td align="center"><span class="math">MinDepth</span></td><td align="center">为<a href="scoring.md#total-score">总分</a>生成分数所需的最小名义订单大小</td><td align="center">$4000</td></tr><tr><td align="center"><span class="math">MaxSpread</span></td><td align="center">订单中相对于中间价的最大允许价差，用于为<a href="scoring.md#total-score">总分</a>生成分数</td><td align="center">50 <a data-footnote-ref href="#user-content-fn-1">基点</a>（BTC/ETH 永续市场），100 基点（其他合格市场）</td></tr></tbody></table>



[^1]: 基点（1 基点 = 1% 的 1%，或 0.0001）
