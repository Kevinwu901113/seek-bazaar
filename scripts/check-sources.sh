#!/usr/bin/env bash
# 检查 plugins.txt 相对基准分支新增的来源：每个来源必须能读取，并且至少产出一个插件。
# 生成器对不合格的插件（没有 dsh.bundle、没有 engines.dsh 等）只跳过不报错，这里把它变成失败。
#
# 用法：DSH_DIR=<DSH checkout> scripts/check-sources.sh <基准 ref，如 origin/main>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
base="${1:?需要基准 ref，例如 origin/main}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# 去掉注释和空行，首尾去空白
normalize() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v -e '^$' -e '^#' | sort -u || true; }

git -C "$root" show "$base:plugins.txt" 2>/dev/null | normalize > "$tmp/base.txt" || true
normalize < "$root/plugins.txt" > "$tmp/head.txt"
comm -13 "$tmp/base.txt" "$tmp/head.txt" > "$tmp/added.txt"

# 整份列表先跑一遍：列表无效（退出码 2）直接失败
status=0
"$root/scripts/generate.sh" "$root/plugins.txt" "$tmp/full/index.json" || status=$?
if [ "$status" -eq 2 ]; then
  echo "::error file=plugins.txt::plugins.txt 无效，见上方生成器输出"
  exit 1
elif [ "$status" -ne 0 ]; then
  echo "::warning file=plugins.txt::有来源读取失败（可能是已有来源临时故障），见上方生成器输出"
fi

if [ ! -s "$tmp/added.txt" ]; then
  echo "没有新增来源。"
  exit 0
fi

failed=0
i=0
while IFS= read -r source; do
  i=$((i + 1))
  echo "::group::检查 $source"
  printf '%s\n' "$source" > "$tmp/one-$i.txt"
  status=0
  out="$("$root/scripts/generate.sh" "$tmp/one-$i.txt" "$tmp/one-$i/index.json" 2>&1)" || status=$?
  echo "$out"
  echo "::endgroup::"
  count="$(sed -nE 's/.*: ([0-9]+) plugin\(s\).*/\1/p' <<<"$out" | tail -1)"
  if [ "$status" -ne 0 ]; then
    echo "::error file=plugins.txt::$source 读取失败（退出码 $status）"
    failed=1
  elif [ "${count:-0}" -eq 0 ]; then
    echo "::error file=plugins.txt::$source 没有产出任何插件：检查 package.json 是否声明 dsh.bundle 和 engines.dsh，且不是 private"
    failed=1
  else
    echo "$source → $count 个插件"
  fi
done < "$tmp/added.txt"

exit "$failed"
