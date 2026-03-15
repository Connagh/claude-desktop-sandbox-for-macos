# Claude Desktop Sandbox for macOS

Claude Desktop, and any MCP servers it runs, has access to your home folder by default. It has its own permission prompts, but those guardrails live inside the app itself. If a prompt injection were to bypass them, there's no second layer to fall back on.

This tool adds that second layer, at the operating system level, using Apple's built-in sandbox. Even if Claude or an MCP server is tricked, macOS itself blocks the access. The app can **only** work inside a single folder: `~/Claude-Sandbox`. The rest of your system is off limits.

**Requirements:** macOS only. Uses Apple's built-in `sandbox-exec`. Claude Desktop must be installed at `/Applications/Claude.app`.

## Quick Start

1. [Download the repo](https://github.com/Connagh/claude-desktop-sandbox-for-macos)
2. Move `Claude Desktop Sandboxed.app` to `/Applications`
3. Open it — Claude Desktop launches sandboxed automatically

Use this instead of the regular Claude.app. Drag it to your Dock for quick access.

A `~/Claude-Sandbox` folder is created automatically on first launch. This is where you put any files you want Claude Desktop to work with.

> **Important:** You must always open Claude Desktop using `Claude Desktop Sandboxed.app`. If you open the regular `Claude.app` from Finder or the Dock, the sandbox is not active and your files are not protected.

<details>
<summary><strong>Test It Works</strong></summary>

1. Open `Claude Desktop Sandboxed.app`
2. Ask Claude to read a file outside the sandbox:
   - `cat ~/Documents/something.txt` → **should fail** (blocked)
3. Ask Claude to read a file inside the sandbox:
   - `cat ~/Claude-Sandbox/test.txt` → **should work** (allowed)
4. Ask Claude to write a file:
   - Writing to `~/Claude-Sandbox/` → **works**
   - Writing anywhere else in `~/` → **blocked**

</details>

<details>
<summary><strong>What It Allows</strong></summary>

- **Your sandbox folder** (`~/Claude-Sandbox`) — full read and write access
- **Claude's own app data** — its config files, caches, logs, and saved state. These are the `~/Library/` paths that Claude Desktop needs to function.
- **Config files** (`~/.claude`, `~/.config`, `~/.gitconfig`)
- **Keychain and Preferences** — needed for authentication and app settings
- **System files** (`/System`, `/Library`, `/usr`, `/bin`, etc.)
- **Full network access** — Claude needs this to talk to the API

</details>

<details>
<summary><strong>What It Blocks</strong></summary>

Everything else in your home folder:

- Desktop, Downloads, Documents, Pictures, Music, Movies
- `.ssh`, `.gnupg`, `.aws`, `.env`, `.zshrc`, `.bash_history`
- Other apps' data in `~/Library/` (browser data, Mail, Messages, etc.)
- Any folder in `~/` not listed above

</details>

<details>
<summary><strong>How It Works</strong></summary>

The app launches Claude Desktop through macOS's `sandbox-exec` with a set of rules defined in `profile.sb` (bundled inside the app). From that point on, the operating system enforces the rules — the app literally cannot access files outside the allowed paths, regardless of what it tries to do.

Electron's built-in Chromium sandbox conflicts with `sandbox-exec`, so the launcher disables it. This is safe because the macOS sandbox replaces it with stronger, OS-level enforcement that the app cannot override.

</details>

<details>
<summary><strong>Customising the Rules</strong></summary>

If you need Claude Desktop to access an additional folder (for example, a project folder outside `~/Claude-Sandbox`), edit `profile.sb` inside the app bundle and add your folder to both the read and write sections. Look for the existing `Claude-Sandbox` lines and add similar ones below them for your folder.

To edit the bundled profile:

```bash
open "Claude Desktop Sandboxed.app/Contents/Resources/profile.sb"
```

Then quit and reopen the app.

### Seeing What's Being Blocked

If something isn't working and you think the sandbox might be blocking it, watch the deny log in a second terminal:

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
| Startup errors (ComputerUseTcc, listMarketplaces, SetApplicationIsDaemon) | Normal Electron startup noise | Ignore |
| Cowork preview "Failed to load local file" | Sandbox may block preview path | Check deny log, add path to profile |

</details>

<details>
<summary><strong>Limitations and Remaining Weaknesses</strong></summary>

- **macOS only** — uses Apple's `sandbox-exec`
- **Must use the sandboxed app** — opening the regular Claude.app bypasses the sandbox
- **MCP servers inherit the sandbox** — they can only access `~/Claude-Sandbox`. If an MCP server needs access to other folders, add the paths to `profile.sb`
- **`~/.config` is broadly allowed** — this folder may contain tokens from other apps like GitHub CLI or VS Code
- **`~/Library/Preferences`** — contains settings for all apps, not just Claude, but is needed for the app to run
- **`~/Library/Keychains`** — needed for authentication but is sensitive
- **`~/Library/Group Containers`** — shared data used by app groups (Safari extensions, etc.), but needed for Claude to run
- **Network is unrestricted** — Claude needs internet access to work, so network requests aren't blocked

</details>

<details>
<summary><strong>Uninstall</strong></summary>

Delete `Claude Desktop Sandboxed.app` from `/Applications`. Your `~/Claude-Sandbox` folder is not affected.

</details>

## License

MIT
