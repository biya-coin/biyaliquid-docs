<!--
order: 6
-->

# 钩子

`x/evm` 模块实现了一个 `EvmHooks` 接口，该接口外部扩展和自定义 `Tx` 处理逻辑。

这支持 EVM 合约通过以下方式调用原生 cosmos 模块：

1. 定义日志签名并从智能合约发出特定日志，
2. 在本机交易处理代码中识别这些日志，以及
3. 将它们转换为原生模块调用。

为此，接口包括一个 `PostTxProcessing` 钩子，该钩子在 `EvmKeeper` 中注册自定义 `Tx` 钩子。这些 `Tx` 钩子在 EVM 状态转换完成且不失败后处理。请注意，EVM 模块中没有实现默认钩子。

```go
type EvmHooks interface {
 // Must be called after tx is processed successfully, if return an error, the whole transaction is reverted.
 PostTxProcessing(ctx sdk.Context, msg core.Message, receipt *ethtypes.Receipt) error
}
```

## `PostTxProcessing`

`PostTxProcessing` 仅在 EVM 交易成功完成后调用，并将调用委托给底层钩子。如果未注册钩子，此函数将返回 `nil` 错误。

```go
func (k *Keeper) PostTxProcessing(ctx sdk.Context, msg core.Message, receipt *ethtypes.Receipt) error {
 if k.hooks == nil {
  return nil
 }
 return k.hooks.PostTxProcessing(k.Ctx(), msg, receipt)
}
```

它在与 EVM 交易相同的缓存上下文中执行，如果返回错误，整个 EVM 交易将被回滚，如果钩子实现者不想回滚交易，他们可以始终返回 `nil`。

钩子返回的错误被转换为 VM 错误 `failed to process native logs`，详细错误消息存储在返回值中。消息异步发送到原生模块，调用者无法捕获和恢复错误。

## 用例：在 Biya Chain 上调用原生 ERC20 模块

这是来自 Biya Chain [erc20 模块]() 的示例，展示了 `EVMHooks` 如何支持合约调用原生模块以将 ERC-20 代币转换为 Cosmos 原生代币。按照上述步骤。

您可以在智能合约中定义并发出 `Transfer` 日志签名，如下所示：

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);

function _transfer(address sender, address recipient, uint256 amount) internal virtual {
  require(sender != address(0), "ERC20: transfer from the zero address");
  require(recipient != address(0), "ERC20: transfer to the zero address");

  _beforeTokenTransfer(sender, recipient, amount);

  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
  _balances[recipient] = _balances[recipient].add(amount);
  emit Transfer(sender, recipient, amount);
}
```

应用程序将向 `EvmKeeper` 注册一个 `BankSendHook`。它识别以太坊交易 `Log` 并将其转换为对银行模块的 `SendCoinsFromAccountToAccount` 方法的调用：

```go

const ERC20EventTransfer = "Transfer"

// PostTxProcessing implements EvmHooks.PostTxProcessing
func (k Keeper) PostTxProcessing(
 ctx sdk.Context,
 msg core.Message,
 receipt *ethtypes.Receipt,
) error {
 params := h.k.GetParams(ctx)
 if !params.EnableErc20 || !params.EnableEVMHook {
  // no error is returned to allow for other post processing txs
  // to pass
  return nil
 }

 erc20 := contracts.ERC20BurnableContract.ABI

 for i, log := range receipt.Logs {
  if len(log.Topics) < 3 {
   continue
  }

  eventID := log.Topics[0] // event ID

  event, err := erc20.EventByID(eventID)
  if err != nil {
   // invalid event for ERC20
   continue
  }

  if event.Name != types.ERC20EventTransfer {
   h.k.Logger(ctx).Info("emitted event", "name", event.Name, "signature", event.Sig)
   continue
  }

  transferEvent, err := erc20.Unpack(event.Name, log.Data)
  if err != nil {
   h.k.Logger(ctx).Error("failed to unpack transfer event", "error", err.Error())
   continue
  }

  if len(transferEvent) == 0 {
   continue
  }

  tokens, ok := transferEvent[0].(*big.Int)
  // safety check and ignore if amount not positive
  if !ok || tokens == nil || tokens.Sign() != 1 {
   continue
  }

  // check that the contract is a registered token pair
  contractAddr := log.Address

  id := h.k.GetERC20Map(ctx, contractAddr)

  if len(id) == 0 {
   // no token is registered for the caller contract
   continue
  }

  pair, found := h.k.GetTokenPair(ctx, id)
  if !found {
   continue
  }

  // check that conversion for the pair is enabled
  if !pair.Enabled {
   // continue to allow transfers for the ERC20 in case the token pair is disabled
   h.k.Logger(ctx).Debug(
    "ERC20 token -> Cosmos coin conversion is disabled for pair",
    "coin", pair.Denom, "contract", pair.Erc20Address,
   )
   continue
  }

  // ignore as the burning always transfers to the zero address
  to := common.BytesToAddress(log.Topics[2].Bytes())
  if !bytes.Equal(to.Bytes(), types.ModuleAddress.Bytes()) {
   continue
  }

  // check that the event is Burn from the ERC20Burnable interface
  // NOTE: assume that if they are burning the token that has been registered as a pair, they want to mint a Cosmos coin

  // create the corresponding sdk.Coin that is paired with ERC20
  coins := sdk.Coins{{Denom: pair.Denom, Amount: sdk.NewIntFromBigInt(tokens)}}

  // Mint the coin only if ERC20 is external
  switch pair.ContractOwner {
  case types.OWNER_MODULE:
   _, err = h.k.CallEVM(ctx, erc20, types.ModuleAddress, contractAddr, true, "burn", tokens)
  case types.OWNER_EXTERNAL:
   err = h.k.bankKeeper.MintCoins(ctx, types.ModuleName, coins)
  default:
   err = types.ErrUndefinedOwner
  }

  if err != nil {
   h.k.Logger(ctx).Debug(
    "failed to process EVM hook for ER20 -> coin conversion",
    "coin", pair.Denom, "contract", pair.Erc20Address, "error", err.Error(),
   )
   continue
  }

  // Only need last 20 bytes from log.topics
  from := common.BytesToAddress(log.Topics[1].Bytes())
  recipient := sdk.AccAddress(from.Bytes())

  // transfer the tokens from ModuleAccount to sender address
  if err := h.k.bankKeeper.SendCoinsFromModuleToAccount(ctx, types.ModuleName, recipient, coins); err != nil {
   h.k.Logger(ctx).Debug(
    "failed to process EVM hook for ER20 -> coin conversion",
    "tx-hash", receipt.TxHash.Hex(), "log-idx", i,
    "coin", pair.Denom, "contract", pair.Erc20Address, "error", err.Error(),
   )
   continue
  }
 }

 return nil
```

最后，在 `app.go` 中注册钩子：

```go
app.EvmKeeper = app.EvmKeeper.SetHooks(app.Erc20Keeper)
```
