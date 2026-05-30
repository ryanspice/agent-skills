import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();
const skillsRoot = path.join(repoRoot, 'skills');
const manifestPath = path.join(skillsRoot, 'provenance.json');
const allowedOrigins = new Set(['original', 'modified']);
const blockedPathPatterns = [
  /S:[\\/]+OneDrive[\\/]+Obsidan/i,
  /S:\/OneDrive\/Obsidan/i,
  /B:[\\/]+Dev/i,
  /B:\/Dev/i,
  /B:[\\/]+Search/i,
  /B:\/Search/i,
  /B:[\\/]+Temp[\\/]+@Browser/i,
  /B:\/Temp\/@Browser/i,
  /B:[\\/]+AI-Wiki/i,
  /B:\/AI-Wiki/i,
  /C:[\\/]+Users[\\/]+/i
];
const excludedExportFiles = [
  /\.zip$/i,
  /\.tar$/i,
  /\.gz$/i,
  /\.7z$/i,
  /\.log$/i,
  /\.pid$/i,
  /\.sha256$/i,
  /\.bak-/i,
  /(^|[\\/])\.thoughts$/i,
  /(^|[\\/])\.runtime([\\/]|$)/i
];

function fail(message) {
  errors.push(message);
}

function toRepoPath(filePath) {
  return path.relative(repoRoot, filePath).replaceAll(path.sep, '/');
}

function walkFiles(root) {
  const files = [];
  for (const entry of readdirSync(root)) {
    const fullPath = path.join(root, entry);
    const stats = statSync(fullPath);
    if (stats.isDirectory()) {
      files.push(...walkFiles(fullPath));
    } else {
      files.push(fullPath);
    }
  }
  return files;
}

function parseFrontmatter(text, repoPath) {
  if (!text.startsWith('---\n') && !text.startsWith('---\r\n')) {
    fail(`${repoPath}: missing YAML frontmatter`);
    return new Map();
  }

  const normalized = text.replaceAll('\r\n', '\n');
  const end = normalized.indexOf('\n---', 4);
  if (end === -1) {
    fail(`${repoPath}: malformed YAML frontmatter`);
    return new Map();
  }

  const fields = new Map();
  const frontmatter = normalized.slice(4, end).split('\n');
  for (const line of frontmatter) {
    const match = /^([A-Za-z0-9_-]+):\s*(.*)$/.exec(line);
    if (!match) continue;
    const [, key, rawValue] = match;
    fields.set(key, rawValue.trim().replace(/^"(.*)"$/, '$1'));
  }

  return fields;
}

function validateNoBlockedRoots(repoPath, text) {
  for (const pattern of blockedPathPatterns) {
    if (pattern.test(text)) {
      fail(`${repoPath}: contains a local absolute root that should be placeholder-normalized`);
    }
  }
}

const errors = [];

if (!existsSync(manifestPath)) {
  fail('skills/provenance.json is missing');
}

const manifest = existsSync(manifestPath)
  ? JSON.parse(readFileSync(manifestPath, 'utf8'))
  : { skills: [] };

if (manifest.schema_version !== '1.0.0') {
  fail('skills/provenance.json: expected schema_version 1.0.0');
}

if (!Array.isArray(manifest.skills)) {
  fail('skills/provenance.json: expected skills array');
}

const manifestByPath = new Map();
for (const skill of manifest.skills ?? []) {
  if (!skill.path) {
    fail('skills/provenance.json: skill entry missing path');
    continue;
  }
  if (manifestByPath.has(skill.path)) {
    fail(`skills/provenance.json: duplicate path ${skill.path}`);
  }
  manifestByPath.set(skill.path, skill);

  if (!allowedOrigins.has(skill.origin)) {
    fail(`${skill.path}: invalid manifest origin ${skill.origin}`);
  }
  if (!skill.source_path) {
    fail(`${skill.path}: manifest missing source_path`);
  }
  if (!skill.note) {
    fail(`${skill.path}: manifest missing note`);
  }
  if (skill.origin === 'modified' && !skill.upstream) {
    fail(`${skill.path}: modified skills must identify upstream/source reference`);
  }
}

const allFiles = existsSync(skillsRoot) ? walkFiles(skillsRoot) : [];
const skillFiles = allFiles
  .map(toRepoPath)
  .filter((repoPath) => repoPath.endsWith('/SKILL.md') || repoPath.endsWith('.SKILL.md'));
const generatedSkillFiles = skillFiles
  .filter((repoPath) => repoPath.startsWith('skills/aiwiki-generated/'));

if (generatedSkillFiles.length < 50) {
  fail(`expected at least 50 generated skill files after AI Wiki import, found ${generatedSkillFiles.length}`);
}

if (!manifest.skills?.some((skill) => skill.origin === 'modified')) {
  fail('expected at least one modified skill in the provenance index');
}

for (const repoPath of generatedSkillFiles) {
  const skill = manifestByPath.get(repoPath);
  if (!skill) {
    fail(`${repoPath}: missing from skills/provenance.json`);
    continue;
  }

  const text = readFileSync(path.join(repoRoot, ...repoPath.split('/')), 'utf8');
  validateNoBlockedRoots(repoPath, text);

  const fields = parseFrontmatter(text, repoPath);
  if (!fields.get('name') && !fields.get('title')) {
    fail(`${repoPath}: frontmatter must include name or title`);
  }
  if (fields.get('provenance_origin') !== skill.origin) {
    fail(`${repoPath}: provenance_origin does not match manifest`);
  }
  if (fields.get('provenance_source_path') !== skill.source_path) {
    fail(`${repoPath}: provenance_source_path does not match manifest`);
  }
  if (!fields.get('provenance_note')) {
    fail(`${repoPath}: missing provenance_note`);
  }
  if (skill.origin === 'modified' && !fields.get('provenance_upstream')) {
    fail(`${repoPath}: modified skill missing provenance_upstream`);
  }
}

for (const skillPath of manifestByPath.keys()) {
  if (!skillPath.startsWith('skills/aiwiki-generated/')) {
    fail(`${skillPath}: provenance manifest should only index generated exports`);
  }
  if (!generatedSkillFiles.includes(skillPath)) {
    fail(`${skillPath}: listed in manifest but SKILL.md was not found`);
  }
}

for (const filePath of allFiles) {
  const repoPath = toRepoPath(filePath);
  if (repoPath.startsWith('skills/aiwiki-generated/')) {
    for (const pattern of excludedExportFiles) {
      if (pattern.test(repoPath)) {
        fail(`${repoPath}: excluded generated artifact should not be exported`);
      }
    }
  }

  if (!/\.(png)$/i.test(repoPath)) {
    const text = readFileSync(filePath, 'utf8');
    validateNoBlockedRoots(repoPath, text);
  }
}

if (errors.length > 0) {
  console.error(`Skill validation failed with ${errors.length} issue(s):`);
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log(`Validated ${generatedSkillFiles.length} generated skills with provenance labels.`);
