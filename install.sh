#!/bin/bash

# Alpha-5 CLI Installation Script
# Sets up the a5 command in your shell

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Display header
clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "========================================"
echo "    Alpha-5 CLI Installation"
echo "    Git Worktree Feature Manager"
echo "========================================"
echo -e "${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALPHA5_SCRIPT="$SCRIPT_DIR/alpha-5.sh"

# Check if alpha-5.sh exists
if [ ! -f "$ALPHA5_SCRIPT" ]; then
    echo -e "${RED}ERROR: alpha-5.sh not found at $ALPHA5_SCRIPT${NC}"
    exit 1
fi

# Make scripts executable
chmod +x "$ALPHA5_SCRIPT"
echo -e "${GREEN}Made alpha-5.sh executable${NC}"

# Detect shell configuration file
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    echo -e "${YELLOW}.zshrc not found, creating it...${NC}"
    touch "$SHELL_RC"
fi

# Create shell function configuration
ALIAS_CONFIG="
# Alpha-5 CLI
export ALPHA5_HOME=\"$SCRIPT_DIR\"

# Main a5 function with special handling for 'open' and 'add' commands
a5() {
    if [ \"\$1\" = \"open\" ]; then
        local feature_name=\$2
        local repo_path=\$(bash \$ALPHA5_HOME/alpha-5.sh open \"\$feature_name\" 2>/dev/null)
        if [ \$? -eq 0 ] && [ -n \"\$repo_path\" ]; then
            cd \"\$repo_path\"
        else
            bash \$ALPHA5_HOME/alpha-5.sh open \"\$feature_name\"
        fi
    elif [ \"\$1\" = \"add\" ] || [ \"\$1\" = \"create\" ]; then
        local output=\$(bash \$ALPHA5_HOME/alpha-5.sh \"\$@\" 2>&1)
        echo \"\$output\" | grep -v \"__A5_AUTO_CD__\"

        local cd_path=\$(echo \"\$output\" | grep \"__A5_AUTO_CD__\" | cut -d: -f2-)
        if [ -n \"\$cd_path\" ] && [ -d \"\$cd_path\" ]; then
            cd \"\$cd_path\"
            echo \"Opened workspace: \$cd_path\"
        fi
    else
        bash \$ALPHA5_HOME/alpha-5.sh \"\$@\"
    fi
}

# Aliases
alias alpha-5='a5'
a5open() {
    a5 open \"\$1\"
}
"

# Check if a5 function already exists
if grep -q "^a5()" "$SHELL_RC" 2>/dev/null || grep -q "alias alpha-5=" "$SHELL_RC" 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}Alpha-5 configuration already exists in $SHELL_RC${NC}"
    echo ""
    read -p "Update it? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove old configuration
        awk '
            /# Alpha-5 CLI/ { skip=1 }
            skip && /^}$/ { skip=0; next }
            skip && /^alias alpha-5=/ { skip=0; next }
            skip && /^a5open\(\)/ && c==0 { c=1 }
            c && /^}$/ { c=0; skip=0; next }
            !skip
        ' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"

        echo -e "${GREEN}Removed old configuration${NC}"
    else
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

# Add function to .zshrc
echo "$ALIAS_CONFIG" >> "$SHELL_RC"
echo -e "${GREEN}Added a5 function and alpha-5 alias to $SHELL_RC${NC}"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "To start using alpha-5, run:"
echo "  source ~/.zshrc"
echo ""
echo "Then navigate to any git repo and:"
echo "  a5 add feat:my-feature   # Create a feature worktree"
echo "  a5 list                  # List features for this repo"
echo "  a5 open feat:my-feature  # Navigate to a feature"
echo "  a5 help                  # See all commands"
echo ""

# Offer to source immediately
read -p "Reload shell configuration now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "Run: ${CYAN}source ~/.zshrc${NC}"
    echo ""
fi
