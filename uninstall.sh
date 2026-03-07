#!/bin/bash

# Alpha-5 CLI Uninstallation Script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${CYAN}Alpha-5 CLI Uninstaller${NC}"
echo ""

# ─── Detect shell ─────────────────────────────────────────────────────────────

detect_shell_rc() {
    local user_shell
    user_shell="$(basename "$SHELL")"

    case "$user_shell" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [ "$(uname)" = "Darwin" ] && [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            elif [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo ""
            ;;
    esac
}

SHELL_RC="$(detect_shell_rc)"
DETECTED_SHELL="$(basename "$SHELL")"

if [ -z "$SHELL_RC" ]; then
    echo -e "${RED}ERROR: Unsupported shell '$DETECTED_SHELL'${NC}"
    exit 1
fi

if [ ! -f "$SHELL_RC" ]; then
    echo -e "${YELLOW}$SHELL_RC not found, nothing to uninstall${NC}"
    exit 0
fi

if ! grep -q "# Alpha-5 CLI" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}Alpha-5 not found in $SHELL_RC, nothing to uninstall${NC}"
    exit 0
fi

echo -e "${CYAN}Shell: $DETECTED_SHELL${NC}"
echo -e "${CYAN}Config: $SHELL_RC${NC}"
echo ""

# Create backup
cp "$SHELL_RC" "$SHELL_RC.backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${GREEN}Created backup${NC}"

# Remove configuration
if [ "$DETECTED_SHELL" = "fish" ]; then
    sed -i.bak '/^# Alpha-5 CLI$/,/^alias alpha-5/d' "$SHELL_RC"
    rm -f "$SHELL_RC.bak"
else
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
fi

echo -e "${GREEN}Removed Alpha-5 configuration from $SHELL_RC${NC}"
echo ""
echo -e "${CYAN}Uninstallation complete!${NC}"
echo ""
echo "Note: Existing worktrees are untouched. Remove them manually with:"
echo "  git worktree list    # see all worktrees"
echo "  git worktree remove <path>"
echo ""
echo "To reinstall:"
echo "  ./install.sh"
echo "  source $SHELL_RC"
echo ""
