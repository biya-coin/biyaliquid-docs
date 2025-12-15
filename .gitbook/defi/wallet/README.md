# Wallet

The Biya Chain Wallet allows you to monitor your assets on Biya Chain. Assets can be native tokens on Biya Chain, as well as bridged assets from Ethereum, Solana, Polygon and various IBC-enabled chains. See [Biya Chain Hub Staking Walkthrough](https://biyachain.com/blog/biyachain-hub/)

There are a variety of different wallets that are supported on Biya Chain. Users can choose to submit transactions on Biya Chain using either their Ethereum or Cosmos-native wallets.

### Overview

Biya Chain's `Account` type uses Ethereum's ECDSA secp256k1 curve for keys. Simply put, Biya Chain's Account is native (compatible) with Ethereum accounts, allowing Ethereum-native wallets, such as MetaMask, to interact with Biya Chain. Popular Cosmos wallets like Keplr and Leap have also integrated with Biya Chain.

#### Ethereum-Based Wallets

As explained above, Ethereum-based wallets can be used to interact with Biya Chain. Right now, the most popular Ethereum-based wallets are supported on Biya Chain. These include:

1. [MetaMask](https://metamask.io/)
2. [Ledger](https://www.ledger.com/)
3. [Trezor](https://trezor.io/)
4. [Torus](https://tor.us/index.html)

The process of signing transactions on Biya Chain using an Ethereum-native wallet consists of:

1. Converting the transaction into EIP712 TypedData,
2. Signing the EIP712 TypedData using an Ethereum-native wallet,
3. Packing the transaction into a native Cosmos transaction (including the signature), and broadcasting the transaction to the chain.

This process is abstracted away from the end-user. If you've previously used an Ethereum-native wallet, the user experience will be the same.

#### Cosmos-Based Wallets

Biya Chain supports the leading wallets compatible with Cosmos and IBC, including:

1. [Cosmostation](https://cosmostation.io/)
2. [Keplr](https://www.keplr.app/)
3. [Leap](https://www.leapwallet.io/)

#### CEX-Based Wallets

There are also several wallets developed by centralized exchanges (CEXs) that now support Biya Chain. If you are an active user of these CEXs, using their wallets can provide a more seamless web3 experience. Currently, CEX-based wallets that support Biya Chain are:

1. [Bitget Wallet](https://web3.bitget.com/en/)
2. [OKX Wallet](https://www.okx.com/web3)
