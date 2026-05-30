# Builder Handoff Prompt Template

Use skill: `gpt55-webapp-builder-codex-bridge`

Goal:
[Describe the local repo/build/package task.]

Environment:
- OS: Windows 11
- Shell: PowerShell 7 preferred
- Repo path: `[absolute path]`
- Downloads/staging path: `<DOWNLOADS_ROOT>`

Constraints:
- Produce a dry-run first for any file writes.
- Use explicit paths and `-LiteralPath` where practical.
- Back up before overwrite/delete.
- Do not read or log secrets.
- Do not install global tools unless explicitly requested.
- Package multi-file output as TAR.GZ with README, manifest, hashes, and `.thoughts`.

Requested output:
1. short plan,
2. generated artifact/script,
3. dry-run command,
4. apply command,
5. verification command,
6. what output to paste back.
