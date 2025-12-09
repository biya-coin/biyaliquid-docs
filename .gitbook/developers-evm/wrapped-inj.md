# Wrapped BIYA (wBIYA)

## What is a wrapped cryptocurrency?

On Biyaliquid, BIYA is the cryptocurrency, which is what is used to pay transaction fees on the network.

However, some dApps (including DEXes), only accept ERC20 tokens in their interfaces, and thus BIYA does **not** work with them.

The solution is to create an ERC20 token which wraps BIYA, called "wrapped BIYA".
Its token symbol is **wBIYA**.
Thus any dApp that accepts ERC20 tokens accepts wBIYA.

The mechanism with which the wBIYA token works is straightforward:

- Mint: Increase the total supply whenever depositing BIYA into it.
- Burn: Decrease the total supply whenever withdrawing BIYA from it.

You may think of wBIYA as an ERC20 token that is 1-to-1 collateralised with BIYA, and therefore be treated as equal value but with a different technical interface.

## Is wBIYA the same as wETH?

For those of you familiar with Ethereum,
you may be thinking that this sounds the same as wrapper Ether (wETH).
You are right, so far wBIYA behaves in the same way as wETH.

However, note that the Biyaliquid network is designed with a MultiVM technical architecture.
This means that if wBIYA were to be implemented using a *standard* ERC20 implementation,
as wETH does, wBIYA would **not** be accessible when interacting with
the the non-EVM parts of the Biyaliquid network (e.g. Cosmos transactions).

This is precisely the type of limitation that Biyaliquid's
[MultiVM Token Standard (MTS)](./multivm-token-standard.md)
was designed for.

Specifically, note
[this line](https://github.com/biya-coin/solidity-contracts/blob/b152129a/src/WBIYA9.sol#L9C10-L9C15):

```solidity
contract WBIYA9 is BankERC20, IWBIYA9 {
```

Instead of storing balances as `uint256` values within the smart contract,
as is typical of ERC20 implementations,
the wBIYA smart contract uses the `Bank` precompile.
The magic happens in the
[`_update` function of `BankERC20`](https://github.com/biya-coin/solidity-contracts/blob/b152129a/src/BankERC20.sol#L50-L81),
where `mint`, `burn`, or `transfer` functions in the `Bank` module are invoked,
via its [EVM precompile](./bank-precompile.md "EVM precompile for Biyaliquid's native Bank module").

As those balances are stored/ retrieved from the `Bank` precompile,
they are accessible from elsewhere within Biyaliquid's MultiVM architecture.
For example, using the Cosmos SDK you can query the wBIYA balances,
even after updating them through EVM transactions;
and vice versa.
We refer to this as "native chain balances".

Check out a [full demo of wBIYA](https://github.com/biya-coin/solidity-contracts/tree/master/demos/wbiya9) in action.

## How to use wBIYA programmatically

- Address on Biyaliquid Mainnet: `0x0000000088827d2d103ee2d9A6b781773AE03FfB`
- Address on Biyaliquid Testnet: `0x0000000088827d2d103ee2d9A6b781773AE03FfB`

To convert BIYA to wBIYA, invoke the `deposit` function on this smart contract:

- The function signature is: `deposit() public payable`
- Note that you do not need to specify the amount as a parameter,
  instead set the `value` on the transactions, and `payable` will pick it up as `msg.value`.

To convert wBIYA to BIYA, invoke the `withdraw` function on this smart contract:

- The function signature is: `withdraw(uint256 wad) public`
- Set the amount of BIYA you intend to received as the `wad` parameter.

All other functions, e.g. transfers, are the same as standard ERC20.

## How to use wBIYA via the network explorer

- Explorer URL for Biyaliquid Mainnet: [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://blockscout.biyaliquid.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB?tab=contract)
- Explorer URL for Biyaliquid Testnet: [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://testnet.blockscout.biyaliquid.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB?tab=contract)

To convert BIYA to wBIYA, invoke the `deposit` function on this smart contract:

- Navigate to the "Contract" tab, then the "Read/Write contract" sub tab in the explorer page for the wBIYA token.
- Find the `deposit()` function, and expand it by clicking on the `>` symbol
- Fill in the field "Send native BIYA (uint256)" with the amount of BIYA you wish to convert
  - Note that this number is automatically multiplied by `10^18`, you do not need to perform that conversion manually
- Press the "Write" button
- In your wallet, confirm the transaction to sign and submit it.
- Your wallet should reflect an BIYA decrease and a wBIYA increase by the amount you selected.
  - Note that the BIYA decrease will be marginally more, because it is used to pay for transaction fees.

To convert wBIYA to BIYA, invoke the `withdraw` function on this smart contract:

- Navigate to the "Contract" tab, then the "Read/Write contract" sub tab in the explorer page for the wBIYA token.
- Find the `withdraw()` function, and expand it by clicking on the `>` symbol
- Fill in the field "wad (uint256)" with the amount of wBIYA you wish to convert
  - Note that this number is automatically multiplied by `10^18`, you do not need to perform that conversion manually
- Press the "Write" button
- In your wallet, confirm the transaction to sign and submit it.
- Your wallet should reflect an BIYA increase and a wBIYA decrease by the amount you selected.
  - Note that the BIYA increase will be marginally less, because it is used to pay for transaction fees.

# How to use wBIYA via Biyaliquid Do

- Visit [Biyaliquid Do](https://do.biyaliquid.network/)
- Press the "Connect" button in the top right corner
- Select your wallet
- In your wallet select "Allow" to allow it to connect ot the Biyaliquid Do dApp.
- You should now see your wallet address apear in the top right corner (where the "Connect" button was previously)
- In the nav bar at the top, select "EVM"
- In the drop-down menu select "Wrap/Unwrap"
- To convert BIYA to wBIYA
  - Press the "Wrap" tab at the top
  - In the "Amount" field, type your desired amount for conversion
  - Press the "Wrap" button at the bottom
  - When the transaction has completed, check your BIYA and wBIYA balances in your wallet
- To convert wBIYA to BIYA
  - Press the "Unwrap" tab at the top
  - In the "Amount" field, type your desired amount for conversion
  - Press the "Unwrap" button at the bottom
  - When the transaction has completed, check your BIYA and wBIYA balances in your wallet
