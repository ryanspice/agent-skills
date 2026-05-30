# Package Apply Patterns

## Preferred flow

1. Locate archive in source dirs.
2. Extract to a stage folder under `<DOWNLOADS_ROOT>` or another temp root.
3. Validate expected files.
4. Back up destination files that will be touched.
5. Apply changes.
6. Run verification.
7. Clean up stage/archive/script when safe.

## Search dirs

For Ryan-local packages, search:

```powershell
$SearchDirs = @("<DOWNLOADS_ROOT>", "$env:USERPROFILE/Downloads")
```

Do not ask for these paths unless the task is for a new environment or the paths fail.

## Preserve local dev state

When applying to repos, preserve local/generated state such as:

- `.git`
- `node_modules`
- `.gradle`
- `build`
- `dist` where local-only
- `local.properties`
- IDE/workspace settings unless intentionally packaged
- secrets and `.env` files

## Changes-only vs full TAR

Prefer changes-only TAR.GZ for project patches. Use full TAR only when the whole artifact is intended to be self-contained or the user explicitly needs it.
