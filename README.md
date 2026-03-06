# Alpha-5 CLI

```
 __   __        ___  __        ___       __   ___  __   __
|__) /  \ |  | |__  |__) |    |__  |\ | |  \ |__  |__) /__`
|    \__/ |/\| |___ |  \ |___ |___ | \| |__/ |___ |  \ .__/
```

A repo-agnostic feature management CLI built on **git worktrees**. Navigate to any git repository and manage isolated feature workspaces that share the same git history.

---

## Quick Start

```bash
# 1. Install
cd /path/to/alpha-5-cli
./install.sh
source ~/.zshrc

# 2. Navigate to your project
cd ~/projects/my-repo

# 3. Create a feature
a5 add feat:new-button

# 4. You're now in the worktree, ready to work!
```

---

## How It Works

Alpha-5 uses **git worktrees** instead of full repository clones:

- **Shared git history** — one `.git` object store, not N clones
- **Instant setup** — no network clone, just a local checkout
- **Less disk usage** — only working tree files are duplicated
- **Branch safety** — git prevents the same branch from being checked out twice

### Directory Structure

```
~/projects/
├── my-repo/                          # Your main repository (run a5 here)
└── my-repo-features/                 # Auto-created by alpha-5
    ├── feat:new-button/              # Worktree (branch: feat/new-button)
    ├── fix:login-bug/                # Worktree (branch: fix/login-bug)
    └── chore:update-deps/            # Worktree (branch: chore/update-deps)
```

---

## Installation

```bash
cd /path/to/alpha-5-cli
./install.sh
source ~/.zshrc
```

### Verify

```bash
a5 version
a5 help
```

---

## Prefix Convention

Every feature **requires a prefix** separated by `:`. The prefix becomes the branch directory:

| Input | Branch Created |
|-------|---------------|
| `feat:new-button` | `feat/new-button` |
| `fix:login-bug` | `fix/login-bug` |
| `chore:update-deps` | `chore/update-deps` |
| `refactor:auth-flow` | `refactor/auth-flow` |

**Valid prefixes:** `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `perf`

---

## Auto-Synced Files

On `add`, `update`, and `update-all`, Alpha-5 automatically copies:

- **All `*.env` files** from the repo root (e.g., `development.env`, `.env.local`)
- **`~/.claude/settings.local.json`** into `.claude/settings.local.json` in the worktree

No configuration file needed.

---

## Commands

| Command | Aliases | Description |
|---------|---------|-------------|
| `a5 help` | `-h`, `--help` | Show help and current repo info |
| `a5 add <prefix>:<name>` | `create` | Create a new feature worktree |
| `a5 list` | `ls` | List all feature worktrees for this repo |
| `a5 update <prefix>:<name>` | `sync` | Sync files to a feature |
| `a5 update-all` | — | Sync files to all features |
| `a5 delete <prefix>:<name>` | `remove`, `rm` | Remove worktree and branch |
| `a5 status <prefix>:<name>` | `st` | Show git status of a feature |
| `a5 path <prefix>:<name>` | — | Print absolute path to a feature |
| `a5 open <prefix>:<name>` | — | Navigate (cd) into a feature worktree |
| `a5 version` | `-v`, `--version` | Show CLI version |

### Examples

```bash
# Create features
a5 add feat:payment-processing
a5 add fix:auth-timeout
a5 add chore:bump-dependencies

# List all features for this repo
a5 list

# Switch between features
a5 open feat:payment-processing
a5 open fix:auth-timeout

# Check status without navigating
a5 status feat:payment-processing

# Sync env files and claude settings
a5 update feat:payment-processing
a5 update-all

# Clean up
a5 delete chore:bump-dependencies
```

### Using with any repo

```bash
cd ~/projects/backend-api
a5 add feat:new-endpoint
a5 list

cd ~/projects/frontend-app
a5 add feat:redesign
a5 list
```

---

## Uninstallation

```bash
cd /path/to/alpha-5-cli
./uninstall.sh
source ~/.zshrc
```

Existing worktrees are left untouched. Remove them manually:

```bash
git worktree list
git worktree remove <path>
```

---

## Requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| Git | 2.17+ | For `worktree add` and `worktree remove` |
| Shell | zsh | bash supported with installer modifications |

---

## FAQ

**Q: Does this work with any git repo?**
A: Yes. Just `cd` into any git repo and run `a5` commands.

**Q: Where do worktrees go?**
A: In `<repo-name>-features/` next to your repo. E.g., `~/projects/my-app-features/`.

**Q: What files get synced?**
A: All `*.env` files from the repo root and `~/.claude/settings.local.json`. No config file needed.

**Q: What happens when I delete a feature?**
A: The worktree directory is removed and the branch is deleted. Confirmation required.

---

**Version:** 3.1.0
**Last Updated:** March 2026

Built with love by the PowerLenders team
