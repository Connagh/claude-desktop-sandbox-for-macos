# Claude Desktop Sandbox for macOS

![Claude Desktop Sandbox](https://i.postimg.cc/FsVnxNkK/claude.gif)

Claude Desktop and its MCP servers have access to your system by default. There's no OS-level protection, so if a prompt injection tricks Claude into approving something, nothing stops it.

This tool wraps Claude Desktop in an OS-level sandbox using Apple's built-in `sandbox-exec`. The app can **only** access `~/Claude-Sandbox`. Everything else is blocked by macOS itself.

**Requirements:** macOS. Claude Desktop installed at `/Applications/Claude.app`.

## Quick Start

```bash
# copy and paste this entire block into your terminal

# download
git clone https://github.com/Connagh/claude-desktop-sandbox-for-macos
cd claude-desktop-sandbox-for-macos

# install
chmod +x claude-desktop-sandboxed install.sh
./install.sh

# add to PATH (only if not already there)
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# launch
claude-desktop-sandboxed
```

A `~/Claude-Sandbox` folder is created on first launch. Put any files you want Claude to work with in there.

> **Important:** Always launch using `claude-desktop-sandboxed`. Opening the regular `Claude.app` bypasses the sandbox.

<details>
<summary><strong>Test It Works</strong></summary>

1. Run `claude-desktop-sandboxed`
2. Ask Claude to read `cat ~/Documents/something.txt` → **blocked**
3. Ask Claude to read `cat ~/Claude-Sandbox/test.txt` → **allowed**
4. Writing to `~/Claude-Sandbox/` → **works**
5. Writing anywhere else → **blocked**

</details>

<details>
<summary><strong>What It Allows</strong></summary>

- `~/Claude-Sandbox`, full read and write
- Claude's app data (`~/Library/` paths it needs to run)
- Config files (`~/.claude`, `~/.config`, `~/.gitconfig`)
- Keychain and Preferences (authentication and settings)
- System files (`/System`, `/Library`, `/usr`, `/bin`, etc.)
- Network access (required for the API)

</details>

<details>
<summary><strong>What It Blocks</strong></summary>

Everything else in your home folder: Desktop, Downloads, Documents, Pictures, `.ssh`, `.gnupg`, `.aws`, `.env`, `.zshrc`, `.bash_history`, other apps' data, and anything not listed above.

</details>

<details>
<summary><strong>How It Works</strong></summary>

The script launches Claude Desktop through `sandbox-exec` with rules from `profile.sb`. macOS enforces these rules at the OS level. The app cannot access anything outside the allowed paths.

Electron's Chromium sandbox conflicts with `sandbox-exec`, so the launcher disables it. The macOS sandbox replaces it with stronger protection that the app cannot override.

</details>

<details>
<summary><strong>Customising the Rules</strong></summary>

To give Claude access to an additional folder, edit `profile.sb` and add your path to both the read and write sections. Look for the `Claude-Sandbox` lines and add similar ones for your folder.

Quit and relaunch with `claude-desktop-sandboxed` to apply changes.

### Seeing What's Being Blocked

Watch the deny log in a second terminal:

```bash
log stream --predicate 'eventMessage contains "deny"' --style compact | grep -i clau
```

</details>

<details>
<summary><strong>Known Issues</strong></summary>

| Issue | Cause | Fix |
|---|---|---|
| Cowork hangs on "Starting workspace" | VPN blocking Anthropic endpoints | Turn off VPN or whitelist Anthropic |
| "account information is unavailable" | Same VPN issue | Same fix |
| Startup errors (ComputerUseTcc, listMarketplaces, etc.) | Normal Electron noise | Ignore |
| Cowork preview "Failed to load local file" | Sandbox blocking preview path | Check deny log, add path to profile |

</details>

<details>
<summary><strong>Limitations</strong></summary>

- **macOS only.** Uses Apple's `sandbox-exec`
- **Must launch from terminal.** Opening regular Claude.app bypasses the sandbox
- **MCP servers inherit the sandbox.** They can only access `~/Claude-Sandbox`. Add extra paths to `profile.sb` if needed
- **`~/.config` is broadly allowed.** May contain tokens from other tools (GitHub CLI, VS Code, etc.)
- **`~/Library/Preferences`**, **`~/Library/Keychains`**, and **`~/Library/Group Containers`** are accessible because Claude needs them to run
- **Network is unrestricted.** Required for API access

</details>

<details>
<summary><strong>Uninstall</strong></summary>

```bash
rm -f ~/.local/bin/claude-desktop-sandboxed
rm -rf ~/.local/share/claude-desktop-sandbox-for-macos
```

Your `~/Claude-Sandbox` folder is not removed as it may contain active projects. Delete this manually if you no longer need it.

</details>

## License

MIT
