# Building dApps

Biyachain is a Layer-1 blockchain built for finance. Biyachain offers developers out-of-the-box primitives for building decentralized financial applications in addition to an open and permissionless smart contracts layer providing advanced capabilities in building robust Web3 applications.

Biyachain is natively interoperable with several well-known blockchain networks, including Ethereum, Solana, and all IBC-enabled cosmos chains like CosmosHub, Osmosis, etc. The interoperability not only allows Biyachain to enable users to bridge assets from multiple chains but also allows for transferring arbitrary data - like oracle prices, etc.

Within this section we are going to explore configuring different UI frameworks to work with the `@biya-coin` packages so you can start building decentralized applications on top of Biyachain. We are also going to showcase example (simple) dApps built on top of Biyachain.

For security reasons, we recommend using the stable package versions of NPM packages.

**Stable Package Version**

![](https://img.shields.io/npm/v/%40biya-coin/sdk-ts/latest?label=%40biya-coin%2Fsdk-ts) ![](https://img.shields.io/npm/v/%40biya-coin/wallet-ts/latest?label=%40biya-coin%2Fwallet-ts) ![](https://img.shields.io/npm/v/%40biya-coin/networks/latest?label=%40biya-coin%2Fnetworks) ![](https://img.shields.io/npm/v/%40biya-coin/ts-types/latest?label=%40biya-coin%2Fts-types) ![](https://img.shields.io/npm/v/%40biya-coin/utils/latest?label=%40biya-coin%2Futils)

**Latest Package Versions:**

![](https://img.shields.io/npm/v/%40biya-coin/sdk-ts/next?label=%40biya-coin%2Fsdk-ts) ![](https://img.shields.io/npm/v/%40biya-coin/wallet-ts/next?label=%40biya-coin%2Fwallet-ts) ![](https://img.shields.io/npm/v/%40biya-coin/networks/next?label=%40biya-coin%2Fnetworks) ![](https://img.shields.io/npm/v/%40biya-coin/ts-types/next?label=%40biya-coin%2Fts-types) ![](https://img.shields.io/npm/v/%40biya-coin/utils/next?label=%40biya-coin%2Futils)

{% hint style="info" %}
The latest versions are published using the `next` tag. For stable versions use the `latest` tag or check npm registry for the latest stable version.
{% endhint %}

{% hint style="info" %}
If you are looking for how to build a dApp on Biyachain EVM,
you should check out the guides in [your first EVM dApp](../../developers-evm/dapps/README.md).
{% endhint %}

### Create Biyachain dApp CLI tool

The simplest way to start your journey on Biyachain is using our CLI tool. To do this, simply write this command and follow the instructions in your terminal!

```bash
$ npx @biya-coin/create-biyachain-app
```

### Configuration

| Topic                                     | Description                 |
| ----------------------------------------- | --------------------------- |
| [Configuring Nuxt](configure-nuxt.md)     | Configuring Nuxt 3.x + Vite |
| [Configuring React](configure-react.md)   | Configuring React 18 + Vite |

### dApps

| Topic                                      | Description                                              |
| ------------------------------------------ | -------------------------------------------------------- |
| [DEX](example-dex.md)                              | Building a decentralized exchange on top of Biyachain    |
| [Simple Smart Contract](example-smart-contract.md) | Building a simple smart contract app on top of Biyachain |
| [Webpack](example-webpack.md) | Simple HTML example with Webpack and Biyachain |

<!--
| [Bridge](example-bridge.md)                        | Building a simple bridge between Biyachain and Ethereum  |
-->

