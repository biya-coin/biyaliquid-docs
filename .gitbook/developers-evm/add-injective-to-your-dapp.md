# Add Biyachain to Your dApp

Enable your users to connect to the Biyachain network with a single click.\
\
Use the code snippet below to add an “Add Biyachain Network” button to your dApp, making it easy for users to add Biyachain to MetaMask or any EVM-compatible wallet.



1. Copy and paste the snippet into your frontend codebase.
2. Connect the `addBiyachainNetwork` function to your preferred UI button.
3. That’s it—your users can now add Biyachain to their wallet in seconds

```tsx
// Network configuration
const biyachain_MAINNET_CONFIG = {
  chainId: '0x6f0', // 1776 in decimal
  chainName: 'Biyachain',
  rpcUrls: ['https://evm-rpc.biyachain.network'],
  nativeCurrency: {
    name: 'Biyachain',
    symbol: 'BIYA',
    decimals: 18
  },
  blockExplorerUrls: ['https://prv.scan.biya.io']
};

async function addBiyachainNetwork() {
  // Check if MetaMask or another Web3 wallet is installed
  if (!window.ethereum) {
    alert('Please install MetaMask or another Web3 wallet!');
    return;
  }

  try {
    // First, try to switch to the Biyachain network
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: biyachain_MAINNET_CONFIG.chainId }],
    });
    
    console.log('Switched to Biyachain network successfully!');
  } catch (switchError) {
    // Error code 4902 means the network hasn't been added yet
    if (switchError.code === 4902) {
      try {
        // Add the Biyachain network
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [biyachain_MAINNET_CONFIG],
        });
        
        console.log('Biyachain network added successfully!');
      } catch (addError) {
        console.error('Failed to add Biyachain network:', addError);
        alert('Failed to add Biyachain network. Please try again.');
      }
    } else {
      console.error('Failed to switch network:', switchError);
      alert('Failed to switch to Biyachain network.');
    }
  }
}
```
