#!/bin/bash

# Alpha-5 CLI Uninstallation Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}🗑️  Alpha-5 CLI Uninstaller${NC}"
echo ""

SHELL_RC="$HOME/.zshrc"

if [ ! -f "$SHELL_RC" ]; then
    echo -e "${YELLOW}⚠️  .zshrc not found${NC}"
    exit 0
fi

# Create backup
cp "$SHELL_RC" "$SHELL_RC.backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${GREEN}✅ Created backup${NC}"

# Remove all Alpha-5 related configuration
# This removes everything from "# Alpha-5 CLI" comment through all related functions
awk '
    BEGIN { skip=0; in_alpha5_func=0; in_a5open_func=0 }

    # Start skipping at Alpha-5 CLI comment
    /^# Alpha-5 CLI/ { skip=1; next }

    # Track when we enter functions
    /^a5\(\)/ { in_alpha5_func=1; skip=1; next }
    /^a5open\(\)/ { in_a5open_func=1; skip=1; next }

    # Track when we exit functions (closing brace at start of line)
    /^}$/ {
        if (in_alpha5_func) { in_alpha5_func=0; skip=1; next }
        if (in_a5open_func) { in_a5open_func=0; skip=1; next }
    }

    # Skip lines related to Alpha-5
    /^export ALPHA5_HOME=/ { skip=1; next }
    /^export ALPHA5_FEATURES_PATH=/ { skip=1; next }
    /^alias alpha-5=/ { skip=1; next }

    # Skip if we are in skip mode or inside a function
    skip || in_alpha5_func || in_a5open_func {
        # Check if this is a blank line after our section
        if (/^$/ && skip && !in_alpha5_func && !in_a5open_func) {
            skip=0
        }
        next
    }

    # Print everything else
    { print }
' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"

echo -e "${GREEN}✅ Removed Alpha-5 configuration${NC}"
echo ""
echo -e "${CYAN}Uninstallation complete!${NC}"
echo ""
echo "To reinstall cleanly:"
echo "  1. ./install.sh"
echo "  2. source ~/.zshrc"
echo ""
