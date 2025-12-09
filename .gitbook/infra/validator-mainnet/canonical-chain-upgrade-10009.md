---
sidebar_position: 12
---

# Upgrade to 10009

Tuesday, January 18th, 2022

Following [proposal 198](https://biyahub.com/proposals/198/) This indicates that the upgrade procedure should be performed on block number **24204000**

* [Summary](#summary)
* [Risks](#risks)
* [Recovery](#recovery)
* [Upgrade Procedure](#upgrade-procedure)
* [Notes for Validator Operators](#notes-for-validator-operators)
* [Notes for Service Providers](#notes-for-dex-relayer-providers)

## Summary

The Biyaliquid Canonical Chain will undergo a scheduled enhancement upgrade on **Tuesday, January 18th, 2022, 14:00 UTC**.

The following is a short summary of the upgrade steps:

1. Vote and wait till the node panics at block height **24204000**.
2. Backing up configs, data, and keys used for running the Biyaliquid Canonical Chain.
3. Install the [Mainnet-10009-1673640888](https://github.com/biya-coin/biyaliquid-chain-releases/releases/tag/v1.9.0-1673640888)
4. Start your node with the new biyaliquidd binary to fulfill the upgrade.

Upgrade coordination and support for validators will be available on the `#mainnet-validators` private channel of the [Biyaliquid Discord](https://discord.gg/biyaliquid).

The network upgrade can take the following potential pathways:

1. **Happy path**\
   Validators successfully upgrade chain without purging the blockchain history, and all validators are up within 1-2 hours of the scheduled upgrade.
2. **Not-so-happy path**\
   Validators have trouble upgrading to the latest Canonical chain. This could be some consensus breaking changes not covered in upgrade handler, or compatibility issue of the migrated state with new biyaliquidd binary, but validators can at least export the genesis.
3. **Abort path**\
   In the rare event that the team becomes aware of unnoticed critical issues, the Biyaliquid team will attempt to patch all the breaking states and provide another official binary within 36 hours.\
   If the chain is not successfully resumed within 36 hours, the upgrade will be announced as aborted on the #mainnet-validators channel of [Discord](https://discord.gg/biyaliquid), and validators will need to resume running the chain without any updates or changes. A new governance proposal for the upgrade will need to be issued and voted on by the community for the next upgrade.

## Risks

As a validator, performing the upgrade procedure on your consensus nodes carries a heightened risk of double-signing and being slashed. The most important piece of this procedure is verifying your software version and genesis file hash before starting your validator and signing.

The riskiest thing a validator can do is discover that they made a mistake and repeat the upgrade procedure again during the network startup. If you discover a mistake in the process, the best thing to do is wait for the network to start before correcting it. If the network is halted and you have started with a different genesis file than the expected one, seek advice from an Biyaliquid developer before resetting your validator.

## Recovery

Prior to exporting chain state, validators are encouraged to take a full data snapshot at the export height before proceeding. Snapshotting depends heavily on infrastructure, but generally this can be done by backing up the `.biyaliquidd` directory.

It is critically important to backup the `.biyaliquidd/data/priv_validator_state.json` file after stopping your biyaliquidd process. This file is updated every block as your validator participates in a consensus rounds. It is a critical file needed to prevent double-signing, in case the upgrade fails and the previous chain needs to be restarted.

In the event that the upgrade does not succeed, validators and operators must restore the snapshot and downgrade back to [Biyaliquid Chain 10008 release](https://github.com/biya-coin/biyaliquid-chain-releases/releases/tag/v1.8.0-1668679102) and continue the chain until next upgrade announcement.

### Upgrade Procedure

## Notes for Validators

Validator operators should configure the **timeout_commit** in **config.toml** to `300ms`.

1.  Verify you are currently running the correct version (`64c9081`) of `biyaliquidd`:

    ```bash
    biyaliquidd version
    Version dev (64c9081)
    Compiled at 20221024-1031 using Go go1.18.5 (amd64)
    ```
2.  After the chain has halted, make a backup of your `.biyaliquidd` directory

    ```bash
    cp ~/.biyaliquidd ./biyaliquidd-backup
    ```

    \
    **NOTE**: It is recommended for validators and operators to take a full data snapshot at the export height before proceeding in case the upgrade does not go as planned or if not enough voting power comes online in a sufficient and agreed upon amount of time. In such a case, the chain will fallback to continue operating the Chain. See [Recovery](#recovery) for details on how to proceed.
3.  Download and install the biyaliquid-chain `10009 release`

    ```bash
    wget https://github.com/biya-coin/biyaliquid-chain-releases/releases/download/v1.9.0-1673640888/linux-amd64.zip
    unzip linux-amd64.zip
    sudo mv biyaliquidd peggo /usr/bin
    sudo mv libwasmvm.x86_64.so /usr/lib
    ```
4.  Verify you are currently running the correct version (`3c87354f5`) of `biyaliquidd` after downloading the 10009 release:

    ```bash
    biyaliquidd version
    Version dev (3c87354f5)
    Compiled at 20230113-2015 using Go go1.18.3 (amd64)
    ```
5.  Coordinate to restart your biyaliquidd with other validators

    ```bash
    biyaliquidd start
    ```

    The binary will perform the upgrade automatically and continue the next consensus round if everything goes well.
6. Verify you are currently running the correct version (`ade8906`) of `peggo` after downloading the 10009 release:

```bash
 peggo version
 Version dev (ade8906)
 Compiled at 20220830-1738 using Go go1.18.5 (amd64)
```

8.  Start peggo

    ```bash
    peggo start
    ```

## Notes for DEX relayer providers

Relayer upgrade will be available after the chain is successfully upgraded, as it relies on several other components that work with biyaliquidd.
