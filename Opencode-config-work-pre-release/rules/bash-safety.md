# Bash Safety

The `bash-safety` tool auto-checks commands. Additionally:

- **BLOCK:** `rm -rf /|~|.`, fork bombs, `curl|wget` piped to `sh|bash`, `dd if=`, `mkfs`, `format C:`, `Remove-Item -Recurse -Force /`
- **WARN+CONFIRM:** `sudo`, `chmod 777`, `eval`, `Invoke-Expression`, `git push --force`, exposing `.env/.pem/.secrets`, `Set-ExecutionPolicy Bypass`, `reg delete`
- **CAUTION:** `git reset --hard`, `npm publish`, `dotnet nuget push`, `git clean -f`, `git stash drop`

Prefer targeted commands. Never pipe untrusted remote content to shell.
