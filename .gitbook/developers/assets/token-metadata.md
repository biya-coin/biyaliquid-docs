# Token Metadata

Assets on Biya Chain are represented as denoms. Denoms (and the amounts) are not human readable and this is why we need to have a way to "attach" token metadata information for a particular denom.

Let's recap the types of denoms we have in the Getting Started section:

* **Native denoms** - there is only one denom of this type, the `biya` denom which represented the native coin of Biya Chain,
* **Peggy denoms** - these denoms represent assets bridged over from Ethereum to Biya Chain using the Peggy bridge. They have the following format `peggy{ERC20_CONTRACT_ADDRESS}`
* **IBC denoms** - these denoms represent assets bridged over from other Cosmos chains through IBC. They have the following format `ibc/{hash}`.
* **Insurance Fund Denoms** - these denoms represent token shares of the insurance funds created on Biya Chain. The have the following format `share{id}`
* **Factory Denoms** - these denoms represent a CW20 token from Cosmwasm on the Biya Chain native bank module. They have the following format `factory/{CW20_ADAPTER_CONTRACT}/{CW20_CONTRACT_ADDRESS}` where the `CW20_ADAPTER_CONTRACT` is the adapter contract address that converts CW20 and the native Bank module.

We maintain our token metadata list off-chain for faster access to the[ biyachain-lists](https://github.com/biya-coin/biyachain-lists/tree/master/tokens) repository.

## Token Verification

Verifying your token's metadata can be done in a couple of ways. Here are the verification levels and what they mean:

* **Verified** -> Your asset metadata has been **submitted and verified** to the `@biya-coin/token-metadata` package. You can find a tutorial on how to add your token's metadata to the package [here](https://github.com/biya-coin/biyachain-lists/blob/master/CONTRIBUTING.md).
* **Internal** -> Your asset's metadata has been verified on-chain using the `MsgSetDenomMetadata` message, as explained [here](../../developers-native/examples/token-factory.md#msgsetdenommetadata).
* **External** -> Your asset's metadata has been verified on some external source like from Ethereum's contract details, etc.
* **Unverified** -> Your asset's metadata has not been provided anywhere.
