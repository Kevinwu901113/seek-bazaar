# AGENTS.md

seek-bazaar 是 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)（DSH）的插件市场索引。仓库只存索引，不存插件代码；插件由作者在自己的仓库开发和发布。

## 文件

| 路径 | 说明 |
|---|---|
| `plugins.txt` | 收录列表，**唯一需要人工维护的文件**。每行一个 npm 包名或 Git 仓库 URL，`#` 开头为注释，空行忽略。 |
| `index.json` | DSH「发现」页读取的索引，由 CI 生成。**不要手改**，下次生成会被覆盖。 |
| `icons/` | 生成器写出的大图标（小图标内联在 `index.json`）。由 CI 生成，可能不存在。 |
| `scripts/generate.sh` | 调用官方生成器。市场标题、描述、缓存位置只在这里定义。 |
| `scripts/check-sources.sh` | PR 检查：新增来源必须能读取且至少产出一个插件。 |
| `.github/actions/setup-generator/` | 拉取固定版本的 DSH 并安装生成器，两个 workflow 共用。 |
| `.github/workflows/check.yml` | PR 检查。 |
| `.github/workflows/generate.yml` | 生成 `index.json` 并直接提交到 main。 |

## 流程

维护者唯一的手动操作是合并收录 PR，其余全自动。

1. 贡献者提 PR，在 `plugins.txt` 加一行。
2. `check.yml` 检查 PR：
   - 外部贡献者（非 OWNER / MEMBER / COLLABORATOR）的 PR 改了 `plugins.txt` 以外的文件即失败。
   - 运行 `check-sources.sh`：整份列表无效则失败；对每个新增来源单独跑生成器，读取失败或产出 0 个插件则失败。生成器对不合格插件只跳过不报错，这一步就是为了把它变成失败。
   - 用 `pull_request_target` 触发，工作流和脚本始终取自 main，只从 PR 读取 `plugins.txt`，所以 PR 无法通过修改脚本绕过检查。改动 `check.yml` 或脚本要合并到 main 后才生效。
3. 维护者合并后，`generate.yml` 重新生成 `index.json`，有变化时由 `github-actions[bot]` 直接提交到 main。

`generate.yml` 每天 03:00 UTC 也会运行一次，自动收录已收录插件新发布的版本。

有来源读取失败时，生成器保留该来源上一次的结果，照样提交，但任务最终标为失败以便通知。

bot 直接推送 main，所以若给 main 开分支保护，需要允许 GitHub Actions 推送，否则生成会失败。

## 发布

GitHub Pages 从 main 分支根目录发布（仓库设置里的 Deploy from a branch），main 每次有提交都会自动更新，无需 workflow。用户添加的索引源是 `https://suj1e.github.io/seek-bazaar/index.json`；图标相对这个地址解析，所以 `index.json` 和 `icons/` 必须留在仓库根目录。

站点首页由 Jekyll 从 README 渲染；网站图标是 `favicon.svg`，通过 `_includes/head-custom.html` 引入。

生成器只下载和读取文件，不安装、不执行插件代码。

## 生成器版本

两个 workflow 的 `env.DSH_REF` 固定了 DSH 仓库的 tag（目前 `dsh-v0.2.1-rc.3`），避免上游改动悄悄改变生成结果。升级时：

1. 在 [DSH releases](https://github.com/deepseek-ai/deepseek-harness/releases) 选新 tag；
2. 同时改 `check.yml` 和 `generate.yml` 里的 `DSH_REF`；
3. 若新版本要求的 Node 或 pnpm 版本变了（看 DSH 根目录 `package.json` 的 `engines.node` 和 `packageManager`），同步改 `setup-generator/action.yml`；
4. 推送后看 bot 提交的 `index.json` diff 是否符合预期。

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

插件本身需要满足：

- `package.json` 声明了 `dsh.bundle`，其 `patch` 指向文件；
- 声明了 `engines.dsh`，或通过 `@deepseek-ai/dsh*` 的 `peerDependencies` 声明兼容范围；
- 不是 `"private": true`；
- npm 来源：版本已发布且未弃用。Git 来源：默认分支或 `vX.Y.Z` / `<name>@X.Y.Z` 标签上的版本。

## 审核

`check sources` 通过即可合并：文件范围和来源有效性都已自动检查。剩下需要人判断的只有来源是否可信。索引内容是插件作者的自我声明，DSH 不做审核，留意冒用 `@deepseek-ai/dsh-*` 等官方名称的包。已收录插件之后发布的新版本会被自动收录，不再经过审核。

## 本地运行

需要 Node ≥24 和 pnpm 11，`DSH_REF` 与 workflow 保持一致：

```bash
git clone --depth 1 --branch dsh-v0.2.1-rc.3 https://github.com/deepseek-ai/deepseek-harness ../dsh
(cd ../dsh && pnpm install --filter "@deepseek-ai/dsh-plugin-market-generator..." --ignore-scripts)
DSH_DIR=../dsh scripts/generate.sh                 # 重新生成 index.json
DSH_DIR=../dsh scripts/check-sources.sh origin/main # 检查相对 main 新增的来源
```

`.plugin-market-cache/` 已被忽略，不要提交。

## 约定

- 文档用中文。
- 索引格式和生成规则以 DSH 官方文档为准：[插件市场指南](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/plugin-market.zh.md)、[索引格式](https://github.com/deepseek-ai/deepseek-harness/blob/master/.agents/notes/implemented/feature/2026-10-02-plugin-market-index-format.zh.md)、[生成器](https://github.com/deepseek-ai/deepseek-harness/tree/master/apps/plugin-market-generator)。
