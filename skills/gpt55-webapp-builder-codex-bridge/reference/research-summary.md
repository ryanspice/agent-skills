# Research Summary

## Main finding

A ChatGPT/GPT-5.5 web session can be used productively as a Codex-like builder **only** when it is treated as a human-in-the-loop orchestration loop:

```txt
Plan -> Generate script/package -> User reviews -> User runs -> User returns output -> ChatGPT interprets -> Next action
```

The pattern is sound because modern agent systems separate model reasoning from tool execution. The model can plan and produce structured tool calls, while the application/human/executor controls what is actually run.

## Durable takeaways

1. **Use tool contracts, not raw shell magic.**
   Generated scripts should be reviewable artifacts with explicit paths, parameters, dry-run, and verification steps.

2. **Approval gates matter.**
   Sandbox and approval policy are two different controls: where code can act, and when the human must approve.

3. **Browser-only is intentionally limited.**
   Web pages can use clipboard, file picker/File System Access in supported browsers, workers, and WASM. They cannot safely become local shell agents without an extension, server executor, or desktop helper.

4. **TAR.GZ bundles are useful but need inspection.**
   Archive extraction is a known risk area. Extract into isolated folders, inspect member paths, and avoid blindly unpacking unknown archives over a repo.

5. **Self-cleaning is not secure erasure.**
   Temporary directories and cleanup are good hygiene. They do not securely sanitize secrets.

6. **Clipboard is user-mediated transfer, not background IPC.**
   It should be explicit, visible, and avoided for secrets.

## Source families reviewed

- OpenAI Responses API, tool calling, MCP connectors, background mode, Codex sandboxing/approvals/rules.
- Model Context Protocol architecture and tools concepts.
- MDN Clipboard API, File System Access API, CSP, same-origin policy.
- Chrome/MDN/Edge native messaging documentation.
- Python `subprocess`, `tempfile`, `atexit`, `tarfile`, `shutil`, `urllib.request` docs.
- Microsoft PowerShell docs for `Invoke-RestMethod`, `Start-Process`, `Remove-Item`, `Set-Clipboard`, `Get-Clipboard`, and `Get-FileHash`.
- OWASP LLM Top 10, AI Agent Security Cheat Sheet, Prompt Injection guidance, Insecure Output Handling.
- NIST SSDF and media sanitization guidance.
- OAuth/bearer-token RFC guidance for token handling.

## Useful source URLs

```txt
https://developers.openai.com/api/docs/guides/function-calling
https://developers.openai.com/api/docs/guides/tools
https://developers.openai.com/api/docs/guides/tools-connectors-mcp
https://developers.openai.com/api/docs/guides/background
https://developers.openai.com/codex/agent-approvals-security
https://developers.openai.com/codex/concepts/sandboxing
https://developers.openai.com/codex/rules
https://modelcontextprotocol.io/docs/getting-started/intro
https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API
https://developer.mozilla.org/en-US/docs/Web/API/File_System_API
https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP
https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging
https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging
https://docs.python.org/3/library/subprocess.html
https://docs.python.org/3/library/tempfile.html
https://docs.python.org/3/library/tarfile.html
https://docs.python.org/3/library/shutil.html
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-clipboard
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-clipboard
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash
https://owasp.org/www-project-top-10-for-large-language-model-applications/
https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html
https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html
https://csrc.nist.gov/projects/ssdf
https://csrc.nist.gov/pubs/sp/800/88/r1/final
```
