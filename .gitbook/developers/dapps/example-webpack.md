# Webpack 示例

该[示例](https://github.com/biya-coin/biyachain-ts-webpack-example)基于 [Cosmos 交易处理部分](../developers-native/transactions/cosmos.md)。

## 运行示例

克隆项目仓库：

```
git clone https://github.com/biya-coin/biyachain-ts-webpack-example.git
```

确保已安装 npm 并安装依赖项：

```
cd biyachain-ts-webpack-example && npm install
```

运行示例：

```
npm start
....
<i> [webpack-dev-server] Project is running at:
<i> [webpack-dev-server] Loopback: http://localhost:8080/, http://[::1]:8080/
....
```

在浏览器中访问 http://localhost:8080/。如果您已设置 Keplr 钱包并连接到 Biya Chain 测试网，您应该会看到"确认交易"弹出窗口。

## 它是如何工作的？

交易逻辑在 `src/sendTx.tx` 中，由 `src/index.html` 加载。Webpack 用于将所有内容整合在一起并在本地服务器端点上提供服务。

`webpack.config.js` 文件配置 Webpack 从 `./src/sendTx.ts` 开始打包 TypeScript 应用程序，使用 `ts-loader` 转译 TypeScript 文件，并包含适当处理 `.js` 和 `.json` 文件的规则。它使用 `fallback` 选项解析 Node.js 核心模块的浏览器兼容版本，在浏览器环境中启用 `buffer`、`crypto` 和 `stream` 等模块。该配置利用 `HtmlWebpackPlugin` 基于 `src/index.html` 生成 HTML 文件，并使用 `ProvidePlugin` 自动全局加载 `Buffer` 和 `process` 变量。打包输出命名为 `bundle.js` 并放置在 `dist` 目录中，`devServer` 设置为从 `./dist` 提供内容以用于开发目的。
