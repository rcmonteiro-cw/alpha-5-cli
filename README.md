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
- **Always up to date** — `add` fetches from remote and branches from `origin/main`
- **Less disk usage** — only working tree files are duplicated
- **Branch safety** — git prevents the same branch from being checked out twice
- **Works from anywhere** — run commands from the main repo or from inside any worktree

### Directory Structure

```
~/projects/
├── my-repo/                          # Your main repository (run a5 here)
└── my-repo-features/                 # Auto-created by alpha-5
    ├── feat:new-button/              # Worktree (branch: feat/new-button)
    ├── fix:login-bug/                # Worktree (branch: fix/login-bug)
    └── chore:update-deps/            # Worktree (branch: chore/update-deps)
```

The features directory is always a sibling to your repo, named `<repo-name>-features`.

---

## Installation

```bash
cd /path/to/alpha-5-cli
./install.sh
source ~/.zshrc
```

This adds the following to your `~/.zshrc`:
- `a5` shell function (handles `open` and `add` with auto-cd)
- `alpha-5` alias (points to `a5`)
- `a5open` function (shortcut for `a5 open`)
- `ALPHA5_HOME` environment variable

### Verify

```bash
a5 version
a5 help
```

---

## Prefix Convention

Every feature **requires a prefix** separated by `:`. The prefix maps to the git branch name:

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

- **All `*.env` files** from the main repo root (e.g., `development.env`, `.env.local`)
- **`~/.claude/settings.local.json`** into `.claude/settings.local.json` in the worktree

No configuration file needed.

---

## Commands

| Command | Aliases | Description |
|---------|---------|-------------|
| `a5 help` | `-h`, `--help` | Show help and current repo info |
| `a5 add <prefix>:<name>` | `create` | Fetch origin, branch from latest main, create worktree |
| `a5 list` | `ls` | List all feature worktrees for this repo |
| `a5 update <prefix>:<name>` | `sync` | Sync env files and claude settings to a feature |
| `a5 update-all` | — | Sync files to all features |
| `a5 delete <prefix>:<name>` | `remove`, `rm` | Remove worktree and delete branch (with confirmation) |
| `a5 status <prefix>:<name>` | `st` | Show git status of a feature |
| `a5 path <prefix>:<name>` | — | Print absolute path to a feature |
| `a5 open <prefix>:<name>` | — | Navigate (cd) into a feature worktree |
| `a5 version` | `-v`, `--version` | Show CLI version |

### What `add` does

1. Runs `git fetch origin` to get the latest remote state
2. Detects the default remote branch (usually `main`)
3. Creates a worktree at `<repo>-features/<prefix>:<name>/`
4. Creates branch `<prefix>/<name>` based on `origin/main`
5. Copies all `*.env` files from the repo root
6. Copies `~/.claude/settings.local.json`
7. Auto-navigates you into the worktree

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
# or use the shortcut
a5open feat:payment-processing

# Check status without navigating
a5 status feat:payment-processing

# Sync env files and claude settings
a5 update feat:payment-processing
a5 update-all

# Clean up
a5 delete chore:bump-dependencies
```

### Works from inside worktrees

All commands work whether you're in the main repo or inside any worktree:

```bash
cd ~/projects/my-repo
a5 list                          # works

a5 open feat:payment-processing
# now inside ~/projects/my-repo-features/feat:payment-processing/
a5 list                          # still works, same output
a5 add fix:urgent-bug            # creates another worktree from here
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
| Shell | zsh, bash, or fish | Auto-detected by the installer |

---

## FAQ

**Q: Does this work with any git repo?**
A: Yes. Just `cd` into any git repo and run `a5` commands.

**Q: Where do worktrees go?**
A: In `<repo-name>-features/` next to your repo. E.g., `~/projects/my-app-features/`.

**Q: What files get synced?**
A: All `*.env` files from the repo root and `~/.claude/settings.local.json`. No config file needed.

**Q: Does `add` use the latest remote code?**
A: Yes. It runs `git fetch origin` and branches from `origin/main` (or whichever is the default remote branch).

**Q: Can I run commands from inside a worktree?**
A: Yes. Alpha-5 detects the main repo automatically, so `a5 list`, `a5 add`, etc. all work from any worktree.

**Q: What happens when I delete a feature?**
A: The worktree directory is removed and the branch is deleted. Confirmation is required.

**Q: What prefixes can I use?**
A: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `perf`.

---

**Version:** 3.1.0
**Last Updated:** March 2026

Built with love by the PowerLenders team
