# 配置 React

## React - 用于构建用户界面的库

React 目前是最流行的 UI 框架之一。我们将帮助您使用 `@biya-coin` 包和一些 polyfills 配置 React + Vite 构建器，因为您需要它们来与加密钱包交互。

### 1. 安装 React

按照 [Vite 文档](https://vitejs.dev/guide/)中的入门指南设置您的应用程序。

```bash
$ npm create vite@latest
```

### 2. 安装 @biya-coin 包

您可以使用 yarn 安装 @biya-coin 包。

```bash
$ yarn add @biya-coin/sdk-ts @biya-coin/networks @biya-coin/ts-types @biya-coin/utils

## If you need Wallet Connection
$ yarn add @biya-coin/wallet-strategy
```

这些是 `biyachain-ts` monorepo 中最常用的包。

### 3. 配置 Vite 并添加 polyfills

首先，添加所需的 polyfill 包和 buffer

{% hint style="info" %}
任何与加密相关的去中心化应用程序的主要依赖项之一是 `Buffer`。为了确保我们将 `Buffer` 添加到项目中，我们可以将其作为依赖项安装，然后将其导入到全局/window 对象。

示例 `vite.config.ts` 如下所示。
{% endhint %}

```bash
$ yarn add @bangjelkoski/node-stdlib-browser
$ yarn add -D @bangjelkoski/vite-plugin-node-polyfills
$ yarn add buffer
```

最后，确保在文件顶部的 `main.tsx` 中导入 `buffer`

```typescript
import { Buffer } from "buffer";

if (!window.Buffer) {
    window.Buffer = Buffer; // Optional, for packages expecting Buffer to be global
}
```

### 4. 使用状态管理

React 有许多不同的状态管理器，选择您要使用的并安装它。您可以使用内置的 `Context API` 进行状态管理，而无需安装第三方解决方案。首选的第三方状态管理器是 `Redux` 和 `Zustand`。

```bash
$ yarn add zustand
```

### 5. vite.config.ts

最后一步是配置 Vite 以使用我们之前安装的 `node-polyfills`。

打开 `vite.config.ts` 并在 `plugins` 数组中添加 `node-polyfills`。

您的配置应如下所示：

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import { nodePolyfills } from "@bangjelkoski/vite-plugin-node-polyfills";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), nodePolyfills({ protocolImports: true })],
  define: {
    global: "globalThis",
  },
  resolve: {
    alias: {
      // others
      buffer: "buffer/",
    },
  },
  optimizeDeps: {
    include: ["buffer"],
  },
});
```

### 8. 启动我们的应用

最后，您可以使用 `yarn dev` 在本地启动应用，或使用 `yarn build` 构建生产版本，您可以将其部署到任何静态页面托管服务，如 Netlify、Vercel 等。
