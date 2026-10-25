# AGENTS.md

seek-bazaar 是 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)（DSH）的插件市场索引。仓库只存索引，不存插件代码；插件由作者在自己的仓库开发和发布。

## 文件

| 路径 | 说明 |
|---|---|
| `plugins.txt` | 收录列表，**唯一需要人工维护的文件**。每行一个 npm 包名或 Git 仓库 URL，`#` 开头为注释，空行忽略。 |
| `index.json` | DSH「发现」页读取的索引，由 CI 生成。**不要手改**，下次生成会被覆盖。 |
| `icons/` | 生成器写出的大图标（小图标内联在 `index.json`）。同样由 CI 生成，可能不存在。 |
| `.github/workflows/generate.yml` | 生成 `index.json` 的工作流。 |

## 工作流

`generate.yml` 拉取 DSH 仓库，运行官方的 [`plugin-market-generator`](https://github.com/deepseek-ai/deepseek-harness/tree/master/apps/plugin-market-generator)，以 `plugins.txt` 为输入写出 `index.json`。

- **推送到 main**（改动 `plugins.txt` 或工作流）、**每天 03:00 UTC**、**手动触发**：生成并在有变化时由 `github-actions[bot]` 提交回 main。定时运行用来收录插件新发布的版本。
- **PR**：只试跑生成器，不提交。生成器有来源读取失败时退出码为 1，PR 检查失败。

生成器只下载和读取文件，不安装、不执行插件代码。

## 收录插件

只改 `plugins.txt`，一行一个来源，追加到末尾：

```text
@scope/dsh-example
https://github.com/author/dsh-plugin
```

来源规则（违反会让生成器把整份列表判为无效）：

- Git URL 必须是 `https:`，至少两段路径，不带凭据、查询串、`#` 片段，不能是 `.tgz` / `.tar.gz`。
- npm 包名不带版本号或范围。
- 同一包名出现多次时，靠前的来源生效，所以不要重复收录。

插件本身需要满足以下条件才会出现在索引里，否则会被生成器跳过（不报错，只是没有条目）：

- `package.json` 声明了 `dsh.bundle`，其 `patch` 指向文件；
- 声明了 `engines.dsh`，或通过 `@deepseek-ai/dsh*` 的 `peerDependencies` 声明兼容范围；
- 不是 `"private": true`；
- npm 来源：版本已发布且未弃用。Git 来源：默认分支或 `vX.Y.Z` / `<name>@X.Y.Z` 标签上的版本。

## 审核 PR

合并收录 PR 前检查：

1. 只改了 `plugins.txt`，没有手改 `index.json`。
2. PR 检查通过。
3. 在 PR 检查日志的 `Generate index.json` 步骤里确认插件数比 main 上多了，没有新来源被静默跳过。
4. 来源可信：索引内容是插件作者的自我声明，DSH 不做审核。留意冒用 `@deepseek-ai/dsh-*` 等官方名称的包。

## 本地生成

需要 Node ≥24 和 pnpm 11：

```bash
git clone --depth 1 https://github.com/deepseek-ai/deepseek-harness ../dsh
cd ../dsh && pnpm install --filter "@deepseek-ai/dsh-plugin-market-generator..." --ignore-scripts
pnpm --filter @deepseek-ai/dsh-plugin-market-generator start \
  --input "$OLDPWD/plugins.txt" --output "$OLDPWD/index.json" \
  --cache "$OLDPWD/.plugin-market-cache" \
  --title "Seek Bazaar" --description "DeepSeek Harness 插件市场"
```

参数与 CI 保持一致；改了其中之一要同步另一处。`.plugin-market-cache/` 不要提交。

## 约定

- 文档用中文。
- 索引格式和生成规则以 DSH 官方文档为准：[插件市场指南](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/plugin-market.zh.md)、[索引格式](https://github.com/deepseek-ai/deepseek-harness/blob/master/.agents/notes/implemented/feature/2026-10-02-plugin-market-index-format.zh.md)。
