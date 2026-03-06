#!/bin/bash

# Alpha-5 CLI Uninstallation Script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}Alpha-5 CLI Uninstaller${NC}"
echo ""

SHELL_RC="$HOME/.zshrc"

if [ ! -f "$SHELL_RC" ]; then
    echo -e "${YELLOW}.zshrc not found${NC}"
    exit 0
fi

# Create backup
cp "$SHELL_RC" "$SHELL_RC.backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${GREEN}Created backup${NC}"

# Remove all Alpha-5 related configuration
awk '
    BEGIN { skip=0; in_alpha5_func=0; in_a5open_func=0 }

    /^# Alpha-5 CLI/ { skip=1; next }

    /^a5\(\)/ { in_alpha5_func=1; skip=1; next }
    /^a5open\(\)/ { in_a5open_func=1; skip=1; next }

    /^}$/ {
        if (in_alpha5_func) { in_alpha5_func=0; skip=1; next }
        if (in_a5open_func) { in_a5open_func=0; skip=1; next }
    }

    /^export ALPHA5_HOME=/ { skip=1; next }
    /^export ALPHA5_FEATURES_PATH=/ { skip=1; next }
    /^alias alpha-5=/ { skip=1; next }

    skip || in_alpha5_func || in_a5open_func {
        if (/^$/ && skip && !in_alpha5_func && !in_a5open_func) {
            skip=0
        }
        next
    }

    { print }
' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"

echo -e "${GREEN}Removed Alpha-5 configuration${NC}"
echo ""
echo -e "${CYAN}Uninstallation complete!${NC}"
echo ""
echo "Note: Existing worktrees are untouched. Remove them manually with:"
echo "  git worktree list    # see all worktrees"
echo "  git worktree remove <path>"
echo ""
echo "To reinstall:"
echo "  ./install.sh"
echo "  source ~/.zshrc"
echo ""
