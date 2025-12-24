# 配置 Nuxt

## Nuxt3 - 直观的 Web 框架

在 @biya-coin 上构建 Biya Chain 去中心化应用程序的首选 UI 框架是 Nuxt3。我们将帮助您使用 `@biya-coin` 包和一些 polyfills 配置 Nuxt3 + Vite 构建器，因为您需要它们来与加密钱包交互。

### 1. 安装 Nuxt 3

按照 [Nuxt3 文档](https://nuxt.com/docs/getting-started/installation)中的入门指南设置您的应用程序。

### 2. 安装 @biya-coin 包

您可以使用 yarn 安装 @biya-coin 包。

```bash
$ yarn add @biya-coin/sdk-ts @biya-coin/networks @biya-coin/ts-types @biya-coin/utils

## If you need Wallet Connection
$ yarn add @biya-coin/wallet-strategy
```

这些是 `biyachain-ts` monorepo 中最常用的包。

### 3. 配置 Nuxt 并添加 polyfills

首先，添加所需的 polyfill 包

```bash
$ yarn add @bangjelkoski/node-stdlib-browser
$ yarn add -D @bangjelkoski/vite-plugin-node-polyfills
```

确保您使用的是 `vue-tsc@1.8.8`、`nuxt@^3.8.1`、`typescript@^5.0.4` 版本。

**Buffer**

任何与加密相关的去中心化应用程序的主要依赖项之一是 Buffer。为了确保我们将 Buffer 添加到项目中，我们可以将其作为依赖项安装，然后创建一个 Nuxt 插件将其导入到全局/window 对象：

```bash
$ yarn add buffer
```

```ts
// filename - plugins/buffer.client.ts
export default defineNuxtPlugin(() => {
  import('buffer/').then((Buffer) => {
    window.Buffer = window.Buffer || Buffer.default.Buffer
    globalThis.Buffer = window.Buffer || Buffer.default.Buffer
  })
})
```

### 4. 使用状态管理

如果您要使用 `pinia` 作为状态管理，请将其添加到您的包中：

```bash
$ yarn add @pinia/nuxt@^0.4.9
```

### 5. 使用 `vueuse`

我们建议添加 `@vueuse/nuxt` 作为依赖项，因为它提供了许多开箱即用的实用函数。

然后，如果您使用 TypeScript（推荐），我们需要配置 `tsconfig.json`。您可以参考以下 `tsconfig.json` 作为基础。

```json
{
  // https://nuxt.com/docs/guide/concepts/typescript
  "extends": "./.nuxt/tsconfig.json",
  "compilerOptions": {
    "strict": true,
    "module": "NodeNext",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "types": ["@vueuse/nuxt", "@pinia/nuxt"]
  },
  "exclude": ["node_modules", "dist", ".output"]
}
```

### 6. nuxt.config.ts / packages.json

在启动应用程序之前，我们需要在 `nuxt.config.ts` 中设置所有内容，这是每个 Nuxt 3 应用程序的主要配置点。让我们看一个参考 `nuxt.config.ts`，并使用注释解释每一行，以便开发者更容易理解。

```ts
// filename - nuxt.config.ts
import { nodePolyfills } from '@bangjelkoski/vite-plugin-node-polyfills'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineNuxtConfig({
  ssr: false, // whether to pre-render your application
  modules: [
    // nuxtjs modules
    '@pinia/nuxt',
    '@vueuse/nuxt',
  ],

  typescript: {
    typeCheck: 'build', // we recommend build so you do typescript checks only on build type
  },

  imports: {
    // automatic imports of store definitions (if you use pinia)
    dirs: ['store/**'],
  },

  pinia: {
    // import pinia definitions
    autoImports: ['defineStore'],
  },

  plugins: [
    {
      // import the buffer plugin we've made
      src: './plugins/buffer.client.ts',
      ssr: false,
    },
  ],

  // We generate only sitemaps for the client side as we don't need a server
  // Note: there is a problem with sitemaps for Vite + Nuxt3
  // as usual is that it takes too much time/memory to generate
  // sitemaps and the build process can fail
  // on Github Actions/Netlify/Vercel/etc so we have to use another
  // strategy like generating them locally and pushing them to services like
  // busgnag
  sourcemap: {
    server: false,
    client: true,
  },

  // Vite related config
  vite: {
    plugins: [
      // setting up node + crypto polyfils + vite TS path resolution
      tsconfigPaths(),
      nodePolyfills({ protocolImports: false }),
    ],

    build: {
      sourcemap: false, // we don't generate

      // default rollup options
      rollupOptions: {
        cache: false,
        output: {
          manualChunks: (id: string) => {
            //
          },
        },
      },
    },

    // needed for some Vite related issue for the
    // @bangjelkoski/vite-plugin-node-polyfills plugin
    optimizeDeps: {
      exclude: ['fsevents'],
    },
  },
})
```

有一个优化可以减小包大小 - 在 `packages.json` 中添加这些解析

```
"resolutions": {
  "@ethereumjs/tx": "^4.1.1",
  "**/libsodium": "npm:@bangjelkoski/noop",
  "**/libsodium-wrappers": "npm:@bangjelkoski/noop"
}
```

### 7. 启动我们的应用

最后，您可以使用 `yarn dev` 在本地启动应用，或使用 `yarn generate` 生成静态页面，您可以将其部署到任何静态页面托管服务，如 Netlify、Vercel 等。
