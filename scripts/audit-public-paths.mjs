import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Detect personal profile paths and absolute OneDrive paths without printing
// their values. Relative paths and documented placeholders remain allowed.
export function hasPersonalPath(text) {
  return /[a-z]:[\\/]+users[\\/]+(?!<)[^\\/\s"'`]+/i.test(text) ||
    /[a-z]:[\\/]+(?:[^\r\n"'`]*[\\/]+)?onedrive[\\/]+/i.test(text) ||
    /(?:^|[^\w])\/(?:home|Users)\/(?!<)[a-z0-9._-]+(?:\/|(?=[\s"'`]|$))/im.test(text);
}

export function auditPublicPaths(root) {
  const output = execFileSync('git', ['-C', root, 'ls-files', '--cached', '--others', '--exclude-standard', '-z'], { encoding: 'utf8' });
  const names = [...new Set(output.split('\0').filter(Boolean))];
  const textFile = /\.(?:md|json|jsonc|ya?ml|mjs|cjs|js|ts|ps1|psm1|psd1|txt|toml|sh)$/i;
  return names.filter((name) => {
    if (!textFile.test(name)) return false;
    const file = path.join(root, name);
    return existsSync(file) && hasPersonalPath(readFileSync(file, 'utf8'));
  });
}

const current = fileURLToPath(import.meta.url);
if (process.argv[1] && path.resolve(process.argv[1]) === current) {
  const root = path.resolve(path.dirname(current), '..');
  const findings = auditPublicPaths(root);
  if (findings.length) {
    console.error('Personal absolute paths found; replace them with portable references:');
    for (const name of findings) console.error(`- ${name}`);
    process.exitCode = 1;
  } else console.log('Public-path audit passed for Git-tracked and nonignored text files.');
}
