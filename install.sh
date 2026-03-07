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

# ─── Detect shell ─────────────────────────────────────────────────────────────

detect_shell_rc() {
    local user_shell
    user_shell="$(basename "$SHELL")"

    case "$user_shell" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            # macOS uses .bash_profile, Linux uses .bashrc
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
    echo ""
    echo "Supported shells: zsh, bash, fish"
    echo "You can manually source the a5 function from alpha-5.sh"
    exit 1
fi

echo -e "${CYAN}Detected shell: $DETECTED_SHELL${NC}"
echo -e "${CYAN}Config file: $SHELL_RC${NC}"
echo ""

# Create config file if it doesn't exist
if [ ! -f "$SHELL_RC" ]; then
    mkdir -p "$(dirname "$SHELL_RC")"
    touch "$SHELL_RC"
    echo -e "${YELLOW}Created $SHELL_RC${NC}"
fi

# ─── Generate config for bash/zsh ─────────────────────────────────────────────

generate_posix_config() {
    cat <<POSIXEOF

# Alpha-5 CLI
export ALPHA5_HOME="$SCRIPT_DIR"

# Main a5 function with special handling for 'open' and 'add' commands
a5() {
    if [ "\$1" = "open" ]; then
        local feature_name=\$2
        local repo_path=\$(bash \$ALPHA5_HOME/alpha-5.sh open "\$feature_name" 2>/dev/null)
        if [ \$? -eq 0 ] && [ -n "\$repo_path" ]; then
            cd "\$repo_path"
        else
            bash \$ALPHA5_HOME/alpha-5.sh open "\$feature_name"
        fi
    elif [ "\$1" = "add" ] || [ "\$1" = "create" ]; then
        local output=\$(bash \$ALPHA5_HOME/alpha-5.sh "\$@" 2>&1)
        echo "\$output" | grep -v "__A5_AUTO_CD__"

        local cd_path=\$(echo "\$output" | grep "__A5_AUTO_CD__" | cut -d: -f2-)
        if [ -n "\$cd_path" ] && [ -d "\$cd_path" ]; then
            cd "\$cd_path"
            echo "Opened workspace: \$cd_path"
        fi
    else
        bash \$ALPHA5_HOME/alpha-5.sh "\$@"
    fi
}

# Aliases
alias alpha-5='a5'
a5open() {
    a5 open "\$1"
}
POSIXEOF
}

# ─── Generate config for fish ─────────────────────────────────────────────────

generate_fish_config() {
    cat <<FISHEOF

# Alpha-5 CLI
set -gx ALPHA5_HOME "$SCRIPT_DIR"

function a5
    if test "\$argv[1]" = "open"
        set -l repo_path (bash \$ALPHA5_HOME/alpha-5.sh open "\$argv[2]" 2>/dev/null)
        if test \$status -eq 0 -a -n "\$repo_path"
            cd "\$repo_path"
        else
            bash \$ALPHA5_HOME/alpha-5.sh open "\$argv[2]"
        end
    else if test "\$argv[1]" = "add" -o "\$argv[1]" = "create"
        set -l output (bash \$ALPHA5_HOME/alpha-5.sh \$argv 2>&1)
        for line in \$output
            if not string match -q "__A5_AUTO_CD__*" "\$line"
                echo "\$line"
            end
        end

        set -l cd_path (string match -r '__A5_AUTO_CD__:(.+)' "\$output" | tail -1)
        if test -n "\$cd_path" -a -d "\$cd_path"
            cd "\$cd_path"
            echo "Opened workspace: \$cd_path"
        end
    else
        bash \$ALPHA5_HOME/alpha-5.sh \$argv
    end
end

function a5open
    a5 open \$argv[1]
end

alias alpha-5='a5'
FISHEOF
}

# ─── Install ──────────────────────────────────────────────────────────────────

# Check if already installed
if grep -q "# Alpha-5 CLI" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}Alpha-5 configuration already exists in $SHELL_RC${NC}"
    echo ""
    read -p "Update it? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ "$DETECTED_SHELL" = "fish" ]; then
            # Remove fish config block
            sed -i.bak '/^# Alpha-5 CLI$/,/^alias alpha-5/d' "$SHELL_RC"
            rm -f "$SHELL_RC.bak"
        else
            # Remove bash/zsh config block
            awk '
                /# Alpha-5 CLI/ { skip=1 }
                skip && /^}$/ { skip=0; next }
                skip && /^alias alpha-5=/ { skip=0; next }
                skip && /^a5open\(\)/ && c==0 { c=1 }
                c && /^}$/ { c=0; skip=0; next }
                !skip
            ' "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
        fi
        echo -e "${GREEN}Removed old configuration${NC}"
    else
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

# Write config
if [ "$DETECTED_SHELL" = "fish" ]; then
    generate_fish_config >> "$SHELL_RC"
else
    generate_posix_config >> "$SHELL_RC"
fi

echo -e "${GREEN}Added a5 function and alpha-5 alias to $SHELL_RC${NC}"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "To start using alpha-5, run:"

if [ "$DETECTED_SHELL" = "fish" ]; then
    echo "  source $SHELL_RC"
else
    echo "  source $SHELL_RC"
fi

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
    echo -e "Run: ${CYAN}source $SHELL_RC${NC}"
    echo ""
fi
