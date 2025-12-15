# Install biyachaind

## Platform compatibiltiy guide

Check out this table to see which platform is supported to run `biyachaind` CLI:

| Platform | Pre-Built Binaries | Docker | From Source |
|----------|-------------------|--------|------------|
| macOS (M1/ARM) | ❌ | ✅ | ✅ |
| macOS (Intel) | ❌ | ✅ | ✅ |
| Windows (x86_64) | ❌ | ✅ | ❌ |
| Windows (ARM) | ❌ | ✅ | ❌ |
| Linux (x86_64) | ✅ | ✅ | ✅ |
| Linux (ARM) | ❌ | ✅ | ✅ |


## Getting started with pre-built binaries

At the moment, the only supported platform to run a pre-built `biyachaind` CLI is Linux x86_64. The pre-built binaries are available on the [Biya Chain GitHub Releases page](https://github.com/biya-coin/biyachain-chain-releases/releases).

```bash
wget https://github.com/biya-coin/biyachain-chain-releases/releases/download/v1.14.1-1740773301/linux-amd64.zip
unzip linux-amd64.zip
```

This zip file will contain these files:

* **`biyachaind`** - Biya Chain daemon also CLI
* **`peggo`** - Biya Chain Ethereum's bridge relayer daemon
* **`libwasmvm.x86_64.so`** - the WASM virtual machine support file

Note: you do not need `peggo` for deploying and instantiating smart contracts, this is for validators.

```bash
sudo mv biyachaind /usr/bin
sudo mv libwasmvm.x86_64.so /usr/lib
```

Confirm your version matches the output below (your output may be slightly different if a newer version is available):

```bash
biyachaind version

Version v1.14.1 (0fe59376dc)
Compiled at 20250302-2204 using Go go1.23.1 (amd64)
```

Continue to [Using biyachaind](./use.md) to learn how to use `biyachaind` CLI for interacting with the Biya Chain blockchain.

## Getting started with Docker

The following command will start a container with `biyachaind` CLI:

```bash
docker run -it --rm biya-coin/biyachain-core:v1.14.1 biyachaind version

Version v1.14.1 (0fe59376d)
Compiled at 20250302-2220 using Go go1.22.11 (amd64)
```

This is compatible with most platforms and arm64 / x86_64 architectures.


Continue to [Using biyachaind](./use.md) to learn how to use `biyachaind` CLI for interacting with the Biya Chain blockchain.


## Getting started with source code

The following command will build `biyachaind` CLI from source code:

```bash
git clone https://github.com/BiyachainFoundation/biyachain-core.git
cd biyachain-core && git checkout v1.14.1
make install
```

This will install `biyachaind` CLI to your go path.

```bash
biyachaind version

Version v1.14.1 (dd7622f)
Compiled at 20250302-2230 using Go go1.24.0 (amd64)
```

(the commit hash may be different, as the open-source repository is published separately from the pre-built versions).

Continue to [Using biyachaind](./use.md) to learn how to use `biyachaind` CLI for interacting with the Biya Chain blockchain.
