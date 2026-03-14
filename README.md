# Claude Desktop Sandbox for macOS

The Claude Desktop app — and any MCP servers it runs — can read and write every file in your home folder. Your SSH keys, browser data, passwords, documents, everything is accessible.

Claude Desktop has its own permission prompts, but those guardrails live inside the app — if a prompt injection bypasses them, there's nothing stopping it. This tool adds a layer underneath, at the operating system level, using Apple's built-in sandbox. Even if Claude or an MCP server is tricked, macOS itself blocks the access. The app can **only** work inside a single folder: `~/Claude-Sandbox`. The rest of your system is blocked. You launch it by running `cd-seatbelt` in your terminal instead of opening Claude from your Dock.

> **You must always launch Claude Desktop from the terminal using `cd-seatbelt`.** If you open it from Finder, the Dock, or Spotlight, the sandbox is not active and your files are not protected.

**Requirements:** macOS only. Uses Apple's built-in `sandbox-exec`. Claude Desktop must be installed at `/Applications/Claude.app`.

## Quick Start

```bash
git clone https://github.com/Connagh/claude-desktop-sandbox-for-macos
cd claude-desktop-sandbox-for-macos
chmod +x cd-seatbelt install.sh uninstall.sh
```

You can run it straight away:

```bash
./cd-seatbelt
```

Or install it so the `cd-seatbelt` command works from any folder:

```bash
./install.sh
```

If your terminal doesn't recognise `cd-seatbelt` after installing, add this line to your `~/.zshrc` and restart your terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

The first time you run it, a `~/Claude-Sandbox` folder is created automatically. This is where you put any files you want Claude Desktop to work with.

## Test It Works

1. Launch Claude Desktop sandboxed: `./cd-seatbelt`
2. Ask Claude to read a file outside the sandbox:
   - `cat ~/Documents/something.txt` → **should fail** (blocked)
3. Ask Claude to read a file inside the sandbox:
   - `cat ~/Claude-Sandbox/test.txt` → **should work** (allowed)
4. Ask Claude to write a file:
   - Writing to `~/Claude-Sandbox/` → **works**
   - Writing anywhere else in `~/` → **blocked**

## What It Allows

- **Your sandbox folder** (`~/Claude-Sandbox`) — full read and write access
- **Claude's own app data** — its config files, caches, logs, and saved state. These are the `~/Library/` paths that Claude Desktop needs to function.
- **Config files** (`~/.claude`, `~/.config`, `~/.gitconfig`)
- **Keychain and Preferences** — needed for authentication and app settings
- **System files** (`/System`, `/Library`, `/usr`, `/bin`, etc.)
- **Full network access** — Claude needs this to talk to the API

## What It Blocks

Everything else in your home folder:

- Desktop, Downloads, Documents, Pictures, Music, Movies
- `.ssh`, `.gnupg`, `.aws`, `.env`, `.zshrc`, `.bash_history`
- Other apps' data in `~/Library/` (browser data, Mail, Messages, etc.)
- Any folder in `~/` not listed above

## How It Works

The `cd-seatbelt` script launches Claude Desktop through macOS's `sandbox-exec` with a set of rules defined in `profile.sb`. From that point on, the operating system enforces the rules — the app literally cannot access files outside the allowed paths, regardless of what it tries to do.

Electron's built-in Chromium sandbox conflicts with `sandbox-exec`, so the launcher disables it. This is safe because the macOS sandbox replaces it with stronger, OS-level enforcement that the app cannot override.

## Customizing the Rules

If you need Claude Desktop to access an additional folder (for example, a project folder outside `~/Claude-Sandbox`), edit `profile.sb` and add your folder to both the read and write sections. Look for the existing `Claude-Sandbox` lines and add similar ones below them for your folder.

Then quit Claude Desktop and relaunch it with `cd-seatbelt`.

### Seeing What's Being Blocked

If something isn't working and you think the sandbox might be blocking it, watch the deny log in a second terminal:

```bash
log stream --predicate 'eventMessage contains "deny"' --style compact | grep -i clau
```

## Known Issues

| Issue | Cause | Fix |
|---|---|---|
| Cowork hangs on "Starting workspace" | VPN blocking Anthropic endpoints | Turn off VPN or whitelist Anthropic |
| "account information is unavailable" | Same VPN issue | Same fix |
| Startup errors (ComputerUseTcc, listMarketplaces, SetApplicationIsDaemon) | Normal Electron startup noise | Ignore |
| Cowork preview "Failed to load local file" | Sandbox may block preview path | Check deny log, add path to profile |

## Limitations and Remaining Weaknesses

- **macOS only** — uses Apple's `sandbox-exec`
- **Must launch from terminal** — opening Claude from Finder or the Dock bypasses the sandbox entirely
- **MCP servers inherit the sandbox** — they can only access `~/Claude-Sandbox`. If an MCP server needs access to other folders, add the paths to `profile.sb`
- **`~/.config` is broadly allowed** — this folder may contain tokens from other apps like GitHub CLI or VS Code
- **`~/Library/Preferences`** — contains settings for all apps, not just Claude, but is needed for the app to run
- **`~/Library/Keychains`** — needed for authentication but is sensitive
- **Network is unrestricted** — Claude needs internet access to work, so network requests aren't blocked

## Uninstall

```bash
./uninstall.sh
```

This removes the `cd-seatbelt` command and its config. Your `~/Claude-Sandbox` folder is not deleted — remove it manually if you want.

## License

MIT
