import { cpSync, existsSync, lstatSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, symlinkSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const skillsRoot = path.join(repoRoot, 'skills');

function parseArgs(argv) {
  const args = {
    apply: false,
    all: false,
    copy: false,
    replace: false,
    prefix: '',
    codexHome: process.env.CODEX_HOME || path.join(os.homedir(), '.codex'),
    names: []
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--apply') args.apply = true;
    else if (arg === '--all') args.all = true;
    else if (arg === '--copy') args.copy = true;
    else if (arg === '--replace') args.replace = true;
    else if (arg === '--prefix') args.prefix = argv[++i] ?? '';
    else if (arg === '--codex-home') args.codexHome = argv[++i] ?? args.codexHome;
    else if (arg === '--name') args.names.push(argv[++i] ?? '');
    else if (arg === '--help' || arg === '-h') args.help = true;
    else args.names.push(arg);
  }

  args.names = args.names.filter(Boolean);
  return args;
}

function printHelp() {
  console.log(`Usage:
  npm run aiwiki:link-codex -- --all [--apply] [--replace] [--prefix aiwiki-gen-]
  npm run aiwiki:link-codex -- --name powershell-script-authoring --apply

Options:
  --all             Select every SKILL.md folder under skills/.
  --name <value>    Select by frontmatter name or relative skill folder path.
  --copy            Copy files instead of creating Windows directory junctions.
  --replace         Replace an existing destination folder.
  --apply           Make changes. Without this, the command is a dry run.
  --codex-home DIR  Override CODEX_HOME or ~/.codex.
  --prefix VALUE    Prefix destination folder names.
`);
}

function parseFrontmatterName(skillPath) {
  let text = '';
  try {
    text = readFileSync(skillPath, 'utf8');
  } catch {
    return '';
  }
  const match = /^name:\s*["']?([^"'\r\n]+)/m.exec(text);
  return match?.[1]?.trim() ?? '';
}

function walkSkillDirs(root, current = root) {
  const dirs = [];
  const skillPath = path.join(current, 'SKILL.md');
  if (existsSync(skillPath)) {
    dirs.push(current);
  }
  for (const entry of readdirSync(current, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      dirs.push(...walkSkillDirs(root, path.join(current, entry.name)));
    }
  }
  return dirs;
}

function relativeDir(skillDir) {
  return path.relative(skillsRoot, skillDir).replaceAll(path.sep, '/');
}

function destinationName(skillDir, prefix) {
  const rel = relativeDir(skillDir);
  const parts = rel.split('/');
  const base = parts.length === 1 ? parts[0] : parts.join('__');
  return `${prefix}${base}`;
}

function selectedSkillDirs(args) {
  if (!existsSync(skillsRoot)) {
    throw new Error(`skills root not found: ${skillsRoot}`);
  }

  const allSkillDirs = walkSkillDirs(skillsRoot).sort((a, b) => relativeDir(a).localeCompare(relativeDir(b)));
  if (args.all) {
    return allSkillDirs;
  }

  if (args.names.length === 0) {
    throw new Error('Pass --all or at least one --name value. Dry-run is still the default.');
  }

  const requested = new Set(args.names.map((name) => name.toLowerCase()));
  return allSkillDirs.filter((skillDir) => {
    const rel = relativeDir(skillDir).toLowerCase();
    const name = parseFrontmatterName(path.join(skillDir, 'SKILL.md')).toLowerCase();
    return requested.has(rel) || requested.has(name) || requested.has(path.basename(skillDir).toLowerCase());
  });
}

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const codexSkillsRoot = path.join(path.resolve(args.codexHome), 'skills');
const skillDirs = selectedSkillDirs(args);
if (skillDirs.length === 0) {
  throw new Error('No matching skill directories found.');
}

console.log('AI Wiki repo skill Codex linker');
console.log(`Repo skills:  ${skillsRoot}`);
console.log(`Codex skills: ${codexSkillsRoot}`);
console.log(`Mode:         ${args.copy ? 'copy' : 'junction'}`);
console.log(`Apply:        ${args.apply}`);
console.log(`Selected:     ${skillDirs.length}`);

if (args.apply) {
  mkdirSync(codexSkillsRoot, { recursive: true });
}

for (const skillDir of skillDirs) {
  const dest = path.join(codexSkillsRoot, destinationName(skillDir, args.prefix));
  const exists = existsSync(dest);
  console.log(`${args.apply ? 'LINK' : 'DRYRUN'}: ${relativeDir(skillDir)} -> ${dest}`);

  if (!args.apply) continue;

  if (exists) {
    if (!args.replace) {
      console.log(`  skipped existing destination; pass --replace to overwrite`);
      continue;
    }
    const stats = lstatSync(dest);
    if (!stats.isDirectory() && !stats.isSymbolicLink()) {
      throw new Error(`refusing to replace non-directory destination: ${dest}`);
    }
    rmSync(dest, { recursive: true, force: true });
  }

  if (args.copy) {
    cpSync(skillDir, dest, { recursive: true });
  } else {
    symlinkSync(skillDir, dest, 'junction');
  }
}
