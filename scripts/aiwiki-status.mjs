import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const defaultAiWikiRoot = 'S:\\OneDrive\\Obsidan\\AI-Wiki';
const expectedSourceRoot = '04_skills/agent-skills/skills';

function repoPath(filePath, root) {
  return path.relative(root, filePath).replaceAll(path.sep, '/');
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

function git(args, cwd) {
  return execFileSync('git', ['-C', cwd, ...args], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe']
  }).trim();
}

function loadJson(filePath) {
  return JSON.parse(readFileSync(filePath, 'utf8'));
}

const errors = [];
const aiWikiRoot = path.resolve(process.env.AIWIKI_ROOT || defaultAiWikiRoot);
const cloneRoot = path.join(aiWikiRoot, '04_skills', 'agent-skills');
const cloneSkillsRoot = path.join(cloneRoot, 'skills');
const policyPath = path.join(aiWikiRoot, '03_indexes', 'skills', 'skill-scan-policy.json');
const provenancePath = path.join(cloneSkillsRoot, 'provenance.json');

if (!existsSync(aiWikiRoot)) {
  errors.push(`AI Wiki root not found: ${aiWikiRoot}`);
}
if (!existsSync(cloneRoot)) {
  errors.push(`agent-skills clone not found: ${cloneRoot}`);
}
if (!existsSync(cloneSkillsRoot)) {
  errors.push(`agent-skills skill source root not found: ${cloneSkillsRoot}`);
}
if (!existsSync(policyPath)) {
  errors.push(`skill scan policy not found: ${policyPath}`);
}
if (!existsSync(provenancePath)) {
  errors.push(`repo provenance manifest not found: ${provenancePath}`);
}

let branch = '';
let commit = '';
let origin = '';
if (existsSync(cloneRoot)) {
  try {
    const inside = git(['rev-parse', '--is-inside-work-tree'], cloneRoot);
    if (inside !== 'true') {
      errors.push(`${cloneRoot} is not a Git work tree`);
    }
    branch = git(['branch', '--show-current'], cloneRoot);
    commit = git(['rev-parse', '--short=12', 'HEAD'], cloneRoot);
    origin = git(['remote', 'get-url', 'origin'], cloneRoot);
  } catch (error) {
    errors.push(`failed to read clone Git state: ${error.message}`);
  }
}

let skillFiles = [];
if (existsSync(cloneSkillsRoot)) {
  skillFiles = walkFiles(cloneSkillsRoot)
    .map((filePath) => repoPath(filePath, cloneSkillsRoot))
    .filter((filePath) => filePath.endsWith('/SKILL.md') || filePath === 'SKILL.md')
    .sort();
}
if (skillFiles.length < 50) {
  errors.push(`expected at least 50 repo-backed skill documents, found ${skillFiles.length}`);
}

let policy = null;
if (existsSync(policyPath)) {
  try {
    policy = loadJson(policyPath);
    const includeRoots = policy.include_roots ?? [];
    if (!includeRoots.includes(expectedSourceRoot)) {
      errors.push(`skill scan policy does not include ${expectedSourceRoot}`);
    }
    if (includeRoots.includes('04_skills/generated')) {
      errors.push('skill scan policy still includes deprecated 04_skills/generated');
    }
  } catch (error) {
    errors.push(`failed to parse skill scan policy: ${error.message}`);
  }
}

console.log('AI Wiki agent-skills status');
console.log(`AI Wiki:       ${aiWikiRoot}`);
console.log(`Clone:         ${cloneRoot}`);
console.log(`Origin:        ${origin || '(unreadable)'}`);
console.log(`Branch:        ${branch || '(unreadable)'}`);
console.log(`Commit:        ${commit || '(unreadable)'}`);
console.log(`Skill root:    ${expectedSourceRoot}`);
console.log(`Skill docs:    ${skillFiles.length}`);
console.log(`Policy file:   ${policyPath}`);
console.log(`Policy roots:  ${(policy?.include_roots ?? []).join(', ') || '(unreadable)'}`);

if (errors.length > 0) {
  console.error(`\nStatus failed with ${errors.length} issue(s):`);
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log('\nStatus ok.');
