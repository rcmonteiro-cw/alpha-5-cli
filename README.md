# 🚀 PowerLenders Alpha-5 CLI

```
 __   __        ___  __        ___       __   ___  __   __ 
|__) /  \ |  | |__  |__) |    |__  |\ | |  \ |__  |__) /__`
|    \__/ |/\| |___ |  \ |___ |___ | \| |__/ |___ |  \ .__/
```

A powerful command-line tool for managing features in the Alpha-5 project. Quickly scaffold new features with configuration files from the infinite-lending repository.

---

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Examples](#-examples)
- [Configuration](#️-configuration)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [Uninstallation](#️-uninstallation)
- [Requirements](#-requirements)
- [Commands Reference](#-commands-reference)
- [FAQ](#-faq)
- [Contributing](#-contributing)

---

## ⚡ Quick Start

```bash
# 1. Navigate to the alpha-5-cli directory
cd /path/to/alpha-5-cli

# 2. Run the installer
./install.sh $HOME/my-folder-for-features

# 3. Reload your shell
source ~/.zshrc

# 4. Create your first feature
alpha-5 add my-awesome-feature

# 5. List all features
alpha-5 list

# 6. Update a feature with latest configuration
alpha-5 update my-awesome-feature

# 7. Check git status
alpha-5 status my-awesome-feature

# 8. Update all features at once
alpha-5 update-all

# 9. Get help anytime
alpha-5 help
```

---

## 📦 Installation

### Step 1: Clone or Download

Ensure you have the `alpha-5-cli` directory on your local machine.

### Step 2: Run the Installer

Navigate to the `alpha-5-cli` directory and run the installation script:

```bash
cd /path/to/alpha-5-cli
./install.sh
```

**With Default Location:**
```bash
./install.sh
```
Features will be created in `./features/` (relative to the alpha-5-cli directory)

**With Custom Location:**
```bash
./install.sh /path/to/your/features
```

**Examples:**
```bash
# Install with features in your home directory
./install.sh ~/my-alpha5-features

# Install with features in a workspace directory
./install.sh ~/workspace/features

# Install with absolute path
./install.sh /Users/ricardo/Documents/Projects/alpha-5-features
```

### Step 3: Reload Your Shell

After installation completes, reload your shell configuration:

```bash
source ~/.zshrc
```

Or simply **restart your terminal**.

**What gets installed:**
- `alpha-5` command (alias to the CLI)
- `a5open` function (navigate to feature repositories)
- Environment variables (`ALPHA5_HOME`, `ALPHA5_FEATURES_PATH`)

### What Installation Does

The installer will:

1. ✅ Make all scripts executable (`chmod +x`)
2. ✅ Add the `alpha-5` alias to your `~/.zshrc`
3. ✅ Set `ALPHA5_HOME` environment variable (path to CLI scripts)
4. ✅ Set `ALPHA5_FEATURES_PATH` environment variable (where features are created)
5. ✅ Display a beautiful PowerLenders banner

### Verify Installation

Check that the installation was successful:

```bash
# Test the command
alpha-5 help

# Check environment variables
echo $ALPHA5_HOME
echo $ALPHA5_FEATURES_PATH
```

## 🎯 Usage

The `alpha-5` CLI provides simple commands for managing features.

### 📖 Show Help

Display all available commands and your configuration:

```bash
alpha-5 help
```

**Output includes:**
- List of all available commands
- Usage examples
- Your configured features path
- Command descriptions

### ➕ Create a New Feature

Create a new feature with all necessary scaffolding:

```bash
alpha-5 add <feature-name>
```

**What happens when you run this command:**

1. 📁 Creates feature directory at `$ALPHA5_FEATURES_PATH/feature-name/`
2. 📦 Clones the `infinite-lending` repository inside the feature directory
3. 🔀 Creates and checks out a new branch `feat/feature-name`
4. 📁 Creates a workspace folder `feature-name/` inside the repository
5. 📋 Copies `development.env` from `$HOME/projects/repos/infinite-lending` into the cloned repo
6. 📋 Copies `.claude/settings.local.json` from `$HOME/projects/repos/infinite-lending` into the cloned repo
7. ✅ Displays success message with locations
8. 💡 Shows navigation command to cd into your workspace

**Example:**
```bash
alpha-5 add payment-gateway
```

**Output:**
```
🚀 Setting up feature: payment-gateway
📁 Creating feature directory...
✅ SUCCESS: Created directory /path/to/features/payment-gateway
📦 Cloning infinite-lending repository into feature directory...
✅ SUCCESS: Cloned infinite-lending repository to /path/to/features/payment-gateway/infinite-lending
🔀 Creating and checking out feature branch...
✅ SUCCESS: Created and checked out branch 'feat/payment-gateway'
📁 Creating feature folder inside repository...
✅ SUCCESS: Created folder payment-gateway inside repository
📋 Copying configuration files from local repo to cloned repo...
✅ SUCCESS: Copied development.env
✅ SUCCESS: Copied .claude/settings.local.json
🎉 Feature setup completed successfully!
📍 Feature location: /path/to/features/payment-gateway
📍 Repository location: /path/to/features/payment-gateway/infinite-lending
📍 Work folder: /path/to/features/payment-gateway/infinite-lending/payment-gateway

💡 To navigate to your feature folder, run:
   alpha-5 open payment-gateway

Or use the alias:
   a5open payment-gateway
```

**Quick navigation after creation:**
```bash
# Either of these work:
alpha-5 open payment-gateway
a5open payment-gateway
```

### 🔄 Update a Feature

Update an existing feature with the latest configuration files from your local infinite-lending repository:

```bash
alpha-5 update <feature-name>
```

**What gets updated:**
- ✅ `infinite-lending/development.env`
- ✅ `infinite-lending/.claude/settings.local.json`

**Source:**
Files are copied from `$HOME/projects/repos/infinite-lending`

**Destination:**
Files are copied into the cloned `infinite-lending` directory inside the feature

**Use case:**
When you've pulled the latest changes to your local infinite-lending repository, use this command to sync your feature's cloned repo with the updated configuration files.

**Example:**
```bash
alpha-5 update payment-gateway
```

**Output:**
```
🔄 Updating feature: payment-gateway
📋 Updating configuration files...
✅ SUCCESS: Updated development.env
✅ SUCCESS: Updated .claude/settings.local.json

📋 Update summary:
  ✓ development.env (updated)
  ✓ .claude/settings.local.json (updated)

🎉 Feature update completed successfully!
📍 Feature location: /path/to/features/payment-gateway
📍 Repository location: /path/to/features/payment-gateway/infinite-lending
```

**Aliases:**
```bash
alpha-5 update feature-name
alpha-5 sync feature-name
```

**Safety:**
- Configuration files are overwritten with the latest versions
- Make sure to commit any custom changes before updating

### 📋 List All Features

View all existing features in your configured features path with their sync status:

```bash
alpha-5 list
```

**Output example:**
```
📁 Features in: /Users/ricardo/features

✓ payment-gateway
🔄 user-authentication (outdated - run update)
✓ notification-system
⚠ reporting-dashboard (missing config files)

Total: 4 feature(s)
```

**Status indicators:**
- ✓ Up to date - all config files match the source repository
- 🔄 Outdated - config files exist but differ from source (run `alpha-5 update <feature-name>`)
- ⚠ Missing files - one or more config files are missing

**Features:**
- Shows all features in your configured path
- Checks if configuration files are up to date
- Compares against source repository at `$HOME/projects/repos/infinite-lending`
- Displays total count

**Aliases:**
```bash
alpha-5 list
alpha-5 ls    # Short version
```

### 🗑️ Delete a Feature

Remove a feature with confirmation:

```bash
alpha-5 delete <feature-name>
```

**Safety features:**
- Requires confirmation before deletion
- Shows feature details (name, location, size)
- Cannot be undone warning
- Must type "yes" to confirm

**Example:**
```bash
alpha-5 delete old-feature
```

**Output:**
```
⚠️  WARNING: You are about to delete the following feature:

Feature name: old-feature
Location: /Users/ricardo/features/old-feature
Size: 2.5M

This action cannot be undone!

Are you sure you want to delete 'old-feature'? (yes/no): yes

Deleting feature 'old-feature'...
✅ SUCCESS: Feature 'old-feature' has been deleted
```

**Confirmation options:**
- Type `yes`, `YES`, or `Yes` to confirm deletion
- Type anything else to cancel

**Aliases:**
```bash
alpha-5 delete feature-name
alpha-5 remove feature-name
alpha-5 rm feature-name
```

### 📊 Show Git Status

Display the git status of a feature's repository:

```bash
alpha-5 status <feature-name>
```

**What it shows:**
- Current branch
- Staged changes
- Unstaged changes
- Untracked files
- Upstream sync status

**Example:**
```bash
alpha-5 status payment-gateway
```

**Output:**
```
📊 Git Status for: payment-gateway
Repository: /Users/ricardo/features/payment-gateway/infinite-lending

On branch feat/payment-gateway
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  modified:   src/index.ts

Untracked files:
  src/new-feature.ts
```

**Aliases:**
```bash
alpha-5 status feature-name
alpha-5 st feature-name    # Short version
```

**Use cases:**
- Quick check without changing directories
- See what needs to be committed
- Check which branch you're on
- Verify upstream sync status

### 📍 Print Feature Path

Print the absolute path to a feature directory:

```bash
alpha-5 path <feature-name>
```

**Example:**
```bash
alpha-5 path payment-gateway
# Output: /Users/ricardo/features/payment-gateway
```

**Use cases:**

**Navigate to feature:**
```bash
cd $(alpha-5 path payment-gateway)
```

**Navigate to repository:**
```bash
cd $(alpha-5 path payment-gateway)/infinite-lending
```

**Use in scripts:**
```bash
FEATURE_PATH=$(alpha-5 path payment-gateway)
echo "Working in: $FEATURE_PATH"
```

**Copy files:**
```bash
cp myfile.txt $(alpha-5 path payment-gateway)/infinite-lending/
```

### 📂 Open Feature Repository

Navigate directly to your feature's `infinite-lending` repository:

```bash
alpha-5 open <feature-name>
# or
a5open <feature-name>
```

**What it does:**
- Changes your current directory to `feature-name/infinite-lending/`
- This is where you'll work on your feature
- Works as a **shell function** (not a script), so `cd` works in your current terminal
- Installed automatically during setup

**Example:**
```bash
alpha-5 open payment-gateway
# You're now in: /Users/ricardo/features/payment-gateway/infinite-lending/

# Same thing with alias:
a5open payment-gateway
```

**Structure:**
```
features/
└── payment-gateway/                    # Feature root
    └── infinite-lending/               # Cloned repository (← a5open goes here)
        ├── development.env
        ├── .claude/
        │   └── settings.local.json
        └── ... (all repository files)
```

**Technical details:**

The installer adds this function to your `~/.zshrc`:
```bash
alpha-5() {
    # Special handling for 'open' command
    if [ "$1" = "open" ]; then
        local feature_name=$2
        local repo_path=$(bash $ALPHA5_HOME/alpha-5.sh open "$feature_name" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$repo_path" ]; then
            cd "$repo_path"
        else
            bash $ALPHA5_HOME/alpha-5.sh open "$feature_name"
        fi
    else
        # Pass through all other commands
        bash $ALPHA5_HOME/alpha-5.sh "$@"
    fi
}

# Convenience alias
a5open() {
    alpha-5 open "$1"
}
```

**For scripting (prints path):**
```bash
# Get the path without cd-ing
WORKSPACE_PATH=$(alpha-5 open payment-gateway)
echo "Workspace at: $WORKSPACE_PATH"
```

**Difference from `path`:**
- `alpha-5 path <name>` → Prints `/features/feature-name`
- `alpha-5 open <name>` → Changes directory to `/features/feature-name/infinite-lending`
- `a5open <name>` → Same as `alpha-5 open` (alias)

### 🔄 Update All Features

Update configuration files for all features at once:

```bash
alpha-5 update-all
```

**What it does:**
- Iterates through all features in your configured path
- Updates `development.env` in each feature's repository
- Updates `.claude/settings.local.json` in each feature's repository
- Shows a summary of successes, failures, and skipped features

**Example:**
```bash
alpha-5 update-all
```

**Output:**
```
🔄 Updating all features...

Processing: payment-gateway
  ✓ Updated successfully

Processing: user-authentication
  ✓ Updated successfully

Processing: notification-system
  ⚠ Skipped (missing infinite-lending directory)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Update Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total features: 3
Updated: 2
Skipped: 1

🎉 Update completed!
```

**Use cases:**
- After pulling latest changes to your local infinite-lending repo
- Sync all features with updated environment variables
- Ensure all projects have consistent configuration

### 🏷️ Show Version

Display the current version of the CLI:

```bash
alpha-5 version
```

---

## 🔧 Shell Functions

The installer automatically adds these shell functions to your `~/.zshrc`:

### `a5open <feature-name>` - Navigate to Repository

Changes your current directory to the feature's `infinite-lending` folder:

```bash
a5open payment-gateway
# You're now in your workspace!
pwd
# → /Users/ricardo/features/payment-gateway/infinite-lending/payment-gateway
```

**Why a shell function?**
- Scripts run in a subshell and can't change the parent shell's directory
- This function runs in your current shell, so `cd` works as expected
- Automatically installed during `./install.sh`

---

## 💡 Examples

### Example 1: Create a Payment Processing Feature

```bash
alpha-5 add payment-processing
```

Creates:
```
features/
└── payment-processing/
    └── infinite-lending/
        ├── payment-processing/         # Your workspace folder
        ├── development.env
        ├── .claude/
        │   └── settings.local.json
        └── ... (all other files from the repository)
```

### Example 2: Create Multiple Features

```bash
# User authentication feature
alpha-5 add user-authentication

# Notification system
alpha-5 add notification-system

# Analytics dashboard
alpha-5 add analytics-dashboard
```

### Example 3: Update Existing Features

```bash
# Create a feature
alpha-5 add payment-gateway

# ... time passes, infinite-lending repo gets updates ...

# Update the feature with latest configuration
alpha-5 update payment-gateway
```

### Example 4: List and Manage Features

```bash
# List all features
alpha-5 list

# Create a new feature
alpha-5 add reporting-dashboard

# List again to see the new feature
alpha-5 list

# Delete an old feature
alpha-5 delete old-prototype
```

### Example 5: Check Your Setup

```bash
# View help and current configuration
alpha-5 help

# Check where features are being created
echo $ALPHA5_FEATURES_PATH

# List all features with alpha-5
alpha-5 list

# Or use system commands
ls $ALPHA5_FEATURES_PATH
```

## ⚙️ Configuration

### Environment Variables

After installation, the following environment variables are configured in `~/.zshrc`:

| Variable | Description | Example |
|----------|-------------|---------|
| `ALPHA5_HOME` | Path to the alpha-5-cli directory | `/Users/ricardo/alpha-5-cli` |
| `ALPHA5_FEATURES_PATH` | Path where features will be created | `/Users/ricardo/features` |

### Verify Configuration

Check your current configuration:

```bash
# View all alpha-5 related configuration
cat ~/.zshrc | grep -A 3 "Alpha-5 CLI"

# Check individual variables
echo "CLI Home: $ALPHA5_HOME"
echo "Features Path: $ALPHA5_FEATURES_PATH"

# Test the alias
which alpha-5
```

### Change Features Path

**Method 1: Manual Edit**

1. Open your shell configuration:
   ```bash
   nano ~/.zshrc
   # or
   code ~/.zshrc
   ```

2. Find and update the line:
   ```bash
   export ALPHA5_FEATURES_PATH="/new/path/to/features"
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

**Method 2: Reinstall**

Run the install script again with a new path:

```bash
cd /path/to/alpha-5-cli
./install.sh /new/path/to/features
```

The installer will detect the existing configuration and ask if you want to update it.

## 📂 Project Structure

### CLI Directory Structure

```
alpha-5-cli/
├── alpha-5.sh           # Main CLI wrapper script
├── setup_feature.sh     # Feature setup script (creates features)
├── update_feature.sh    # Feature update script (syncs config files)
├── install.sh           # Installation script (adds to PATH)
├── README.md            # Documentation
└── features/            # Default features location (if not customized)
```

### Created Feature Structure

When you run `alpha-5 add feature-name`, the following structure is created:

```
$ALPHA5_FEATURES_PATH/
└── feature-name/
    └── infinite-lending/
        ├── feature-name/               # Your workspace
        ├── development.env
        ├── .claude/
        │   └── settings.local.json
        └── ... (all other repository files)
```

**Example with actual features:**

```
~/my-features/
├── payment-gateway/
│   └── infinite-lending/
│       ├── payment-gateway/           # Workspace for this feature
│       ├── development.env
│       ├── .claude/
│       │   └── settings.local.json
│       └── ... (repository files)
├── user-auth/
│   └── infinite-lending/
│       ├── user-auth/                 # Workspace for this feature
│       ├── development.env
│       └── ... (repository files)
└── notification-system/
    └── infinite-lending/
        ├── notification-system/       # Workspace for this feature
        ├── development.env
        └── ... (repository files)
```

## Uninstallation

To remove the alpha-5 command from your shell:

1. Open `~/.zshrc` in your editor
2. Remove the following lines:
   ```bash
   # Alpha-5 CLI
   export ALPHA5_HOME="..."
   export ALPHA5_FEATURES_PATH="..."
   alias alpha-5="..."
   ```
3. Reload your shell: `source ~/.zshrc`

## 🔧 Troubleshooting

### Issue: `command not found: alpha-5`

**Symptoms:**
```bash
$ alpha-5 help
zsh: command not found: alpha-5
```

**Solutions:**

1. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

2. **Verify the alias was added:**
   ```bash
   cat ~/.zshrc | grep alpha-5
   ```
   You should see:
   ```bash
   # Alpha-5 CLI
   export ALPHA5_HOME="..."
   export ALPHA5_FEATURES_PATH="..."
   alias alpha-5="..."
   ```

3. **Check if using bash instead of zsh:**
   ```bash
   echo $SHELL
   ```
   If using bash, the installer needs to target `~/.bashrc` or `~/.bash_profile`

4. **Reinstall:**
   ```bash
   cd /path/to/alpha-5-cli
   ./install.sh
   ```

---

### Issue: Permission Denied

**Symptoms:**
```bash
$ ./install.sh
-bash: ./install.sh: Permission denied
```

**Solutions:**

1. **Make scripts executable:**
   ```bash
   chmod +x install.sh alpha-5.sh setup_feature.sh
   ```

2. **Run with bash explicitly:**
   ```bash
   bash install.sh
   ```

---

### Issue: Source Repository Not Found (Update Command)

**Symptoms:**
```bash
❌ FAIL: infinite-lending repository not found at $HOME/projects/repos/infinite-lending
```

**Note:** This error only occurs when using the `update` command. The `add` command clones directly from GitHub.

**Solutions:**

1. **Verify the repository exists:**
   ```bash
   ls $HOME/projects/repos/infinite-lending
   ```

2. **Clone the repository if missing:**
   ```bash
   mkdir -p $HOME/projects/repos
   cd $HOME/projects/repos
   git clone https://github.com/cloudwalk/infinite-lending.git
   ```

3. **Check required files exist:**
   ```bash
   ls $HOME/projects/repos/infinite-lending/development.env
   ls $HOME/projects/repos/infinite-lending/.claude/settings.local.json
   ```

---

### Issue: Feature Directory Already Exists

**Symptoms:**
```bash
❌ FAIL: Failed to create directory (directory already exists)
```

**Solutions:**

1. **Use a different feature name:**
   ```bash
   alpha-5 add payment-gateway-v2
   ```

2. **Remove the existing feature:**
   ```bash
   rm -rf $ALPHA5_FEATURES_PATH/feature-name
   alpha-5 add feature-name
   ```

3. **Check existing features:**
   ```bash
   ls $ALPHA5_FEATURES_PATH
   ```

---

### Issue: Wrong Features Path

**Symptoms:**
- Features are being created in the wrong location

**Solutions:**

1. **Check current configuration:**
   ```bash
   echo $ALPHA5_FEATURES_PATH
   ```

2. **Update the path:**
   ```bash
   # Edit ~/.zshrc
   nano ~/.zshrc
   
   # Find and update:
   export ALPHA5_FEATURES_PATH="/correct/path"
   
   # Reload
   source ~/.zshrc
   ```

3. **Or reinstall with correct path:**
   ```bash
   ./install.sh /correct/path/to/features
   ```

---

### Issue: List Shows "No features found"

**Symptoms:**
```bash
$ alpha-5 list
No features found
```

**Solutions:**

1. **Verify you've created features:**
   ```bash
   # Create a feature first
   alpha-5 add test-feature
   
   # Then list
   alpha-5 list
   ```

2. **Check the features path:**
   ```bash
   echo $ALPHA5_FEATURES_PATH
   ls $ALPHA5_FEATURES_PATH
   ```

3. **Verify features directory exists:**
   ```bash
   # If it doesn't exist, create a feature to initialize it
   alpha-5 add my-first-feature
   ```

---

### Issue: Cannot Delete Feature

**Symptoms:**
```bash
❌ ERROR: Feature 'feature-name' does not exist
```

**Solutions:**

1. **List all features to see exact names:**
   ```bash
   alpha-5 list
   ```

2. **Check for typos in feature name:**
   - Feature names are case-sensitive
   - Make sure there are no extra spaces

3. **Verify feature exists:**
   ```bash
   ls $ALPHA5_FEATURES_PATH
   ```

---

### Issue: Accidental Deletion

**Prevention:**
- Always double-check the feature name before typing "yes"
- Use `alpha-5 list` to verify the feature exists before deleting
- The delete command shows feature details before confirmation

**Recovery:**
- Deleted features cannot be recovered
- However, you can recreate them: `alpha-5 add feature-name`
- This will copy fresh configuration files from the repository

---

### Issue: Update Overwrites My Custom Configuration

**Symptoms:**
- Custom changes to configuration files are being overwritten

**Solutions:**

1. **Understand what update does:**
   ```
   Updated (overwritten):
   - development.env
   - .claude/settings.local.json
   ```

2. **Backup before update:**
   ```bash
   # Backup your custom configurations
   cp $ALPHA5_FEATURES_PATH/feature-name/development.env \
      $ALPHA5_FEATURES_PATH/feature-name/development.env.backup

   cp $ALPHA5_FEATURES_PATH/feature-name/.claude/settings.local.json \
      $ALPHA5_FEATURES_PATH/feature-name/.claude/settings.local.json.backup
   ```

3. **Use version control:**
   ```bash
   cd $ALPHA5_FEATURES_PATH/feature-name
   git init
   git add .
   git commit -m "Before update"

   # Now update
   alpha-5 update feature-name

   # Review changes
   git diff
   ```

---

### Issue: Update Fails - Feature Not Found

**Symptoms:**
```bash
❌ ERROR: Feature 'feature-name' does not exist
```

**Solutions:**

1. **Verify feature exists:**
   ```bash
   alpha-5 list
   ```

2. **Check feature name spelling:**
   - Feature names are case-sensitive
   - Make sure there are no typos

3. **Use add instead of update:**
   ```bash
   # If feature doesn't exist, create it first
   alpha-5 add feature-name
   ```

---

### Issue: Missing Configuration Files

**Symptoms:**
```bash
❌ FAIL: development.env not found in source repository
```

**Solutions:**

1. **Verify files exist in source repository:**
   ```bash
   ls -la $HOME/projects/repos/infinite-lending/development.env
   ls -la $HOME/projects/repos/infinite-lending/.claude/settings.local.json
   ```

2. **Pull latest changes from source repository:**
   ```bash
   cd $HOME/projects/repos/infinite-lending
   git pull origin main
   ```

---

## 🗑️ Uninstallation

To completely remove the Alpha-5 CLI from your system:

### Step 1: Remove Shell Configuration

1. Open your shell configuration file:
   ```bash
   nano ~/.zshrc
   # or
   code ~/.zshrc
   ```

2. Find and delete these lines:
   ```bash
   # Alpha-5 CLI
   export ALPHA5_HOME="/path/to/alpha-5-cli"
   export ALPHA5_FEATURES_PATH="/path/to/features"
   alias alpha-5="bash $ALPHA5_HOME/alpha-5.sh"
   ```

3. Save and reload:
   ```bash
   source ~/.zshrc
   ```

### Step 2: (Optional) Remove Features

If you want to remove all created features:

```bash
# List features first to confirm
ls $ALPHA5_FEATURES_PATH

# Remove all features (be careful!)
rm -rf $ALPHA5_FEATURES_PATH
```

### Step 3: (Optional) Remove CLI Scripts

If you no longer need the CLI scripts:

```bash
# Remove the entire alpha-5-cli directory
rm -rf /path/to/alpha-5-cli
```

### Verify Uninstallation

```bash
# This should return nothing
which alpha-5

# This should return empty
echo $ALPHA5_HOME
```

---

## 📋 Requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Operating System** | macOS, Linux | Windows WSL also supported |
| **Shell** | zsh | Default on macOS; bash can be used with modifications |
| **Git** | 2.0+ | Required for cloning repositories |
| **Bash** | 4.0+ | For running scripts |

### Check Requirements

```bash
# Check shell
echo $SHELL

# Check Git version
git --version

# Check Bash version
bash --version
```

---

## 🚀 Commands Reference

| Command | Description | Example | Aliases |
|---------|-------------|---------|---------|
| `alpha-5 help` | Show help and configuration | `alpha-5 help` | `-h`, `--help` |
| `alpha-5 add <name>` | Create a new feature | `alpha-5 add payment-gateway` | `create` |
| `alpha-5 list` | List all existing features | `alpha-5 list` | `ls` |
| `alpha-5 update <name>` | Update feature config files | `alpha-5 update payment-gateway` | `sync` |
| `alpha-5 update-all` | Update all features at once | `alpha-5 update-all` | - |
| `alpha-5 status <name>` | Show git status of a feature | `alpha-5 status payment-gateway` | `st` |
| `alpha-5 path <name>` | Print absolute path to feature | `alpha-5 path payment-gateway` | - |
| `alpha-5 open <name>` | Print path to feature repository | `alpha-5 open payment-gateway` | - |
| `a5open <name>` | Navigate to feature repository | `a5open payment-gateway` | - |
| `alpha-5 delete <name>` | Delete a feature (with confirmation) | `alpha-5 delete old-feature` | `remove`, `rm` |
| `alpha-5 version` | Show CLI version | `alpha-5 version` | `-v`, `--version` |

---

## 📝 FAQ

**Q: Can I use this with bash instead of zsh?**  
A: Yes, but you'll need to modify the installer to use `~/.bashrc` or `~/.bash_profile` instead of `~/.zshrc`.

**Q: Where does the CLI get the configuration files from?**
A: The `add` command clones the `infinite-lending` repository from GitHub into the feature directory, then copies config files from your local repo at `$HOME/projects/repos/infinite-lending` into the cloned repo. The `update` command also copies files from your local infinite-lending repository.

**Q: Can I have multiple features directories?**  
A: The CLI uses one configured path (`$ALPHA5_FEATURES_PATH`), but you can change it anytime and create features in different locations.

**Q: What if the feature name contains spaces?**  
A: Use quotes: `alpha-5 add "my feature name"` or use dashes: `alpha-5 add my-feature-name` (recommended)

**Q: Can I customize what gets copied?**
A: Yes! Edit the `setup_feature.sh` script to customize which files get copied or add additional setup steps.

**Q: How do I see all my features?**  
A: Use `alpha-5 list` to see all features in your configured path, or use `ls $ALPHA5_FEATURES_PATH` for a simple directory listing.

**Q: Can I recover a deleted feature?**  
A: No, the `delete` command permanently removes the feature directory. There is no undo. Always confirm you're deleting the correct feature before typing "yes".

**Q: What happens if I accidentally type "yes" when deleting?**
A: The feature will be permanently deleted. However, you can always recreate it using `alpha-5 add feature-name` and it will copy the configuration files from the repository again.

**Q: Can I rename a feature?**  
A: The CLI doesn't have a rename command, but you can manually rename the directory: `mv $ALPHA5_FEATURES_PATH/old-name $ALPHA5_FEATURES_PATH/new-name`

**Q: What's the difference between `add` and `update`?**
A: `add` creates a new feature by cloning the infinite-lending repository from GitHub and copying config files from your local repo. `update` refreshes an existing feature's config files by copying from your local infinite-lending repository.

**Q: Will `update` overwrite my changes?**
A: Yes, the update command overwrites:
- development.env
- .claude/settings.local.json

It's recommended to commit your changes or create backups before updating.

**Q: When should I use the `update` command?**
A: Use `update` when:
- The infinite-lending repository has new environment variables
- Configuration files have been updated in the source repository
- You need to sync configuration changes to your existing features

**Q: Can I update all features at once?**
A: Yes! Use the `alpha-5 update-all` command to update configuration files for all features in one go.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report bugs** - Open an issue describing the problem
2. **Suggest features** - Share ideas for improvements
3. **Submit PRs** - Fix bugs or add new features
4. **Improve docs** - Help make this README better

---

## 📄 License

MIT License - feel free to use this in your projects!

---

## 💪 PowerLenders

Built with ❤️ by the PowerLenders team

```
 __   __        ___  __        ___       __   ___  __   __ 
|__) /  \ |  | |__  |__) |    |__  |\ | |  \ |__  |__) /__`
|    \__/ |/\| |___ |  \ |___ |___ | \| |__/ |___ |  \ .__/
```

---

**Version:** 2.3.0
**Last Updated:** February 2026
