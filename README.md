# Codex Windows Reload Workaround

Unofficial workaround for a Windows Codex Desktop startup/UI regression where the app may open successfully but remain stuck on a spinner or blocked local configuration state.

## What it does

This workaround:

1. launches the Microsoft Store/MSIX `OpenAI.Codex` app using `IApplicationActivationManager`;
2. enables a loopback-only Chromium DevTools endpoint on `127.0.0.1:9222`;
3. locates the main renderer at `app://-/index.html`;
4. sends `Page.reload` over the Chrome DevTools Protocol.

It does **not** delete `.codex`, sessions, projects, account data, or the desktop profile.

## Quick setup

Run once:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Install-Shortcuts.ps1
```

This creates two desktop shortcuts:

- `1 Start Codex (Debug)`
- `2 Fix Codex Spinner`

Then:

1. launch `1 Start Codex (Debug)`;
2. wait for the Codex window to appear;
3. if it remains stuck spinning, launch `2 Fix Codex Spinner`.

## One-click GitHub publishing

If you downloaded this source bundle and want to publish your own fork/repository:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Publish-To-GitHub.ps1
```

The script uses GitHub CLI, creates the repository, adds `origin`, pushes the files, and opens the repository page.

## Security note

The remote debugging endpoint is explicitly bound to:

```text
127.0.0.1:9222
```

Do **not** change it to `0.0.0.0`.

While the endpoint is active, another process running locally may be able to connect to the DevTools interface. Close Codex when it is not in use.

## Scope

Verified against the Windows Microsoft Store/MSIX Codex desktop app family `OpenAI.Codex`.

This is a workaround, not an official OpenAI fix. It may stop being necessary or stop working after future Codex/Electron changes.

## Related upstream reports

- https://github.com/openai/codex/issues/44342
- https://github.com/openai/codex/issues/45069
- https://github.com/openai/codex/issues/42547

## Privacy

This repository intentionally contains no usernames, account identifiers, project paths, conversation data, logs, tokens, cookies, or machine-specific package installation paths.

User directories and the current Codex package are discovered dynamically at runtime.

## License

MIT
