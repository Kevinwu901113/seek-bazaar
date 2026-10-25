#!/usr/bin/env bash
# 用官方生成器把来源列表生成为索引。市场标题、描述、缓存位置只在这里定义。
#
# 用法：DSH_DIR=<DSH checkout> scripts/generate.sh [来源列表] [输出 index.json]
# 默认读写仓库根目录的 plugins.txt 和 index.json。
# 退出码沿用生成器：0 全部成功，1 有来源读取失败，2 列表或参数无效。
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
abspath() { mkdir -p "$(dirname "$1")" && echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; }

input="$(abspath "${1:-$root/plugins.txt}")"
output="$(abspath "${2:-$root/index.json}")"
: "${DSH_DIR:?需要设置 DSH_DIR 指向已安装生成器的 DSH checkout}"

cd "$DSH_DIR"
exec pnpm --silent --filter @deepseek-ai/dsh-plugin-market-generator start \
  --input "$input" \
  --output "$output" \
  --cache "$root/.plugin-market-cache" \
  --title "Seek Bazaar" \
  --description "DeepSeek Harness 插件市场"
