# Add Biyaliquid to Your dApp

Enable your users to connect to the Biyaliquid network with a single click.\
\
Use the code snippet below to add an “Add Biyaliquid Network” button to your dApp, making it easy for users to add Biyaliquid to MetaMask or any EVM-compatible wallet.



1. Copy and paste the snippet into your frontend codebase.
2. Connect the `addBiyaliquidNetwork` function to your preferred UI button.
3. That’s it—your users can now add Biyaliquid to their wallet in seconds

```tsx
// Network configuration
const biyaliquid_MAINNET_CONFIG = {
  chainId: '0x6f0', // 1776 in decimal
  chainName: 'Biyaliquid',
  rpcUrls: ['https://evm-rpc.biyaliquid.network'],
  nativeCurrency: {
    name: 'Biyaliquid',
    symbol: 'BIYA',
    decimals: 18
  },
  blockExplorerUrls: ['https://explorer.biyaliquid.network']
};

async function addBiyaliquidNetwork() {
  // Check if MetaMask or another Web3 wallet is installed
  if (!window.ethereum) {
    alert('Please install MetaMask or another Web3 wallet!');
    return;
  }

  try {
    // First, try to switch to the Biyaliquid network
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: biyaliquid_MAINNET_CONFIG.chainId }],
    });
    
    console.log('Switched to Biyaliquid network successfully!');
  } catch (switchError) {
    // Error code 4902 means the network hasn't been added yet
    if (switchError.code === 4902) {
      try {
        // Add the Biyaliquid network
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [biyaliquid_MAINNET_CONFIG],
        });
        
        console.log('Biyaliquid network added successfully!');
      } catch (addError) {
        console.error('Failed to add Biyaliquid network:', addError);
        alert('Failed to add Biyaliquid network. Please try again.');
      }
    } else {
      console.error('Failed to switch network:', switchError);
      alert('Failed to switch to Biyaliquid network.');
    }
  }
}
```
