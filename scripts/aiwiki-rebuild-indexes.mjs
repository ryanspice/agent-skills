import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const defaultAiWikiRoot = 'S:\\OneDrive\\Obsidan\\AI-Wiki';
const repoSourceRootRel = '04_skills/agent-skills/skills';
const repoSourceSlug = 'ryanspice-agent-skills';

function parseArgs(argv) {
  const args = {
    aiWikiRoot: process.env.AIWIKI_ROOT || defaultAiWikiRoot,
    apply: false,
    backup: true
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--ai-wiki-root') args.aiWikiRoot = argv[++i] ?? args.aiWikiRoot;
    else if (arg === '--apply') args.apply = true;
    else if (arg === '--no-backup') args.backup = false;
    else if (arg === '--help' || arg === '-h') args.help = true;
  }

  return args;
}

function printHelp() {
  console.log(`Usage:
  npm run aiwiki:rebuild-indexes -- --apply
  node scripts/aiwiki-rebuild-indexes.mjs --ai-wiki-root S:\\OneDrive\\Obsidan\\AI-Wiki --apply

Without --apply, this prints a dry-run summary and writes nothing.
`);
}

function toPosix(filePath) {
  return filePath.replaceAll(path.sep, '/');
}

function relPath(root, filePath) {
  return toPosix(path.relative(root, filePath));
}

function nowIso() {
  return new Date().toISOString();
}

function git(args, cwd) {
  return execFileSync('git', ['-C', cwd, ...args], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe']
  }).trim();
}

function parseScalar(value) {
  const trimmed = value.trim();
  if (!trimmed) return '';
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    const inner = trimmed.slice(1, -1).trim();
    if (!inner) return [];
    return inner.split(',').map((item) => item.trim().replace(/^["']|["']$/g, '')).filter(Boolean);
  }
  return trimmed.replace(/^["']|["']$/g, '');
}

function parseFrontmatter(skillPath) {
  let text = '';
  try {
    text = readFileSync(skillPath, 'utf8');
  } catch {
    return {};
  }

  const normalized = text.replaceAll('\r\n', '\n');
  if (!normalized.startsWith('---\n')) return {};
  const end = normalized.indexOf('\n---', 4);
  if (end === -1) return {};

  const data = {};
  for (const rawLine of normalized.slice(4, end).split('\n')) {
    const match = /^([A-Za-z0-9_-]+):\s*(.*)$/.exec(rawLine.trim());
    if (!match) continue;
    data[match[1]] = parseScalar(match[2]);
  }
  return data;
}

function versionParts(version) {
  return String(version || '')
    .match(/\d+/g)
    ?.slice(0, 4)
    .map((part) => Number.parseInt(part, 10)) ?? [];
}

function compareVersionDesc(a, b) {
  const aa = versionParts(a);
  const bb = versionParts(b);
  const len = Math.max(aa.length, bb.length);
  for (let i = 0; i < len; i += 1) {
    const av = aa[i] ?? 0;
    const bv = bb[i] ?? 0;
    if (av !== bv) return bv - av;
  }
  return 0;
}

function shouldSkipPath(filePath) {
  const normalized = toPosix(filePath).toLowerCase();
  return [
    '/.git/',
    '/.github/',
    '/node_modules/',
    '/archive/',
    '/deprecated/',
    '/candidate-import-snapshots/',
    '/generated-duplicates/',
    '.bak-'
  ].some((pattern) => normalized.includes(pattern));
}

function walkSkillFiles(root) {
  const files = [];
  if (!existsSync(root)) return files;
  for (const entry of readdirSync(root)) {
    const fullPath = path.join(root, entry);
    if (shouldSkipPath(fullPath)) continue;
    const stats = statSync(fullPath);
    if (stats.isDirectory()) {
      files.push(...walkSkillFiles(fullPath));
    } else if (entry === 'SKILL.md') {
      files.push(fullPath);
    }
  }
  return files;
}

function entryForSkill({ aiWikiRoot, sourceRoot, sourceRootRel, shelf, scope, skillPath }) {
  const fm = parseFrontmatter(skillPath);
  const pathRelToSource = relPath(sourceRoot, skillPath);
  const skillDirRel = pathRelToSource.replace(/\/SKILL\.md$/, '');
  const pathRelToWiki = `${sourceRootRel}/${pathRelToSource}`;
  const name = String(fm.name || fm.title || path.basename(path.dirname(skillPath)));
  const project = scope === 'project' ? pathRelToSource.split('/')[0] : null;
  const descriptorPath = path.join(path.dirname(skillPath), 'mcp-skill.json');

  return {
    slug: name,
    name,
    title: String(fm.title || name),
    version: String(fm.version || ''),
    type: String(fm.type || (scope === 'project' ? 'project-agent-skill' : 'universal-agent-skill')),
    status: String(fm.status || 'active'),
    scope,
    shelf,
    project,
    source_slug: shelf === 'repo' ? repoSourceSlug : shelf,
    path: pathRelToWiki,
    descriptor: existsSync(descriptorPath) ? `${sourceRootRel}/${relPath(sourceRoot, descriptorPath)}` : null,
    description: String(fm.description || fm.summary || ''),
    platforms: Array.isArray(fm.platforms) ? fm.platforms : [],
    tags: Array.isArray(fm.tags) ? fm.tags : [],
    relative_skill_dir: skillDirRel,
    selected_by_default: false,
    duplicate_reason: ''
  };
}

function collectEntries(aiWikiRoot) {
  const sources = [
    {
      shelf: 'repo',
      scope: 'repo',
      sourceRootRel: repoSourceRootRel,
      sourceRoot: path.join(aiWikiRoot, ...repoSourceRootRel.split('/'))
    },
    {
      shelf: 'universal',
      scope: 'universal',
      sourceRootRel: '04_skills/universal',
      sourceRoot: path.join(aiWikiRoot, '04_skills', 'universal')
    },
    {
      shelf: 'projects',
      scope: 'project',
      sourceRootRel: '04_skills/projects',
      sourceRoot: path.join(aiWikiRoot, '04_skills', 'projects')
    }
  ];

  const entries = [];
  for (const source of sources) {
    for (const skillPath of walkSkillFiles(source.sourceRoot).sort()) {
      entries.push(entryForSkill({ aiWikiRoot, ...source, skillPath }));
    }
  }

  return entries.sort((a, b) => a.path.localeCompare(b.path));
}

function selectionScore(entry) {
  const copyPenalty = / - copy(\/|$)/i.test(entry.path) ? 100 : 0;
  const shelfPriority = entry.shelf === 'repo' ? 0 : entry.shelf === 'universal' ? 20 : 40;
  const nestingPenalty = entry.shelf === 'repo' ? entry.relative_skill_dir.split('/').length : 0;
  return copyPenalty + shelfPriority + nestingPenalty;
}

function chooseDefaultEntries(entries) {
  const byName = new Map();
  for (const entry of entries) {
    if (!byName.has(entry.name)) byName.set(entry.name, []);
    byName.get(entry.name).push(entry);
  }

  const duplicates = [];
  for (const [name, group] of byName.entries()) {
    const sorted = [...group].sort((a, b) => {
      const score = selectionScore(a) - selectionScore(b);
      if (score !== 0) return score;
      const version = compareVersionDesc(a.version, b.version);
      if (version !== 0) return version;
      return a.path.length - b.path.length || a.path.localeCompare(b.path);
    });

    const winner = sorted[0];
    winner.selected_by_default = true;
    for (const loser of sorted.slice(1)) {
      loser.selected_by_default = false;
      loser.duplicate_reason = `default selection uses ${winner.path}`;
    }

    if (group.length > 1) {
      duplicates.push({
        name,
        selected_path: winner.path,
        paths: sorted.map((entry) => entry.path)
      });
    }
  }

  return {
    active: entries.filter((entry) => entry.selected_by_default).sort((a, b) => a.name.localeCompare(b.name) || a.path.localeCompare(b.path)),
    duplicates: duplicates.sort((a, b) => a.name.localeCompare(b.name))
  };
}

function activeEntry(entry) {
  return {
    slug: entry.slug,
    title: entry.title,
    shelf: entry.shelf,
    scope: entry.scope,
    project: entry.project || '',
    path: entry.path,
    description: entry.description,
    status: entry.status,
    type: entry.type,
    tags: entry.tags,
    source_slug: entry.source_slug
  };
}

function backupExisting(filePath) {
  if (!existsSync(filePath)) return;
  const stamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14);
  copyFileSync(filePath, `${filePath}.bak-${stamp}`);
}

function writeJson(filePath, payload, { apply, backup }) {
  if (!apply) return;
  mkdirSync(path.dirname(filePath), { recursive: true });
  if (backup) backupExisting(filePath);
  writeFileSync(filePath, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
}

function repoManifest(aiWikiRoot, entries) {
  const cloneRoot = path.join(aiWikiRoot, '04_skills', 'agent-skills');
  const branch = git(['branch', '--show-current'], cloneRoot);
  const commit = git(['rev-parse', '--short=12', 'HEAD'], cloneRoot);
  const origin = git(['remote', 'get-url', 'origin'], cloneRoot);
  const repoEntries = entries.filter((entry) => entry.shelf === 'repo');
  return {
    schema_version: '1.0.0',
    updated_at: nowIso(),
    source_slug: repoSourceSlug,
    source_type: 'owned-repo',
    repository_url: origin,
    branch,
    commit,
    local_path: '04_skills/agent-skills',
    source_root: repoSourceRootRel,
    provenance_manifest_path: '04_skills/agent-skills/skills/provenance.json',
    skill_document_count: repoEntries.length,
    selected_default_count: repoEntries.filter((entry) => entry.selected_by_default).length,
    notes: 'Owned Ryan-maintained skill repository consumed by the AI Wiki.'
  };
}

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const aiWikiRoot = path.resolve(args.aiWikiRoot);
const cloneRoot = path.join(aiWikiRoot, '04_skills', 'agent-skills');
if (!existsSync(aiWikiRoot)) {
  throw new Error(`AI Wiki root not found: ${aiWikiRoot}`);
}
if (!existsSync(cloneRoot)) {
  throw new Error(`agent-skills clone not found: ${cloneRoot}`);
}

const entries = collectEntries(aiWikiRoot);
const { active, duplicates } = chooseDefaultEntries(entries);
const generatedAt = nowIso();
const indexRoot = path.join(aiWikiRoot, '03_indexes', 'skills');
const registryPath = path.join(indexRoot, 'skills-registry.json');
const activePath = path.join(indexRoot, 'active-skills.json');
const validationPath = path.join(indexRoot, 'skill-registry-validation-report.json');
const sourceManifestPath = path.join(indexRoot, 'sources', 'ryanspice-agent-skills.json');
const projectRoot = path.join(indexRoot, 'project-skills');

const registry = {
  schema_version: '1.1.0',
  generated_at: generatedAt,
  ai_wiki_root: toPosix(aiWikiRoot),
  skill_roots: [
    repoSourceRootRel,
    '04_skills/universal',
    '04_skills/projects'
  ],
  duplicate_policy: 'Prefer repo-backed skills, then universal, then project overlays; choose highest version and exclude obvious copy folders by default.',
  skills: entries
};

const activeIndex = {
  version: '0.2.0',
  generated: generatedAt,
  policy_path: '03_indexes/skills/skill-scan-policy.json',
  skill_count: active.length,
  counts: active.reduce((acc, entry) => {
    acc[entry.shelf] = (acc[entry.shelf] || 0) + 1;
    if (entry.project) acc[entry.project] = (acc[entry.project] || 0) + 1;
    return acc;
  }, {}),
  skills: active.map(activeEntry)
};

const validation = {
  version: '0.2.0',
  generated: generatedAt,
  policy_path: '03_indexes/skills/skill-scan-policy.json',
  include_roots: registry.skill_roots,
  source_counts: entries.reduce((acc, entry) => {
    acc[entry.shelf] = (acc[entry.shelf] || 0) + 1;
    return acc;
  }, {}),
  active_count: active.length,
  duplicate_group_count: duplicates.length,
  duplicate_groups: duplicates,
  deprecated_roots_absent: ['legacy local-created shelf'],
  status: 'ok'
};

const byProject = new Map();
for (const entry of entries.filter((item) => item.scope === 'project')) {
  if (!entry.project) continue;
  if (!byProject.has(entry.project)) byProject.set(entry.project, []);
  byProject.get(entry.project).push(entry);
}

console.log('AI Wiki skill index rebuild');
console.log(`AI Wiki:        ${aiWikiRoot}`);
console.log(`Repo clone:     ${cloneRoot}`);
console.log(`All skills:     ${entries.length}`);
console.log(`Active default: ${active.length}`);
console.log(`Duplicates:     ${duplicates.length}`);
console.log(`Apply:          ${args.apply}`);

writeJson(registryPath, registry, args);
writeJson(activePath, activeIndex, args);
writeJson(validationPath, validation, args);
writeJson(sourceManifestPath, repoManifest(aiWikiRoot, entries), args);

for (const [project, projectEntries] of byProject.entries()) {
  const projectPayload = {
    version: '0.2.0',
    generated: generatedAt,
    project,
    skill_count: projectEntries.length,
    skills: projectEntries.sort((a, b) => a.name.localeCompare(b.name)).map(activeEntry)
  };
  writeJson(path.join(projectRoot, `${project}-active-skills.json`), projectPayload, args);
}

if (!args.apply) {
  console.log('[DRY RUN] No files written. Pass --apply to write indexes.');
} else {
  console.log(`Wrote ${registryPath}`);
  console.log(`Wrote ${activePath}`);
  console.log(`Wrote ${validationPath}`);
  console.log(`Wrote ${sourceManifestPath}`);
}
