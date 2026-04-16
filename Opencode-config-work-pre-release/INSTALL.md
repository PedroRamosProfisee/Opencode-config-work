# Installation Guide

## Windows

```powershell
# Clone the repo
git clone https://github.com/PedroRamosProfisee/Opencode-config-work.git "$env:USERPROFILE\.config\opencode"

# Install dependencies
cd "$env:USERPROFILE\.config\opencode"
npm install
```

## macOS / Linux

```bash
# Clone the repo
git clone https://github.com/PedroRamosProfisee/Opencode-config-work.git ~/.config/opencode

# Install dependencies
cd ~/.config/opencode
npm install
```

## Manual (if you already have an opencode config)

If you already have files in `~/.config/opencode`, copy selectively:

```bash
# Copy only specific folders you want
cp -r ./agents ~/.config/opencode/
cp -r ./command ~/.config/opencode/
cp -r ./skill ~/.config/opencode/
cp -r ./context ~/.config/opencode/
```

Then run `npm install` in `~/.config/opencode`.

## Post-Install

1. Restart OpenCode to pick up new agents, commands, and skills
2. Edit `opencode.json` to set your preferred model and provider
3. Add your own `mcp` block if you use MCP servers
4. Run `/start-feature` to verify everything is working
