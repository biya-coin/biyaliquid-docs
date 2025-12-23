# 将 Biya Chain 添加到您的 dApp

使您的用户只需单击一次即可连接到 Biya Chain 网络。\
\
使用下面的代码片段向您的 dApp 添加"添加 Biya Chain 网络"按钮，使用户可以轻松地将 Biya Chain 添加到 MetaMask 或任何 EVM 兼容的钱包。



1. 将代码片段复制并粘贴到您的前端代码库中。
2. 将 `addBiyachainNetwork` 函数连接到您首选的 UI 按钮。
3. 就是这样——您的用户现在可以在几秒钟内将 Biya Chain 添加到他们的钱包

```tsx
// 网络配置
const biyachain_MAINNET_CONFIG = {
  chainId: '0x6f0', // 十进制为 1776
  chainName: 'Biya Chain',
  rpcUrls: ['https://evm-rpc.biyachain.network'],
  nativeCurrency: {
    name: 'Biya Chain',
    symbol: 'BIYA',
    decimals: 18
  },
  blockExplorerUrls: ['https://prv.scan.biya.io/zh/transactions']
};

async function addBiyachainNetwork() {
  // 检查是否安装了 MetaMask 或其他 Web3 钱包
  if (!window.ethereum) {
    alert('请安装 MetaMask 或其他 Web3 钱包！');
    return;
  }

  try {
    // 首先，尝试切换到 Biya Chain 网络
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: biyachain_MAINNET_CONFIG.chainId }],
    });
    
    console.log('成功切换到 Biya Chain 网络！');
  } catch (switchError) {
    // 错误代码 4902 表示网络尚未添加
    if (switchError.code === 4902) {
      try {
        // 添加 Biya Chain 网络
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [biyachain_MAINNET_CONFIG],
        });
        
        console.log('Biya Chain 网络添加成功！');
      } catch (addError) {
        console.error('添加 Biya Chain 网络失败:', addError);
        alert('添加 Biya Chain 网络失败。请重试。');
      }
    } else {
      console.error('切换网络失败:', switchError);
      alert('切换到 Biya Chain 网络失败。');
    }
  }
}
```
