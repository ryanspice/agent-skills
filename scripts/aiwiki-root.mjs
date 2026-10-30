import { existsSync } from 'node:fs';
import path from 'node:path';

// An explicit machine-local setting wins. A canonical Wiki checkout can
// otherwise discover its root without embedding a user's drive or profile.
export function findAiWikiRoot(repoRoot, explicitRoot = process.env.AIWIKI_ROOT) {
  if (explicitRoot) return path.resolve(explicitRoot);
  const shelf = path.dirname(repoRoot);
  if (path.basename(repoRoot).toLowerCase() !== 'agent-skills' ||
      path.basename(shelf).toLowerCase() !== '04_skills') return null;
  const wiki = path.dirname(shelf);
  return existsSync(path.join(wiki, '03_Indexes')) || existsSync(path.join(wiki, '03_indexes')) ? wiki : null;
}

export function requireAiWikiRoot(repoRoot, explicitRoot) {
  const root = findAiWikiRoot(repoRoot, explicitRoot);
  if (!root) throw new Error('AI Wiki root not found; set AIWIKI_ROOT or pass --ai-wiki-root where supported.');
  return root;
}
