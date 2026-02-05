#!/bin/bash

# Alpha-5 CLI Installation Script
# This script sets up the alpha-5 command in your shell

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Display header
clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║     __   __        ___  __        ___       __   ___  __   __     ║"
echo "║    |__) /  \ |  | |__  |__) |    |__  |\ | |  \ |__  |__) /__\`    ║"
echo "║    |    \__/ |/\| |___ |  \ |___ |___ | \| |__/ |___ |  \ .__/    ║"
echo "║                                                                   ║"
echo "║                  🚀 Alpha-5 CLI Installation 🚀                   ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALPHA5_SCRIPT="$SCRIPT_DIR/alpha-5.sh"

# Get features path from argument or use default
FEATURES_PATH="$1"
if [ -z "$FEATURES_PATH" ]; then
    FEATURES_PATH="$SCRIPT_DIR/features"
    echo -e "${YELLOW}ℹ️  No features path specified, using default: $FEATURES_PATH${NC}"
else
    # Expand ~ to home directory if needed
    FEATURES_PATH="${FEATURES_PATH/#\~/$HOME}"
    # Convert to absolute path
    FEATURES_PATH="$(cd "$(dirname "$FEATURES_PATH")" 2>/dev/null && pwd)/$(basename "$FEATURES_PATH")" || FEATURES_PATH="$FEATURES_PATH"
    echo -e "${GREEN}✅ Features will be created in: $FEATURES_PATH${NC}"
fi
echo ""

# Check if alpha-5.sh exists
if [ ! -f "$ALPHA5_SCRIPT" ]; then
    echo -e "${RED}❌ ERROR: alpha-5.sh not found at $ALPHA5_SCRIPT${NC}"
    exit 1
fi

# Make alpha-5.sh executable
chmod +x "$ALPHA5_SCRIPT"
echo -e "${GREEN}✅ Made alpha-5.sh executable${NC}"

# Make setup_feature.sh executable
SETUP_SCRIPT="$SCRIPT_DIR/setup_feature.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    chmod +x "$SETUP_SCRIPT"
    echo -e "${GREEN}✅ Made setup_feature.sh executable${NC}"
fi

# Make update_feature.sh executable
UPDATE_SCRIPT="$SCRIPT_DIR/update_feature.sh"
if [ -f "$UPDATE_SCRIPT" ]; then
    chmod +x "$UPDATE_SCRIPT"
    echo -e "${GREEN}✅ Made update_feature.sh executable${NC}"
fi

# Detect shell configuration file
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    echo -e "${YELLOW}⚠️  .zshrc not found, creating it...${NC}"
    touch "$SHELL_RC"
fi

# Create alias configuration
ALIAS_CONFIG="
# Alpha-5 CLI
export ALPHA5_HOME=\"$SCRIPT_DIR\"
export ALPHA5_FEATURES_PATH=\"$FEATURES_PATH\"
alias alpha-5=\"bash \$ALPHA5_HOME/alpha-5.sh\"
"

# Check if alias already exists
if grep -q "alias alpha-5=" "$SHELL_RC" 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}⚠️  Alpha-5 alias already exists in $SHELL_RC${NC}"
    echo ""
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove old configuration
        sed -i.backup '/# Alpha-5 CLI/,/alias alpha-5=/d' "$SHELL_RC"
        echo -e "${GREEN}✅ Removed old configuration${NC}"
    else
        echo -e "${YELLOW}⚠️  Installation cancelled${NC}"
        exit 0
    fi
fi

# Add alias to .zshrc
echo "$ALIAS_CONFIG" >> "$SHELL_RC"
echo -e "${GREEN}✅ Added alpha-5 alias to $SHELL_RC${NC}"

echo ""
echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
echo ""
echo -e "${BLUE}Features path:${NC} $FEATURES_PATH"
echo ""
echo "To start using alpha-5, either:"
echo "  1. Run: source ~/.zshrc"
echo "  2. Or restart your terminal"
echo ""
echo "Then try:"
echo "  alpha-5 help"
echo "  alpha-5 add my-feature"
echo ""

# Offer to source immediately
read -p "Would you like to reload your shell configuration now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Note: Run 'source ~/.zshrc' in your current terminal, or try:${NC}"
    echo -e "${YELLOW}  alpha-5 help${NC}"
    echo ""
    echo "Installation complete! 🚀"
else
    echo ""
    echo "Remember to run 'source ~/.zshrc' or restart your terminal!"
fi
