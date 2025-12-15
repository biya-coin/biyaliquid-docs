# Using biyachaind

The following page explains what one can do via `biyachaind`, the command-line interface that connects to Biya Chain. You can use `biyachaind` to interact with the Biya Chain blockchain by uploading smart contracts, querying data, managing staking activities, working with governance proposals, and more.

## Prerequisites

### Ensuring biyachaind is installed

See [Install biyachaind](./install.md) for more information. If you have installed `biyachaind` successfully, you should be able to run the following command:

```bash
biyachaind version
```

Please adjust your command to use the home dir properly.

```bash
biyachaind keys list --home ~/.biyachain
```

### Using Dockerized CLI

In case when running from Docker, you have to mount the home dir to the container.

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

Adding a key using Dockerized CLI is straightforward.

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys add my_key --home /root/.biyachain
```

There's a breakdown of that command:

* docker runs the image `biya-coin/biyachain-core:v1.14.1`
* `biyachaind` is the command to run the CLI from within the container
* `keys add` is the command to add a key
* `my_key` is the name of the key
* `--home /root/.biyachain` is the home directory for CLI inside the container
* `-v ~/.biyachain:/root/.biyachain` simply mounts the host `~/.biyachain` dir to the container's `/root/.biyachain` dir.

It will create a key pair and save it to the container's `/root/.biyachain/keyring-file` dir, which is the same as your host `~/.biyachain/keyring-file` dir.

You can list all the keys by running:

```bash
docker run -it --rm -v ~/.biyachain:/root/.biyachain biya-coin/biyachain-core:v1.14.1 biyachaind keys list --home /root/.biyachain
```

### Using the RPC endpoint

Before you can access the Biya Chain blockchain, you need to have a node running. You can either run your own full node or connect to someone else’s.

To query the state and send transactions, you must connect to a node, which is the access point to the entire network of peer connections. You can either run your own full node or connect to someone else’s.

[Running own node](../../infra/join-a-network.md) is for advanced users only. For most users, it is recommended to connect to a public node.

To set the RPC endpoint, you can use the following command:

```bash
biyachaind config set client node https://sentry.tm.biyachain.network:443
biyachaind config set client chain-id biyachain-1
```

{% hint style="info" %}
For testnet only, you can use: `https://k8s.testnet.tm.biyachain.network:443` (chain-id `biyachain-888`)
{% endhint %}

Now try to query the state:

```bash
biyachaind q bank balances biya1yu75ch9u6twffwp94gdtf4sa7hqm6n7egsu09s

balances:
- amount: "28748617927330656"
  denom: biya
```

### General help

For more general information about `biyachaind`, run:

```bash
biyachaind --help
```

For more information about a specific `biyachaind` command, append the `-h` or `--help` flag after the command. For example:

```bash
biyachaind query --help.
```

### Configuring `biyachaind` client

To configure more options of `biyachaind`, edit the `config.toml` file in the `~/.biyachain/config/` directory. Keyring file is located in `~/.biyachain/keyring-file` directory when keyring-backend is set to `file`. It's possible to set keyring-backend to `test` or `os` as well. In case for the test, it will be also stored as file `~/.biyachain/keyring-test` but not password-protected.

All options in the file can be set using the CLI: `biyachaind config set client <option> <value>`.

## Generate, Sign, and Broadcast a Transaction

Running the following command sends BIYA tokens from the sender's account to the recipient's account. `1000biya` is the amount of BIYA tokens to send, where `1 BIYA = 10^18 biya`, so `1000biya` is a really small amount.

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET
```

The following steps are performed:

* Generates a transaction with one `Msg` (`x/bank`'s `MsgSend`), and print the generated transaction to the console.
* Ask the user for confirmation to send the transaction from the `$MY_WALLET` account.
* Fetch `$MY_WALLET` from the keyring. This is possible because we have set up the CLI's keyring in a previous step.
* Sign the generated transaction with the keyring's account.
* Broadcast the signed transaction to the network. This is possible because the CLI connects to the public Biya Chain node's RPC endpoint.

The CLI bundles all the necessary steps into a simple-to-use user experience. However, it is possible to run all the steps individually as well.

### (Only) Generating a Transaction

Generating a transaction can simply be done by appending the `--generate-only` flag on any `tx` command, e.g.,

```bash
biyachaind tx bank send MY_WALLET RECEIVER_WALLET 1000biya --from MY_WALLET --generate-only
```

This will output the unsigned transaction as JSON in the console. We can also save the unsigned transaction to a file (to be passed around between signers more easily) by appending `> unsigned_tx.json` to the above command.

### Signing a pre-generated Transaction

Signing a transaction using the CLI requires the unsigned transaction to be saved in a file. Let's assume the unsigned transaction is in a file called `unsigned_tx.json` in the current directory (see previous paragraph on how to do that). Then, simply run the following command:

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET
```

This command will decode the unsigned transaction and sign it with `SIGN_MODE_DIRECT` with `MY_WALLET`'s key, which we already set up in the keyring. The signed transaction will be output as JSON to the console, and, as above, we can save it to a file by appending `> signed_tx.json` to the commandline.

```bash
biyachaind tx sign unsigned_tx.json --from=MY_WALLET > signed_tx.json
```

Some useful flags to consider in the `tx sign` command:

* `--sign-mode`: you may use `amino-json` to sign the transaction using `SIGN_MODE_LEGACY_AMINO_JSON`,
* `--offline`: sign in offline mode. This means that the `tx sign` command doesn't connect to the node to retrieve the signer's account number and sequence, both needed for signing. In this case, you must manually supply the `--account-number` and `--sequence` flags. This is useful for offline signing, i.e., signing in a secure environment which doesn't have access to the internet.

### Signing with multiple signers (Multi Sig)

Signing with multiple signers is done with the `tx multi-sign` command. This command assumes that all signers use `SIGN_MODE_LEGACY_AMINO_JSON`. The flow is similar to the `tx sign` command flow, but instead of signing an unsigned transaction file, each signer signs the file signed by previous signer(s). The `tx multi-sign` command will append signatures to the existing transactions. It is important that signers sign the transaction **in the same order** as given by the transaction, which is retrievable using the `GetSigners()` method.

For example, starting with the `unsigned_tx.json`, and assuming the transaction has 4 signers, we would run:

```bash
# Let signer1 sign the unsigned tx.
biyachaind tx multi-sign unsigned_tx.json signer_key_1 > partial_tx_1.json
# Now signer1 will send the partial_tx_1.json to the signer2.
# Signer2 appends their signature:
biyachaind tx multi-sign partial_tx_1.json signer_key_2 > partial_tx_2.json
# Signer2 sends the partial_tx_2.json file to signer3, and signer3 can append his signature:
biyachaind tx multi-sign partial_tx_2.json signer_key_3 > partial_tx_3.json
```

### Broadcasting a Transaction

Broadcasting a transaction is done using the following command:

```bash
biyachaind tx broadcast tx_signed.json
```

You may optionally pass the `--broadcast-mode` flag to specify which response to receive from the node:

* `block`: the CLI waits for the tx to be included in a block.
* `sync`: the CLI waits for a CheckTx execution response only, query transaction result manually to ensure it was included.
* `async`: the CLI returns immediately (transaction might fail) - DO NOT USE.

To query the transaction result, you can use the following command:

```bash
biyachaind tx query TX_HASH
```

## Additional Troubleshooting

Sometimes the config is not set correctly. You can force the correct node RPC endpoint by adding the following to the commandline. When sharing commands with others, it is recommended to have all the flags explicitly set in the commandline. (chain-id, node, keyring-backend, etc.)

```bash
biyachaind --node https://sentry.tm.biyachain.network:443
```
