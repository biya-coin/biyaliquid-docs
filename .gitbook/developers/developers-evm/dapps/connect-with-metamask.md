# 使用 MetaMask 连接

## 将 MetaMask 连接到 Biya Chain EVM 测试网

MetaMask 是一个浏览器钱包扩展，可让您连接到任何 EVM 兼容网络，包括 **Biya Chain EVM**。

### 如何安装 MetaMask

从 [MetaMask 下载页面](https://metamask.io/download) 安装官方 MetaMask 扩展。

### 将 Biya Chain EVM 测试网添加到 MetaMask

1. 点击浏览器中的 **MetaMask 图标**并解锁您的钱包。
2. 点击顶部的**网络选择器**（默认为 _"Ethereum Mainnet"_）。
3. 选择 **"Add Network"** 或 **"Add a network manually"** 打开自定义网络表单。

#### Biya Chain EVM 测试网参数

填写以下详细信息：

```json
Network Name: Biya Chain EVM Testnet
Chain ID: 1439
RPC URL: https://k8s.testnet.json-rpc.biyachain.network/
Currency Symbol: BIYA
Block Explorer URL: https://testnet.blockscout.biyachain.network/blocks
```

> _注意：Block Explorer URL 是可选的，由 BlockScout 提供支持。_

### 切换到 Biya Chain EVM 测试网

添加网络后，使用网络选择器切换到 **Biya Chain EVM Testnet**。

### 为您的钱包充值（可选）

需要测试网 BIYA？访问 [Biya Chain 测试网水龙头](https://testnet.faucet.biyachain.network)。

资金将在包含在测试网区块中后出现。

***

### 一切就绪！

MetaMask 现在已连接到 **Biya Chain EVM 测试网**。您可以：

* 使用 **Foundry**、**Hardhat** 或 **Remix** 等工具部署智能合约。
* 与测试网 dApp 和合约交互。
* 通过 Blockscout 浏览器检查交易。

> **提示：** 始终仔细检查 RPC URL 和 Chain ID - 准确性对于避免配置错误至关重要。

***

### 通过 `ethers.js` 连接 MetaMask

您还可以使用 [`ethers`](https://docs.ethers.org/) 以编程方式连接 MetaMask。

#### 示例代码

```ts
import { ethers } from 'ethers';

export const biyachain_EVM_PARAMS = {
  chainId: '0x59f', // 1439 的十六进制
  chainName: 'Biya Chain EVM',
  rpcUrls: ['https://k8s.testnet.json-rpc.biyachain.network/'],
  nativeCurrency: {
    name: 'Biya Chain',
    symbol: 'BIYA',
    decimals: 18,
  },
  blockExplorerUrls: ['https://testnet.blockscout.biyachain.network/blocks'],
};

export async function connectMetaMask() {
  if (typeof window.ethereum === 'undefined') {
    alert('MetaMask 未安装！');
    return;
  }

  const provider = new ethers.providers.Web3Provider(window.ethereum);

  try {
    await window.ethereum.request({
      method: 'wallet_addEthereumChain',
      params: [biyachain_EVM_PARAMS],
    });

    await provider.send('eth_requestAccounts', []);
    const signer = provider.getSigner();
    const address = await signer.getAddress();

    console.log('已连接地址:', address);
    return { provider, signer, address };
  } catch (err) {
    console.error('MetaMask 连接失败:', err);
  }
}
```

### 使用 `ethers.js` 与您的智能合约交互

示例代码

[counter 合约](/broken/pages/8hmIqtuEuzYmXK7me3oI) ABI:

```tsx
// abi/counterAbi.ts
[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "reason",
				"type": "string"
			}
		],
		"name": "UserRevert",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newValue",
				"type": "uint256"
			}
		],
		"name": "ValueSet",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "increment",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "number",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newNumber",
				"type": "uint256"
			}
		],
		"name": "setNumber",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "reason",
				"type": "string"
			}
		],
		"name": "userRevert",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
```

```javascript
import { ethers } from 'ethers'
import { biyachain_EVM_PARAMS } from './config' // 从单独的文件导入
import { counterAbi } from './abi/counterAbi'

// 替换为您部署的合约地址
const contractAddress = '0xYourContractAddressHere'

async function connectAndInteract() {
  if (!window.ethereum) {
    alert('MetaMask 未安装！')
    return
  }

  // 请求将 Biya Chain EVM 网络添加到 MetaMask
  await window.ethereum.request({
    method: 'wallet_addEthereumChain',
    params: [
      {
        chainId: biyachain_EVM_PARAMS.chainHex,
        chainName: biyachain_EVM_PARAMS.chainName,
        rpcUrls: [biyachain_EVM_PARAMS.rpcUrl],
        nativeCurrency: biyachain_EVM_PARAMS.nativeCurrency,
        blockExplorerUrls: [biyachain_EVM_PARAMS.blockExplorer],
      },
    ],
  })

  const provider = new ethers.providers.Web3Provider(window.ethereum)
  await provider.send('eth_requestAccounts', [])
  const signer = provider.getSigner()
  const userAddress = await signer.getAddress()
  console.log('已连接为:', userAddress)

  // 合约实例
  const contract = new ethers.Contract(contractAddress, counterAbi, signer)

  // 发送交易以递增
  const tx = await contract.increment()
  console.log('交易已发送:', tx.hash)

  const receipt = await tx.wait()
  console.log('交易已在区块中打包:', receipt.blockNumber)
}

connectAndInteract().catch(console.error)
```

### 使用 `viem` 与您的智能合约交互

示例代码

```javascript
import { createWalletClient, custom, defineChain, formatEther } from 'viem'
import { biyachain_EVM_PARAMS } from './config'
import { counterAbi } from './abi/counterAbi'
import { createPublicClient, http } from 'viem'

// 替换为您部署的合约地址
const contractAddress = '0xYourContractAddressHere'

async function connectAndInteract() {
  if (typeof window === 'undefined' || typeof window.ethereum === 'undefined') {
    alert('MetaMask 未安装！')
    return
  }

  const client = createWalletClient({
    chain: biyachain_EVM_PARAMS,
    transport: custom(window.ethereum),
  })

  // 创建 PublicClient 用于读取合约状态
  const publicClient = createPublicClient({
    chain: biyachainEvm,
    transport: http(),
  })

  const [account] = await client.requestAddresses()
  console.log('已连接账户:', account)

  // 使用钱包客户端发送交易以递增
  const hash = await client.writeContract({
    address: contractAddress,
    abi: counterAbi,
    functionName: 'increment',
    account,
  })

  console.log('交易已发送，哈希:', hash)
}

connectAndInteract().catch(console.error)
```
