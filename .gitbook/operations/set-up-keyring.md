# 设置密钥环

{% hint style="info" %}
本文档介绍如何为 Biya Chain 节点配置和使用密钥环及其各种后端。在设置密钥环之前应安装 `biyachaind`。有关更多信息，请参阅 [安装 `biyachaind` 页面](../developers/biyachaind/install.md)。
{% endhint %}

密钥环保存用于与节点交互的私钥/公钥对。例如，在运行 Biya Chain 节点之前需要设置验证器密钥，以便正确签名区块。私钥可以存储在不同的位置，称为"后端"，例如文件或操作系统自己的密钥存储。

### 密钥环的可用后端

#### `os` 后端

`os` 后端依赖于操作系统特定的默认值来安全地处理密钥存储。通常，操作系统的凭证子系统根据用户的密码策略处理密码提示、私钥存储和用户会话。以下是最流行的操作系统及其各自的密码管理器列表：

* macOS（自 Mac OS 8.6 起）：[Keychain](https://support.apple.com/en-gb/guide/keychain-access/welcome/mac)
* Windows：[Credentials Management API](https://docs.microsoft.com/en-us/windows/win32/secauthn/credentials-management)
* GNU/Linux：
  * [libsecret](https://gitlab.gnome.org/GNOME/libsecret)
  * [kwallet](https://api.kde.org/frameworks/kwallet/html/index.html)

使用 GNOME 作为默认桌面环境的 GNU/Linux 发行版通常附带 [Seahorse](https://wiki.gnome.org/Apps/Seahorse)。基于 KDE 的发行版用户通常提供 [KDE Wallet Manager](https://userbase.kde.org/KDE_Wallet_Manager)。虽然前者实际上是 `libsecret` 的便捷前端，但后者是 `kwallet` 客户端。

`os` 是默认选项，因为操作系统的默认凭证管理器旨在满足用户最常见的需求，并在不损害安全性的情况下为他们提供舒适的体验。

无头环境推荐的后端是 `file` 和 `pass`。

#### `file` 后端

`file` 后端将密钥环加密存储在应用程序的配置目录中。此密钥环每次访问时都会请求密码，这在单个命令中可能发生多次，导致重复的密码提示。如果使用 bash 脚本执行使用 `file` 选项的命令，您可能希望使用以下格式来处理多次提示：

```bash
# assuming that KEYPASSWD is set in the environment
yes $KEYPASSWD | biyachaind keys add me
yes $KEYPASSWD | biyachaind keys show me
# start biyachaind with keyring-backend flag
biyachaind --keyring-backend=file start
```

{% hint style="info" %}
第一次向空密钥环添加密钥时，系统会提示您输入两次密码。
{% endhint %}

#### `pass` 后端

`pass` 后端使用 [pass](https://www.passwordstore.org/) 实用程序来管理密钥敏感数据和元数据的磁盘加密。密钥存储在应用程序特定目录内的 `gpg` 加密文件中。`pass` 适用于最流行的 UNIX 操作系统以及 GNU/Linux 发行版。有关如何下载和安装的信息，请参阅其手册页。

{% hint style="info" %}
`pass` 使用 [GnuPG](https://gnupg.org/) 进行加密。`gpg` 在执行时自动调用 `gpg-agent` 守护进程，该进程处理 GnuPG 凭证的缓存。有关如何配置缓存参数（如凭证 TTL 和密码短语过期）的更多信息，请参阅 `gpg-agent` 手册页。
{% endhint %}

密码存储必须在首次使用之前设置：

```sh
pass init <GPG_KEY_ID>
```

将 `<GPG_KEY_ID>` 替换为您的 GPG 密钥 ID。您可以使用您的个人 GPG 密钥或您可能想要专门用于加密密码存储的替代密钥。

#### `kwallet` 后端

`kwallet` 后端使用 `KDE Wallet Manager`，它在将 KDE 作为默认桌面环境的 GNU/Linux 发行版中默认安装。有关更多信息，请参阅 [KWallet 手册](https://docs.kde.org/stable/en/kdeutils/kwallet/index.html)。

#### `test` 后端

`test` 后端是 `file` 后端的无密码变体。密钥以未加密方式存储在磁盘上。

**仅用于测试目的。不建议在生产环境中使用 `test` 后端**。

#### `memory` 后端

`memory` 后端将密钥存储在内存中。程序退出后，密钥会立即删除。

**仅用于测试目的。不建议在生产环境中使用 `memory` 后端**。

### 向密钥环添加密钥

您可以使用 `biyachaind keys` 获取有关 keys 命令的帮助，使用 `biyachaind keys [command] --help` 获取有关特定子命令的更多信息。

{% hint style="info" %}
您还可以使用 `biyachaind completion` 命令启用自动完成。例如，在 bash 会话开始时，运行 `. <(biyachaind completion)`，所有 `biyachaind` 子命令都将自动完成。
{% endhint %}

要在密钥环中创建新密钥，请使用 `<key_name>` 参数运行 `add` 子命令。在本教程中，我们将仅使用 `test` 后端，并将新密钥命名为 `my_validator`。此密钥将在下一节中使用。

```bash
$ biyachaind keys add my_validator --keyring-backend test

# Put the generated address in a variable for later use.
MY_VALIDATOR_ADDRESS=$(biyachaind keys show my_validator -a --keyring-backend test)
```

此命令生成一个新的 24 词助记词短语，将其持久化到相关后端，并输出有关密钥对的信息。如果此密钥对将用于持有有价值的代币，请务必将助记词短语写在安全的地方！

默认情况下，密钥环生成 `eth_secp256k1` 密钥对。密钥环还支持 `ed25519` 密钥，可以通过传递 `--algo ed25519` 标志来创建。密钥环当然可以同时持有两种类型的密钥。
