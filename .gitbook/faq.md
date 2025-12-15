# Biyachain FAQ

## Fundamentals

Q: What account address types are supported in Biyachain?

A: There are 2 address types supported:
- Bech32 (`biya...`), which is primarily used when interacting via Cosmos wallets/ tools
- Hexadecimal (`0x...`), which is primarily used when interacting via EVM wallets/ tools

----

Q: Is there a way to find which Biyachain Cosmos address is mapped to which Biyachain EVM address?

A: The mapping between these address types is done through a mathematical operation,
which is 1 to 1, and bidirectional.
- Live example: [Biyachain Testnet Faucet](https://testnet.faucet.biyachain.network/)
- Docs: [TS code examples](https://docs.biyachain.network/developers/convert-addresses)

----

## Infrastructure

Q: When maintaining a private node:

- Should we store 2.5 Ti archival data (event provider)?
- Can we skip that part and make indexer work?

A: Event provider can be pruned. One can use the public event provider endpoint for the initial sync.  Then resort to local deployment, but only from the latest height. Therefore, yes can be skipped.

----

## EVM

Q: Does Biyachain have a deployment of the [`multicall3`](https://www.multicall3.com/) smart contract? <!-- tachida2k -->

A: Yes.

- Biyachain Mainnet `multicall3`: [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11?tab=contract)
- Biyachain Testnet `multicall3`: [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://testnet.blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11?tab=contract)

----
