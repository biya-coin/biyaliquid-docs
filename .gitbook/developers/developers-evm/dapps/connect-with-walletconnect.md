# Connect with WalletConnect

WalletConnect is an open-source, chain-agnostic protocol that securely links wallets and Web3 applications. It uses a bridge server to relay encrypted messages, allowing users to connect by scanning a QR code or via deep-linking, without exposing private keys.

### Integration Steps for WalletConnect

#### Prerequisites

Register at [WalletConnect Cloud](https://cloud.walletconnect.com) and obtain the **project ID**.

***

#### Install Dependency

```bash
npm install ethers wagmi viem @walletconnect/ethereum-provider
```

Set up Biya Chain EVM network configuration

```javascript
// lib/biyachainChain.ts
import { defineChain } from 'viem'

export const biyachainEvm = defineChain({
  id: 1439,
  name: 'Biya Chain EVM',
  nativeCurrency: {
    name: 'BIYA',
    symbol: 'BIYA',
    decimals: 18,
  },
  rpcUrls: {
    default: { http: ['https://k8s.testnet.json-rpc.biyachain.network'] },
  },
  blockExplorers: {
    default: { name: 'BiyachainScan', url: 'https://testnet.blockscout.biyachain.network/blocks' },
  },
})
```

Set up Wagmi + WalletConnect

```javascript
 // lib/wagmi.ts
import { createConfig, http } from '@wagmi/core'
import { walletConnect } from '@wagmi/connectors'
import { biyachainEvm } from './biyachainChain'

export const wagmiConfig = createConfig({
  chains: [biyachainEvm],
  connectors: [
    walletConnect({
      projectId: 'your-walletconnect-project-id', // From WalletConnect Cloud
      showQrModal: true,
    }),
  ],
  transports: {
    [biyachainEvm.id]: http(biyachainEvm.rpcUrls.default.http[0]),
  },
})

```

Integrate into your project

```javascript
'use client'

import { useConnect, useAccount, WagmiProvider } from 'wagmi'
import { wagmiConfig } from './providers'
import Image from 'next/image'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient()

function WalletConnector() {
  const { connectors, connect, isPending } = useConnect()
  const { address, isConnected } = useAccount()
  const wcConnector = connectors.find(c => c.id === 'walletConnect')

  return (
    <div style={{ textAlign: 'center', marginTop: '100px' }}>
      {isConnected ? (
        <p>Connected to {address}</p>
      ) : (
        <button
          onClick={() => wcConnector && connect({ connector: wcConnector })}
          disabled={isPending || !wcConnector}
          style={{ padding: '12px 24px', fontSize: '16px' }}
        >
          Connect Wallet (WalletConnect)
        </button>
      )}
    </div>
  )
}

export default function Home() {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <WalletConnector />
      </QueryClientProvider>
    </WagmiProvider>
  )
}

```

***

More Info

* WalletConnect docs: [https://docs.walletconnect.com](https://docs.walletconnect.com)
* WalletConnect official examples: [https://github.com/WalletConnect/web-examples](https://github.com/WalletConnect/web-examples)
