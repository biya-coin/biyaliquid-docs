# BeginBlock

在每个BeginBlock时，它会检查是否到了支付间隔时间，如果到了，它会为所有的feed处理支付。

**步骤**

* 确保是支付间隔的BeginBlock 。
* 在遍历所有feed配置, 处理奖励支付。
