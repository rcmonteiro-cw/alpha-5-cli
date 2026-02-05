# 🚀 PowerLenders Alpha-5 CLI

```
 __   __        ___  __        ___       __   ___  __   __ 
|__) /  \ |  | |__  |__) |    |__  |\ | |  \ |__  |__) /__`
|    \__/ |/\| |___ |  \ |___ |___ | \| |__/ |___ |  \ .__/
```

A powerful command-line tool for managing features in the Alpha-5 project. Quickly scaffold new features with pre-configured agents from the infinite-lending repository.

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

# 6. Get help anytime
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
2. 📁 Creates agents directory inside the feature
3. 📦 Clones the `infinite-lending` repository to a temporary location
4. 📋 Copies all agents contents from the repository
5. 🧹 Cleans up temporary files
6. ✅ Displays success message with feature location

**Example:**
```bash
alpha-5 add payment-gateway
```

**Output:**
```
🚀 Setting up feature: payment-gateway
📁 Creating feature directory...
✅ SUCCESS: Created directory /path/to/features/payment-gateway
📂 Creating agents directory...
✅ SUCCESS: Created agents directory at /path/to/features/payment-gateway/agents
📦 Cloning infinite-lending repository to /tmp...
✅ SUCCESS: Cloned infinite-lending repository
📋 Copying agents contents...
✅ SUCCESS: Copied all agents contents
🧹 Cleaning up temporary files...
✅ SUCCESS: Cleaned up temporary repository
🎉 Feature setup completed successfully!
📍 Feature location: /path/to/features/payment-gateway
```

### 📋 List All Features

View all existing features in your configured features path:

```bash
alpha-5 list
```

**Output example:**
```
📁 Features in: /Users/ricardo/features

✓ payment-gateway
✓ user-authentication
✓ notification-system
⚠ incomplete-feature (missing agents folder)

Total: 4 feature(s)
```

**Features:**
- Shows all features in your configured path
- Indicates which features have the agents folder (✓)
- Warns about incomplete features (⚠)
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

### 🏷️ Show Version

Display the current version of the CLI:

```bash
alpha-5 version
```

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
    └── agents/
        └── [all agents from infinite-lending repo]
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

### Example 3: List and Manage Features

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

### Example 4: Check Your Setup

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
├── install.sh           # Installation script (adds to PATH)
├── README.md            # Documentation
└── features/            # Default features location (if not customized)
```

### Created Feature Structure

When you run `alpha-5 add feature-name`, the following structure is created:

```
$ALPHA5_FEATURES_PATH/
└── feature-name/
    └── agents/
        ├── [agent files and folders from infinite-lending repo]
        └── ...
```

**Example with actual feature:**

```
~/my-features/
├── payment-gateway/
│   └── agents/
│       ├── config/
│       ├── rules/
│       └── ...
├── user-auth/
│   └── agents/
│       ├── config/
│       ├── rules/
│       └── ...
└── notification-system/
    └── agents/
        ├── config/
        ├── rules/
        └── ...
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

### Issue: Git Clone Fails

**Symptoms:**
```bash
❌ FAIL: Failed to clone infinite-lending repository
```

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping github.com
   ```

2. **Verify Git is installed:**
   ```bash
   git --version
   ```

3. **Check repository URL access:**
   ```bash
   git ls-remote https://github.com/cloudwalk/infinite-lending.git
   ```

4. **SSH vs HTTPS:** If using SSH, ensure your keys are configured:
   ```bash
   ssh -T git@github.com
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
- This will clone fresh agents from the repository

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
| `alpha-5 delete <name>` | Delete a feature (with confirmation) | `alpha-5 delete old-feature` | `remove`, `rm` |
| `alpha-5 version` | Show CLI version | `alpha-5 version` | `-v`, `--version` |

---

## 📝 FAQ

**Q: Can I use this with bash instead of zsh?**  
A: Yes, but you'll need to modify the installer to use `~/.bashrc` or `~/.bash_profile` instead of `~/.zshrc`.

**Q: Where does the CLI clone the infinite-lending repository?**  
A: It clones to a temporary directory `/tmp/infinite-lending-<timestamp>` which is automatically cleaned up after copying.

**Q: Can I have multiple features directories?**  
A: The CLI uses one configured path (`$ALPHA5_FEATURES_PATH`), but you can change it anytime and create features in different locations.

**Q: What if the feature name contains spaces?**  
A: Use quotes: `alpha-5 add "my feature name"` or use dashes: `alpha-5 add my-feature-name` (recommended)

**Q: Can I customize what gets copied?**  
A: Yes! Edit the `setup_feature.sh` script to customize the repository URL, what folders get copied, or add additional setup steps.

**Q: How do I see all my features?**  
A: Use `alpha-5 list` to see all features in your configured path, or use `ls $ALPHA5_FEATURES_PATH` for a simple directory listing.

**Q: Can I recover a deleted feature?**  
A: No, the `delete` command permanently removes the feature directory. There is no undo. Always confirm you're deleting the correct feature before typing "yes".

**Q: What happens if I accidentally type "yes" when deleting?**  
A: The feature will be permanently deleted. However, you can always recreate it using `alpha-5 add feature-name` and it will clone the agents from the repository again.

**Q: Can I rename a feature?**  
A: The CLI doesn't have a rename command, but you can manually rename the directory: `mv $ALPHA5_FEATURES_PATH/old-name $ALPHA5_FEATURES_PATH/new-name`

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

**Version:** 1.0.0  
**Last Updated:** February 2026
