# seek-bazaar

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)（DSH）插件市场。

## 使用

在 DSH 里打开 **插件 → 发现 → 添加索引源**，填入：

```
https://raw.githubusercontent.com/suj1e/seek-bazaar/main/index.json
```

## 收录插件

提 PR，在 [`plugins.txt`](plugins.txt) 里加一行，npm 包名或 Git 仓库 URL 都可以（PR 会自动试跑生成器检查来源）：

```text
@scope/dsh-example
https://github.com/author/dsh-plugin
```

推送后 GitHub Actions 会用 DSH 官方的[索引生成器](https://github.com/deepseek-ai/deepseek-harness/tree/master/apps/plugin-market-generator)重新生成 [`index.json`](index.json)，每天也会自动刷新一次，以收录插件发布的新版本。

被收录的插件需要满足：

- `package.json` 里声明了 `dsh.bundle`；
- 声明了 `engines.dsh`（或依赖 `@deepseek-ai/dsh*` 的 `peerDependencies`）；
- 不是 `"private": true`。

索引格式见 DSH 的[插件市场文档](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/plugin-market.zh.md)。

## 许可

[MIT](LICENSE)
