# Wallets

Biya Chain defines its own custom `Account` type that uses Ethereum's ECDSA secp256k1 curve for keys. In simple words said, it means that Biya Chain's Account is native (compatible) with Ethereum accounts. This allows users to use Ethereum native wallets to interact with Biya Chain.

Biya Chain is built on top of the CosmosSDK. This means that (with some modifications, since Cosmos uses different curve for keys) users can also use Cosmos native wallets to interact with Biya Chain.

## Technical Explanation

Let's briefly explain how the accounts (wallets) work on Biya Chain and in crypto in general.

* Everything starts from a **SeedPhase** (or mnemonic). A **SeedPhrase** is a list of 12 or 24 common words in a particular order.
* From the **SeedPhase** you can have an **infinite** number of **PrivateKeys** derived using indexing (the first private key starts at index 0). This is why you can add multiple accounts on Metamask, Keplr, or any other popular wallet without generating a new **SeedPhase** _(the derivation itself is a bit complicated for this brief explanation so we are going to omit it for now)._
* After a **PrivateKey** has been derived from your **seed phase**, you can use this **PrivateKey** to derive your **PublicKey**. **One PrivateKey always corresponds to one PublicKey!**
* Once you have your P**ublicKey** you can derive your **PublicAddress**. These public addresses can be derived using different derivation schemes and representations (_base64_, _hex_, _bech32_, etc).

With the explanation above, we can understand that once you have your **PublicKey** you can derive both your Ethereum address (represented in a hex format, `0x...`) and your Biya Chain address (represented in a bech32 format, `biya1...`).

## Topics

| Topic                                                   | Description                                                     |
| ------------------------------------------------------- | --------------------------------------------------------------- |
| [Accounts on Biya Chain](accounts.md)             | Accounts/Wallets definition on Biya Chain                        |
| [Wallet Connections](connections.md)             | Connecting directly using Metamask or Keplr                     |
| [Wallet Strategy](strategy.md)            | Using the WalletStrategy to connect using different wallets     |
| [Offchain (Arbitrary) Data](offchain-data.md) | Signing and verifying data offchain using the ADR-036 by Cosmos |
