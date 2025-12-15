# Join a network

This guide will walk you through the process of setting up a standalone network locally, as well as running a node on Mainnet or Testnet.

You can also find the hardware requirements for each network in the respective tabs.

{% tabs %}
{% tab title="Local Network" %}
To easily set up a local node, download and run the `setup.sh` script. This will initialize your local Biya Chain network.

```bash
wget https://raw.githubusercontent.com/biya-coin/biyachain-chain-releases/master/scripts/setup.sh
chmod +x ./setup.sh # Make the script executable
./setup.sh
```

Start the node by running:

```bash
biyachaind start # Blocks should start coming in after running this
```

For further explanation on what the script is doing and more fine-grained control over the setup process, continue reading below.

#### Initialize the Chain

Before running Biya Chain node, we need to initialize the chain as well as the node's genesis file:

```bash
# The <moniker> argument is the custom username of your node. It should be human-readable.
biyachaind init <moniker> --chain-id=biyachain-1
```

The command above creates all the configuration files needed for your node to run as well as a default genesis file, which defines the initial state of the network. All these configuration files are in `~/.biyachaind` by default, but you can overwrite the location of this folder by passing the `--home` flag. Note that if you choose to use a different directory other than `~/.biyachaind`, you must specify the location with the `--home` flag each time an `biyachaind` command is run. If you already have a genesis file, you can overwrite it with the `--overwrite` or `-o` flag.

The `~/.biyachaind` folder has the following structure:

```bash
.                                   # ~/.biyachaind
  |- data                           # Contains the databases used by the node.
  |- config/
      |- app.toml                   # Application-related configuration file.
      |- config.toml                # Tendermint-related configuration file.
      |- genesis.json               # The genesis file.
      |- node_key.json              # Private key to use for node authentication in the p2p protocol.
      |- priv_validator_key.json    # Private key to use as a validator in the consensus protocol.
```

#### Modify the `genesis.json` File

At this point, a modification is required in the `genesis.json` file:

* Change the staking `bond_denom`, crisis `denom`, gov `denom`, and mint `denom` values to `"biya"`, since that is the native token of Biya Chain.

This can easily be done by running the following commands:

```bash
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
cat $HOME/.biyachaind/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="biya"' > $HOME/.biyachaind/config/tmp_genesis.json && mv $HOME/.biyachaind/config/tmp_genesis.json $HOME/.biyachaind/config/genesis.json
```

{% hint style="info" %}
The commands above will only work if the default `.biyachaind` directory is used. For a specific directory, either modify the commands above or manually edit the `genesis.json` file to reflect the changes.
{% endhint %}

#### Create Keys for the Validator Account

Before starting the chain, you need to populate the state with at least one account. To do so, first create a new account in the keyring named `my_validator` under the `test` keyring backend (feel free to choose another name and another backend):

```bash
biyachaind keys add my_validator --keyring-backend=test

# Put the generated address in a variable for later use.
MY_VALIDATOR_ADDRESS=$(biyachaind keys show my_validator -a --keyring-backend=test)
```

Now that you have created a local account, go ahead and grant it some `biya` tokens in your chain's genesis file. Doing so will also make sure your chain is aware of this account's existence from the genesis of the chain:

```bash
biyachaind add-genesis-account $MY_VALIDATOR_ADDRESS 100000000000000000000000000biya --chain-id=biyachain-1
```

`$MY_VALIDATOR_ADDRESS` is the variable that holds the address of the `my_validator` key in the keyring. Tokens in Biya Chain have the `{amount}{denom}` format: `amount` is an 18-digit-precision decimal number, and `denom` is the unique token identifier with its denomination key (e.g. `biya`). Here, we are granting `biya` tokens, as `biya` is the token identifier used for staking in `biyachaind`.

#### Add the Validator to the Chain

Now that your account has some tokens, you need to add a validator to your chain. Validators are special full-nodes that participate in the consensus process in order to add new blocks to the chain. Any account can declare its intention to become a validator operator, but only those with sufficient delegation get to enter the active set. For this guide, you will add your local node (created via the `init` command above) as a validator of your chain. Validators can be declared before a chain is first started via a special transaction included in the genesis file called a `gentx`:

```bash
# Create a gentx.
biyachaind genesis gentx my_validator 1000000000000000000000biya --chain-id=biyachain-1 --keyring-backend=test

# Add the gentx to the genesis file.
biyachaind genesis collect-gentxs
```

A `gentx` does three things:

1. Registers the `validator` account you created as a validator operator account (i.e. the account that controls the validator).
2. Self-delegates the provided `amount` of staking tokens.
3. Link the operator account with a Tendermint node pubkey that will be used for signing blocks. If no `--pubkey` flag is provided, it defaults to the local node pubkey created via the `biyachaind init` command above.

For more information on `gentx`, use the following command:

```bash
biyachaind genesis gentx --help
```

#### Configuring the Node Using `app.toml` and `config.toml`

Two configuration files are automatically generated inside `~/.biyachaind/config`:

* `config.toml`: used to configure Tendermint (learn more on [Tendermint's documentation](https://docs.tendermint.com/v0.34/tendermint-core/configuration.html)), and
* `app.toml`: generated by the Cosmos SDK (which Biya Chain is built on), and used for configurations such as state pruning strategies, telemetry, gRPC and REST server configurations, state sync, and more.

Both files are heavily commented—please refer to them directly to tweak your node.

One example config to tweak is the `minimum-gas-prices` field inside `app.toml`, which defines the minimum gas prices the validator node is willing to accept for processing a transaction. If it's empty, make sure to edit the field with some value, for example `10biya`, or else the node will halt on startup. For this tutorial, let's set the minimum gas price to 0:

```toml
 # The minimum gas prices a validator is willing to accept for processing a
 # transaction. A transaction's fees must meet the minimum of any denomination
 # specified in this config (e.g. 0.25token1;0.0001token2).
 minimum-gas-prices = "0biya"
```

#### Run a Localnet

Now that everything is set up, you can finally start your node:

```bash
biyachaind start # Blocks should start coming in after running this
```

This command allows you to run a single node, which is is enough to interact with the chain through the node, but you may wish to run multiple nodes at the same time to see how consensus occurs between them.
{% endtab %}

{% tab title="Testnet Network" %}
#### Hardware Specification

Node operators should deploy bare metal servers to achieve optimal performance. Additionally, validator nodes must meet the recommended hardware specifications and particularly the CPU requirements, to ensure high uptime.

|       _Minimum_       |    _Recommendation_   |
| :-------------------: | :-------------------: |
|    RAM Memory 128GB   |    RAM Memory 128GB   |
|      CPU 12 cores     |      CPU 16 cores     |
| CPU base clock 3.7GHz | CPU base clock 4.2GHz |
|    Storage 2TB NVMe   |    Storage 2TB NVMe   |
|     Network 1Gbps+    |     Network 1Gbps+    |

#### Install `biyachaind` and `peggo`

See the [Biya Chain releases repo](https://github.com/biya-coin/testnet/releases) for the most recent releases. Non-validator node operators do not need to install `peggo`.

```bash
wget https://github.com/biya-coin/testnet/releases/latest/download/linux-amd64.zip
unzip linux-amd64.zip
sudo mv peggo /usr/bin
sudo mv biyachaind /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib 
```

#### Initialize a New Biya Chain Chain Node

Before running Biya Chain node, we need to initialize the chain as well as the node's genesis file:

```bash
# The argument <moniker> is the custom username of your node, it should be human-readable.
export MONIKER=<moniker>
# Biya Chain Testnet has a chain-id of "biyachain-888"
biyachaind init $MONIKER --chain-id biyachain-888
```

Running the `init` command will create `biyachaind` default configuration files at `~/.biyachaind`.

#### Prepare Configuration to Join Testnet

You should now update the default configuration with the Testnet's genesis file and application config file, as well as configure your persistent peers with seed nodes.

```bash
git clone https://github.com/biya-coin/testnet.git

# copy genesis file to config directory
aws s3 cp --no-sign-request s3://biyachain-snapshots/testnet/genesis.json .
mv genesis.json ~/.biyachaind/config/

# copy config file to config directory
cp testnet/corfu/70001/app.toml  ~/.biyachaind/config/app.toml
cp testnet/corfu/70001/config.toml ~/.biyachaind/config/config.toml
```

You can also run verify the checksum of the genesis checksum - a4abe4e1f5511d4c2f821c1c05ecb44b493eec185c0eec13b1dcd03d36e1a779

```bash
sha256sum ~/.biyachaind/config/genesis.json
```

#### Configure `systemd` Service for `biyachaind`

Edit the config at `/etc/systemd/system/biyachaind.service`:

```bash
[Unit]
  Description=biyachaind

[Service]
  WorkingDirectory=/usr/bin
  ExecStart=/bin/bash -c '/usr/bin/biyachaind --log-level=error start'
  Type=simple
  Restart=always
  RestartSec=5
  User=root

[Install]
  WantedBy=multi-user.target
```

Starting and restarting the systemd service

```bash
sudo systemctl daemon-reload
sudo systemctl restart biyachaind
sudo systemctl status biyachaind

# enable start on system boot
sudo systemctl enable biyachaind

# To check Logs
journalctl -u biyachaind -f
```

#### Sync with the network

Refer to the [Polkachu Biya Chain Testnet Node Snapshot](https://polkachu.com/testnets/biyachain/snapshots) to download a snapshot and sync with the network.

**Support**

For any further questions, you can always connect with the Biya Chain Team via [Discord](https://discord.gg/biyachain), [Telegram](https://t.me/joinbiyachain), or [email](mailto:contact@biya-coin.org).
{% endtab %}

{% tab title="Mainnet Network" %}
#### Hardware Specification

Node operators should deploy bare metal servers to achieve optimal performance. Additionally, validator nodes must meet the recommended hardware specifications and particularly the CPU requirements, to ensure high uptime.

|       _Minimum_       |    _Recommendation_   |
| :-------------------: | :-------------------: |
|    RAM Memory 128GB   |    RAM Memory 128GB   |
|      CPU 12 cores     |      CPU 16 cores     |
| CPU base clock 3.7GHz | CPU base clock 4.2GHz |
|    Storage 2TB NVMe   |    Storage 2TB NVMe   |
|     Network 1Gbps+    |     Network 1Gbps+    |

#### Install `biyachaind` and `peggo`

See the [Biya Chain chain releases repo](https://github.com/biya-coin/biyachain-chain-releases/releases/) for the most recent releases. Non-validator node operators do not need to install `peggo`.

```bash
wget https://github.com/biya-coin/biyachain-chain-releases/releases/latest/download/linux-amd64.zip
unzip linux-amd64.zip
sudo mv peggo /usr/bin
sudo mv biyachaind /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib 
```

#### Initialize a New Biya Chain Node

Before running Biya Chain node, we need to initialize the chain as well as the node's genesis file:

```bash
# The argument <moniker> is the custom username of your node. It should be human-readable.
export MONIKER=<moniker>
# Biya Chain Mainnet has a chain-id of "biyachain-1"
biyachaind init $MONIKER --chain-id biyachain-1
```

Running the `init` command will create `biyachaind` default configuration files at `~/.biyachaind`.

#### Prepare Configuration to Join Mainnet

You should now update the default configuration with the Mainnet's genesis file and application config file, as well as configure your persistent peers with seed nodes.

```bash
git clone https://github.com/biya-coin/mainnet-config

# copy genesis file to config directory
cp mainnet-config/10001/genesis.json ~/.biyachaind/config/genesis.json

# copy config file to config directory
cp mainnet-config/10001/app.toml  ~/.biyachaind/config/app.toml
```

You can also run verify the checksum of the genesis checksum - 573b89727e42b41d43156cd6605c0c8ad4a1ce16d9aad1e1604b02864015d528

```bash
sha256sum ~/.biyachaind/config/genesis.json
```

Then update the `seeds` field in `~/.biyachaind/config/config.toml` with the contents of `mainnet-config/10001/seeds.txt` and update the `timeout_commit` to `300ms`.

```bash
cat mainnet-config/10001/seeds.txt
nano ~/.biyachaind/config/config.toml
```

#### Configure `systemd` Service for `biyachaind`

Edit the config at `/etc/systemd/system/biyachaind.service`:

```bash
[Unit]
  Description=biyachaind

[Service]
  WorkingDirectory=/usr/bin
  ExecStart=/bin/bash -c '/usr/bin/biyachaind --log-level=error start'
  Type=simple
  Restart=always
  RestartSec=5
  User=root

[Install]
  WantedBy=multi-user.target
```

Starting and restarting the systemd service:

```bash
sudo systemctl daemon-reload
sudo systemctl restart biyachaind
sudo systemctl status biyachaind

# enable start on system boot
sudo systemctl enable biyachaind

# To check Logs
journalctl -u biyachaind -f
```

The service should be stopped before and started after the snapshot data has been loaded into the correct directory.

```bash
# to stop the node
sudo systemctl stop biyachaind

# to start the node
sudo systemctl start biyachaind
```

#### Sync with the network

**Option 1. State-Sync**

_To be added soon_

**Option 2. Snapshots**

**Pruned**

1. [Polkachu](https://polkachu.com/tendermint_snapshots/biyachain).
2. [HighStakes](https://tools.highstakes.ch/files/biyachain.tar.gz).
3. [Imperator](https://www.imperator.co/services/chain-services/mainnets/biyachain).
4. [Bware Labs](https://bwarelabs.com/snapshots).
5. [AutoStake](https://autostake.com/networks/biyachain/#validator).

Should the Biya Chain `mainnet-config seeds.txt` list not work (the node fails to sync blocks), ChainLayer, Polkachu, and Autostake maintain peer lists (can be used in the `persistent_peers` field in `config.toml`) or addressbooks (for faster peer discovery).

**Support**

For any further questions, you can always connect with the Biya Chain Team via [Discord](https://discord.gg/biyachain), [Telegram](https://t.me/joinbiyachain), or [email](mailto:contact@biya-coin.org)
{% endtab %}
{% endtabs %}
