// 用 dsh-m 自带的校验器检查 registry.json，保证本索引能被 dsh-m 直接加载。
import { readFile } from 'node:fs/promises';
import { validateRegistry } from '../node_modules/dsh-m/lib/core/registry.js';

const file = new URL('../registry.json', import.meta.url);
const raw = JSON.parse(await readFile(file, 'utf8'));
const { ok, errors } = validateRegistry(raw);

if (!ok) {
  console.error('registry.json 校验失败：');
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`registry.json 校验通过，共 ${raw.plugins.length} 个插件。`);
