# seek-bazaar

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)（DSH）插件市场索引。

索引文件 [`registry.json`](registry.json) 采用 [dsh-m](https://github.com/iasiv5/dsh-m) 的 registry v1 格式，可以直接作为 dsh-m 的自定义索引源使用。

## 使用

1. 安装 dsh-m：

   ```bash
   dsh plugin --profile web add dsh-m
   ```

2. 打开 DSH 侧栏「插件市场」→ 设置页，把下面任一地址填进自定义索引源，点「Validate & apply」：

   - GitHub raw：`https://raw.githubusercontent.com/suj1e/seek-bazaar/main/registry.json`
   - jsDelivr 镜像：`https://cdn.jsdelivr.net/gh/suj1e/seek-bazaar@main/registry.json`

> 自定义索引源会**替换**官方清单而不是合并，所以本索引保留了 dsh-m 自身的条目，方便它继续升级。

## 收录插件

改 `registry.json`，在 `plugins` 数组里加一条，然后提 PR：

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "description": "一句话说明插件做什么",
  "category": "essentials",
  "tags": ["标签"],
  "source": "npm",
  "npm": "my-dsh-plugin",
  "github": "owner/repo",
  "homepage": "https://github.com/owner/repo"
}
```

| 字段 | 必填 | 说明 |
|---|---|---|
| `id` | 是 | 小写字母、数字、`.`、`_`、`-`，≤64 字符，全表唯一 |
| `name` | 是 | ≤100 字符 |
| `description` | 是 | ≤500 字符 |
| `category` | 是 | `essentials` / `cui-picks` / `self-dev` / `tencent-lighthouse` / `watchlist` |
| `tags` | 是 | 字符串数组，≤10 个，每个 ≤30 字符 |
| `source` | 是 | `npm` 或 `github` |
| `npm` | source=npm 时必填 | 包名，不带版本号 |
| `github` | source=github 时必填 | `owner/repo` |
| `homepage` / `icon` | 否 | HTTPS 地址 |
| `alsoCategories` | 否 | 次级分类，取值同 `category`，不能与主分类重复 |
| `verified` | 否 | 实测通过的 DSH 版本，精确 semver 数组 |

dsh-m 对清单是严格校验的：出现未知字段或任何一条不合法，整份清单都会被拒绝。提交前请先本地校验：

```bash
npm install --ignore-scripts && npm run validate
```

CI 会对每个 PR 跑同样的校验。

## 许可

[MIT](LICENSE)
