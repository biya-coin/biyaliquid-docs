# Ethereum Bridge

The Biya Chain Ethereum bridge enables the Biya Chain Chain to support a trustless, on-chain bidirectional token bridge. In this system, holders of ERC-20 tokens on Ethereum can instantaneously convert their ERC-20 tokens to Cosmos-native coins on the Biya Chain Chain and vice-versa.

The Biya Chain Peggy bridge consists of three main components:

1. Peggy Contract on Ethereum
2. Peggo Orchestrator
3. Peggy Module on the Biya Chain Chain

## Peggy Contract

The function of the Peggy contract is to facilitate efficient, bidirectional cross-chain transfers of ERC-20 tokens from Ethereum to the Biya Chain Chain. Unlike other token bridge setups, the Biya Chain Peggy bridge is a decentralized, non-custodial bridge operated solely by the validators on Biya Chain. The bridge is secured by the proof of stake security of the Biya Chain Chain, as deposits and withdrawals are processed in accordance with attestations made by at least two-thirds of the validators based on consensus staking power.

## Peggo Orchestrator

The orchestrator is an off-chain relayer that every Biya Chain Chain validator operates which serves the function of transmitting ERC-20 token transfer data from Ethereum to the Biya Chain Chain.

## Peggy Module

On a basic level, the Peggy module mints new tokens on the Biya Chain Chain upon an ERC-20 deposit from Ethereum and burns tokens upon withdrawing a token from the Biya Chain Chain back to Ethereum. The Peggy module also manages the economic incentives to ensure that validators act honestly and efficiently, through a variety of mechanisms including slashing penalties, native token rewards, and withdrawal fees.

## From Ethereum to Biya Chain

To transfer from Ethereum to Biya Chain you have to make a Web3 Transaction and interact with the Peggy contract on Ethereum. There are two steps required to make a transfer:

1. As we are basically locking our ERC20 assets on the Peggy Contract which lives on Ethereum, we need to set an allowance for the assets we are transferring to the Peggy Contract. We have an [example](https://github.com/biya-coin/biyachain-ts/blob/1fbc2577b9278a62d1676041d6e502e12f5880a8/deprecated/sdk-ui-ts/src/services/web3/Web3Composer.ts#L41-L91) here about how to make this transaction and you can use any web3 provider to sign and broadcast the transaction to the Ethereum Network.
2. After the allowance is set, we need to call the `sendToBiyachain` function on the Peggy Contract with the desired amount and asset that we want to transfer to the Biya Chain Chain, an example can be found [here](https://github.com/biya-coin/biyachain-ts/blob/1fbc2577b9278a62d1676041d6e502e12f5880a8/deprecated/sdk-ui-ts/src/services/web3/Web3Composer.ts#L93-L156). Once we get the transaction, we can use a web3 provider to sign and broadcast the transaction to the Ethereum Network. Once the transaction is confirmed, it’ll take a couple of minutes for the assets to show on the Biya Chain Chain.

Couple of notes about the examples above:

- The destination address (if you want to build the transaction yourself) is in the following format

```ts
"0x000000000000000000000000{ETHEREUM_ADDRESS_HERE_WITHOUT_0X_PREFIX}";
// example
"0x000000000000000000000000e28b3b32b6c345a34ff64674606124dd5aceca30";
```

where the Ethereum address is the corresponding Ethereum address of the destination Biya Chain address.

- `const web3 = walletStrategy.getWeb3()` `walletStrategy` is an abstraction that we’ve built which supports a lot of wallets which can be used to sign and broadcast transactions (both on Ethereum and on the Biya Chain Chain), more details can be found in the documentation of the npm package [@biya-coin/wallet-ts](https://github.com/biya-coin/biyachain-ts/blob/master/packages/wallet-ts). Obviously, this is just an example and you can use the web3 package directly, or any web3 provider to handle the transaction.

```ts
import { PeggyContract } from "@biya-coin/contracts";

const contract = new PeggyContract({
  ethereumChainId,
  address: peggyContractAddress,
  web3: web3 as any,
});
```

- The snippet below instantiates a PeggyContract instance which can easily `estimateGas` and `sendTransaction` using the `web3` we provide to the contract’s constructor. Its implementation can be found [here](https://github.com/biya-coin/biyachain-ts/blob/master/packages/contracts/src/contracts/Peggy.ts). Obviously, this is just an example and you can use the web3 package directly + the ABI of the contract to instantiate the contract, and then handle the logic of signing and broadcasting the transaction using some web3 provider.

## From Biya Chain to Ethereum

Now that you have the ERC20 version of BIYA transferred over to Biya Chain, the native `biya` denom on the Biya Chain Chain is minted and it is the canonical version of the BIYA token. To withdraw `biya` from Biya Chain to Ethereum we have to prepare, sign and then broadcast a native Cosmos transaction on the Biya Chain Chain.

If you are not familiar with how Transactions (and Messages) work on Cosmos you can find more information here. The Message we need to pack into a transaction to instruct Biya Chain to withdraw funds from Biya Chain to Ethereum is `MsgSendToEth`.

When `MsgSendToEth` is called on the chain, some of the validators will pick up the transaction, batch multiple `MsgSendToEth` requests into one and: burn the assets being withdrawn on Biya Chain, unlock these funds on the Peggy Smart Contract on Ethereum and send them to the respective address.

There is a bridgeFee included in these transactions to incentivize Validators to pick up and process your withdrawal requests faster. The bridgeFee is in the asset the user wants to withdraw to Ethereum (if you withdraw BIYA you have to pay the bridgeFee in BIYA as well).

Here is an example implementation that prepares the transaction, uses a privateKey to sign it and finally, broadcasts it to Biya Chain:

```ts
import { getNetworkInfo, Network } from "@biya-coin/networks";
import {
  TxClient,
  PrivateKey,
  TxRestClient,
  MsgSendToEth,
  getDefaultStdFee,
  ChainRestAuthApi,
  createTransaction,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";

/** MsgSendToEth Example */
(async () => {
  const network = getNetworkInfo(Network.Mainnet); // Gets the rpc/lcd endpoints
  const privateKeyHash =
    "f9db9bf330e23cb7839039e944adef6e9df447b90b503d5b4464c90bea9022f3";
  const privateKey = PrivateKey.fromPrivateKey(privateKeyHash);
  const biyachainAddress = privateKey.toBech32();
  const ethAddress = privateKey.toHex();
  const publicKey = privateKey.toPublicKey().toBase64();

  /** Account Details **/
  const accountDetails = await new ChainRestAuthApi(network.rest).fetchAccount(
    biyachainAddress
  );

  /** Prepare the Message */
  const amount = {
    amount: toChainFormat(0.01).toFixed(),
    denom: "biya",
  };
  const bridgeFee = {
    amount: toChainFormat(0.01).toFixed(),
    denom: "biya",
  };

  const msg = MsgSendToEth.fromJSON({
    amount,
    bridgeFee,
    biyachainAddress,
    address: ethAddress,
  });

  /** Prepare the Transaction **/
  const { signBytes, txRaw } = createTransaction({
    message: msg,
    pubKey: publicKey,
    fee: getDefaultStdFee(),
    sequence: parseInt(accountDetails.account.base_account.sequence, 10),
    accountNumber: parseInt(
      accountDetails.account.base_account.account_number,
      10
    ),
    chainId: network.chainId,
  });

  /** Sign transaction */
  const signature = await privateKey.sign(Buffer.from(signBytes));

  /** Append Signatures */
  txRaw.signatures = [signature];

  /** Calculate hash of the transaction */
  console.log(`Transaction Hash: ${TxClient.hash(txRaw)}`);

  const txService = new TxRestClient(network.rest);

  /** Simulate transaction */
  const simulationResponse = await txService.simulate(txRaw);

  console.log(
    `Transaction simulation response: ${JSON.stringify(
      simulationResponse.gasInfo
    )}`
  );

  /** Broadcast transaction */
  const txResponse = await txService.broadcast(txRaw);

  if (txResponse.code !== 0) {
    console.log(`Transaction failed: ${txResponse.rawLog}`);
  } else {
    console.log(
      `Broadcasted transaction hash: ${JSON.stringify(txResponse.txhash)}`
    );
  }
})();
```
