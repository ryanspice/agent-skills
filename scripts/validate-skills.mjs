import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();
const skillsRoot = path.join(repoRoot, 'skills');
const manifestPath = path.join(skillsRoot, 'provenance.json');
const allowedOrigins = new Set(['original', 'modified']);
const generatedBucketPath = ['skills', 'aiwiki-generated'].join('/');
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
  /C:[\\/]+Users[\\/]+/i,
  new RegExp(['SPICE', 'PC', '2023'].join('-'), 'i')
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

if (manifest.schema_version !== '1.2.0') {
  fail('skills/provenance.json: expected schema_version 1.2.0');
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
  if (!skill.credit) {
    fail(`${skill.path}: manifest missing credit`);
  }
  if (skill.origin === 'modified' && !skill.upstream) {
    fail(`${skill.path}: modified skills must identify upstream/source reference`);
  }
}

const allFiles = existsSync(skillsRoot) ? walkFiles(skillsRoot) : [];
const skillFiles = allFiles
  .map(toRepoPath)
  .filter((repoPath) => repoPath.endsWith('/SKILL.md') || repoPath.endsWith('.SKILL.md'));
const ingestedSkillFiles = [...manifestByPath.keys()].sort();

if (ingestedSkillFiles.length < 50) {
  fail(`expected at least 50 AI Wiki-ingested skill files, found ${ingestedSkillFiles.length}`);
}

if (!manifest.skills?.some((skill) => skill.origin === 'modified')) {
  fail('expected at least one modified skill in the provenance index');
}

for (const repoPath of ingestedSkillFiles) {
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
  if (fields.get('provenance_credit') !== skill.credit) {
    fail(`${repoPath}: provenance_credit does not match manifest`);
  }
  if (skill.origin === 'modified' && !fields.get('provenance_upstream')) {
    fail(`${repoPath}: modified skill missing provenance_upstream`);
  }
}

for (const skillPath of manifestByPath.keys()) {
  if (!skillPath.startsWith('skills/')) {
    fail(`${skillPath}: provenance manifest entries must live under skills/`);
  }
  if (skillPath.startsWith(`${generatedBucketPath}/`)) {
    fail(`${skillPath}: ingested skills should live directly under skills/, not ${generatedBucketPath}/`);
  }
  if (!skillFiles.includes(skillPath)) {
    fail(`${skillPath}: listed in manifest but SKILL.md was not found`);
  }
}

if (!Array.isArray(manifest.source_files)) {
  fail('skills/provenance.json: expected source_files array');
} else {
  const sourceFilePaths = new Set();
  for (const sourceFile of manifest.source_files) {
    if (!sourceFile.path) {
      fail('skills/provenance.json: source file entry missing path');
      continue;
    }
    sourceFilePaths.add(sourceFile.path);
    if (!sourceFile.path.startsWith('skills/')) {
      fail(`${sourceFile.path}: source file manifest entries must live under skills/`);
    }
    if (sourceFile.path.startsWith(`${generatedBucketPath}/`)) {
      fail(`${sourceFile.path}: source files should live directly under skills/, not ${generatedBucketPath}/`);
    }
    if (!sourceFile.source_path?.startsWith('04_skills/generated/')) {
      fail(`${sourceFile.path}: source file missing AI Wiki source path`);
    }
    if (!sourceFile.kind) {
      fail(`${sourceFile.path}: source file missing kind`);
    }
    if (!sourceFile.credit) {
      fail(`${sourceFile.path}: source file missing credit`);
    }
    if (!sourceFile.sha256) {
      fail(`${sourceFile.path}: source file missing sha256`);
    }
    const sourceFilePath = path.join(repoRoot, ...sourceFile.path.split('/'));
    if (!existsSync(sourceFilePath)) {
      fail(`${sourceFile.path}: listed in source_files but file was not found`);
    } else {
      const actualHash = createHash('sha256').update(readFileSync(sourceFilePath)).digest('hex');
      if (actualHash !== sourceFile.sha256) {
        fail(`${sourceFile.path}: sha256 does not match source_files manifest`);
      }
    }
  }

  if (manifest.source_file_count !== manifest.source_files.length) {
    fail('skills/provenance.json: source_file_count does not match source_files length');
  }
  if (manifest.skill_document_count !== ingestedSkillFiles.length) {
    fail('skills/provenance.json: skill_document_count does not match AI Wiki-ingested skill count');
  }
}

for (const filePath of allFiles) {
  const repoPath = toRepoPath(filePath);
  if (!/\.(png|zip|tar|gz|7z)$/i.test(repoPath)) {
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

console.log(`Validated ${ingestedSkillFiles.length} AI Wiki-ingested skills with provenance labels.`);
