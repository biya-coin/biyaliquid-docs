# Biyachain 网络 Cosmovisor 设置指南

Cosmovisor 是一个专为基于 Cosmos SDK 的区块链设计的进程管理器，可简化二进制（链）升级的管理。本指南提供了为您的 Biyachain 网络节点设置 Cosmovisor 的分步说明。

> **注意：** 这些说明假设您已经有一个现有的链二进制文件（例如 `biyachaind`），如果您选择从源代码安装 Cosmovisor，还需要一个可用的 Go 环境。根据您的具体设置调整名称和路径。

---

## 目录

1. [安装](#installation)
   - [通过 Go 安装](#installing-via-go)
2. [环境变量](#environment-variables)
3. [目录结构](#directory-structure)
4. [运行 Cosmovisor](#running-cosmovisor)
5. [处理链升级](#handling-chain-upgrades)
6. [将 Cosmovisor 作为 Systemd 服务运行](#running-cosmovisor-as-a-systemd-service)

---

## 安装

### 通过 Go 安装

如果您已安装 Go，可以使用以下命令安装 Cosmovisor：

```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0
```

> **提示：** 确保您的 Go 二进制安装路径（通常是 `$GOPATH/bin` 或 `$HOME/go/bin`）已添加到系统的 `PATH` 中。您可以通过运行以下命令验证安装：
>
> ```bash
> which cosmovisor
> ```

## 环境变量

设置以下环境变量，以便 Cosmovisor 知道要运行哪个二进制文件以及在哪里找到它：

- **`DAEMON_NAME`**  
  链二进制文件的名称（例如 `biyachaind`）。

- **`DAEMON_HOME`**  
  节点的主目录（例如 `~/.biyachaind`）。

您可以在 shell 的配置文件中设置这些变量（如 `~/.bashrc` 或 `~/.profile`），或在终端会话中直接导出它们：

```bash
export DAEMON_NAME=biyachaind
export DAEMON_HOME=~/.biyachaind
```

---

## 目录结构

Cosmovisor 期望在节点的主目录中有特定的文件夹结构：

1. **创建创世目录**

   此目录保存初始（创世）二进制文件。

   ```bash
   mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin
   ```

2. **复制当前二进制文件**

   将当前的链二进制文件（例如 `biyachaind`）放入创世文件夹。确保文件名与 `DAEMON_NAME` 值匹配（请参阅下一节）。

   ```bash
   cp $(which biyachaind) $DAEMON_HOME/cosmovisor/genesis/bin/biyachaind
   ```

---

## 运行 Cosmovisor

不要直接运行链的二进制文件，而是通过执行以下命令使用 Cosmovisor 启动节点：

```bash
cosmovisor run start
```

Cosmovisor 将：

- 在 `$DAEMON_HOME/cosmovisor/genesis/bin`（或相应的升级文件夹）中查找二进制文件。
- 使用该二进制文件启动节点。
- 监控任何链上升级信号，并在需要时自动切换二进制文件。

---

## 处理链升级

当链上宣布升级时，准备新的二进制文件，以便 Cosmovisor 可以自动切换到它：

1. **创建升级目录**

   使用链上提供的升级名称（例如 `v1.14.0`）：

   ```bash
   mkdir -p $DAEMON_HOME/cosmovisor/upgrades/<upgrade_name>/bin
   ```

2. **放置新二进制文件**

   编译或下载新的二进制文件，然后将其复制到升级目录。确保二进制文件名与 `DAEMON_NAME` 匹配。

   ```bash
   cp /path/to/new/biyachaind $DAEMON_HOME/cosmovisor/upgrades/<upgrade_name>/bin
   cp /path/to/new/libwasmvm.x86_64.so $DAEMON_HOME/cosmovisor/upgrades/<upgrade_name>/bin
   ```

> **提示：** 如果您从 GitHub 下载了 `biyachaind` 二进制包，我们将 `libwasmvm.x86_64.so` 复制到升级 `bin` 目录。稍后将在 systemd 服务中添加环境变量，以将此目录添加到 `LD_LIBRARY_PATH`。

3. **升级过程**

   当达到升级高度时，Cosmovisor 将检测到计划的升级并自动切换到位于相应升级文件夹中的二进制文件。

---

## 将 Cosmovisor 作为 Systemd 服务运行

对于生产环境，通常将节点作为 systemd 服务运行。下面是一个示例服务文件。

1. **创建服务文件**

   创建一个文件（例如 `/etc/systemd/system/biyachaind.service`），内容如下。相应地调整路径和 `<your_username>`：

   ```ini
   [Unit]
   Description=Biyachain Daemon managed by Cosmovisor
   After=network-online.target

   [Service]
   User=<your_username>
   ExecStart=/home/<your_username>/go/bin/cosmovisor run start
   Restart=always
   RestartSec=3
   Environment="DAEMON_NAME=biyachaind"
   Environment="DAEMON_HOME=/home/<your_username>/.biyachaind"
   Environment="PATH=/usr/local/bin:/home/<your_username>/go/bin:$PATH"
   Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
   Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
   Environment="UNSAFE_SKIP_BACKUP=true"
   Environment="LD_LIBRARY_PATH=/home/<your_username>/.biyachaind/cosmovisor/current/bin"

   [Install]
   WantedBy=multi-user.target
   ```

2. **启用并启动服务**

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable biyachaind.service
   sudo systemctl start biyachaind.service
   ```

3. **检查日志**

   验证您的服务是否正常运行：

   ```bash
   journalctl -u biyachaind.service -f
   ```

---
