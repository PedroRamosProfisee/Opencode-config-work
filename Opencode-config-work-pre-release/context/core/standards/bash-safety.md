# Bash Command Safety Rules

Before executing ANY bash or shell command, mentally pre-screen it against the risk patterns below. The `bash_safety` custom tool is also available for programmatic checking.

## Risk Levels

### HIGH Risk — Block Execution

If a command matches any of these patterns, **refuse to execute** and explain to the user why it is dangerous.

- `rm -rf /` or `rm -rf ~` or `rm -rf . ` — Recursive delete of root, home, or current directory
- `:(){ :|:& };:` — Fork bomb
- `curl ... | sh` or `curl ... | bash` — Pipe curl to shell (remote code execution)
- `wget ... | sh` or `wget ... | bash` — Pipe wget to shell (remote code execution)
- `> /dev/sda` — Direct write to disk device
- `dd if=...` — Low-level disk copy (dd)
- `mkfs` — Format filesystem
- `format C:` — Format drive (Windows)
- `export PATH=` (empty) — Nuke PATH variable
- `unset PATH` — Unset PATH variable
- `Remove-Item ... -Recurse -Force /` — PowerShell recursive force delete root

### MEDIUM Risk — Warn and Confirm

If a command matches any of these patterns, **explain the risk** to the user and **ask for confirmation** before executing.

- `sudo ...` — Elevated privilege execution (sudo)
- `history -c` / `history -w` / `history -d` — Shell history manipulation
- `chmod 777` — Overly permissive file permissions
- `eval ...` — Dynamic command evaluation
- `Invoke-Expression` — PowerShell dynamic execution
- `git push --force` — Force push (rewrites remote history)
- `cat .env` / `echo .pem` / `type .secrets` — Exposing sensitive files
- `Set-ExecutionPolicy Unrestricted` or `Bypass` — PowerShell execution policy bypass
- `reg delete` — Windows registry deletion
- `chown -R ... /` — Recursive ownership change from root

### LOW Risk — Proceed with Caution

If a command matches any of these patterns, **proceed but note the risk** to the user.

- `git reset --hard` — Hard reset discards uncommitted changes
- `npm publish` — Publishing npm package
- `dotnet nuget push` — Publishing NuGet package
- `git clean -f` — Force clean untracked files
- `git stash drop` — Dropping stashed changes

## Windows/PowerShell Equivalents

Several patterns specifically target Windows and PowerShell commands:

- **Remove-Item -Recurse -Force** (HIGH) — The PowerShell equivalent of `rm -rf`, especially dangerous when targeting root paths
- **Invoke-Expression** (MEDIUM) — PowerShell's `eval` equivalent, enables dynamic code execution
- **Set-ExecutionPolicy Unrestricted/Bypass** (MEDIUM) — Disables PowerShell's script execution safety controls
- **reg delete** (MEDIUM) — Deleting Windows registry keys can destabilize the system
- **format [drive]:/** (HIGH) — Formatting a drive erases all data on it

## Policy

1. Always prefer targeted commands over broad ones (e.g., `rm file.txt` not `rm -rf .`).
2. Never pipe untrusted remote content to a shell interpreter.
3. When in doubt, show the command to the user and explain what it does before executing.
