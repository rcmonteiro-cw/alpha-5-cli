#!/bin/bash

# Alpha-5 CLI Tool
# Repo-agnostic feature management using git worktrees

set -e

VERSION="3.1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Valid prefixes for feature names
VALID_PREFIXES=("feat" "fix" "chore" "refactor" "docs" "test" "ci" "perf")

# ─── Repo Detection ───────────────────────────────────────────────────────────

get_repo_root() {
    # Use --git-common-dir to always resolve to the main repo,
    # even when running from inside a worktree
    local git_common_dir
    git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"

    if [ "$git_common_dir" = ".git" ]; then
        # We're in the main repo
        git rev-parse --show-toplevel 2>/dev/null
    else
        # We're in a worktree — git-common-dir is e.g. /path/to/main-repo/.git
        # Strip the trailing /.git to get the repo root
        dirname "$git_common_dir"
    fi
}

get_repo_name() {
    basename "$(get_repo_root)"
}

get_features_path() {
    local repo_root
    repo_root="$(get_repo_root)"
    echo "$(dirname "$repo_root")/$(basename "$repo_root")-features"
}

require_repo() {
    if ! git rev-parse --show-toplevel &>/dev/null; then
        echo -e "${RED}ERROR: Not inside a git repository${NC}"
        echo ""
        echo "Navigate to a git repository and try again."
        exit 1
    fi
}

# ─── Name Parsing ─────────────────────────────────────────────────────────────

# Parse "feat:my-feature" into prefix="feat" and name="my-feature"
# Branch becomes "feat/my-feature", directory becomes "feat:my-feature"
parse_feature_input() {
    local input="$1"

    if [[ "$input" != *:* ]]; then
        echo -e "${RED}ERROR: Feature name must include a prefix${NC}"
        echo ""
        echo "Format: a5 add <prefix>:<name>"
        echo ""
        echo "Valid prefixes: ${VALID_PREFIXES[*]}"
        echo ""
        echo "Examples:"
        echo "  a5 add feat:new-button"
        echo "  a5 add fix:login-bug"
        echo "  a5 add chore:update-deps"
        exit 1
    fi

    PARSED_PREFIX="${input%%:*}"
    PARSED_NAME="${input#*:}"

    if [ -z "$PARSED_NAME" ]; then
        echo -e "${RED}ERROR: Feature name after prefix cannot be empty${NC}"
        echo ""
        echo "Example: a5 add ${PARSED_PREFIX}:my-feature"
        exit 1
    fi

    # Validate prefix
    local valid=false
    for p in "${VALID_PREFIXES[@]}"; do
        if [ "$p" = "$PARSED_PREFIX" ]; then
            valid=true
            break
        fi
    done

    if [ "$valid" = false ]; then
        echo -e "${RED}ERROR: Invalid prefix '${PARSED_PREFIX}'${NC}"
        echo ""
        echo "Valid prefixes: ${VALID_PREFIXES[*]}"
        exit 1
    fi
}

# Get the branch name from a feature input (e.g., "feat:my-feature" -> "feat/my-feature")
get_branch_name() {
    local input="$1"
    local prefix="${input%%:*}"
    local name="${input#*:}"
    echo "${prefix}/${name}"
}

# ─── File Syncing ─────────────────────────────────────────────────────────────

sync_files_to_worktree() {
    local source_root="$1"
    local target_root="$2"
    local synced=0

    echo ""
    echo "Syncing files..."

    # Copy all *.env files from repo root
    for env_file in "$source_root"/*.env; do
        [ -f "$env_file" ] || continue
        local filename
        filename="$(basename "$env_file")"
        if cp "$env_file" "$target_root/$filename"; then
            echo -e "${GREEN}  Synced: $filename${NC}"
            synced=$((synced + 1))
        else
            echo -e "${RED}  Failed: $filename${NC}"
        fi
    done

    # Copy ~/.claude/settings.local.json
    local claude_settings="$HOME/.claude/settings.local.json"
    if [ -f "$claude_settings" ]; then
        mkdir -p "$target_root/.claude"
        if cp "$claude_settings" "$target_root/.claude/settings.local.json"; then
            echo -e "${GREEN}  Synced: .claude/settings.local.json${NC}"
            synced=$((synced + 1))
        else
            echo -e "${RED}  Failed: .claude/settings.local.json${NC}"
        fi
    fi

    if [ "$synced" -eq 0 ]; then
        echo -e "${YELLOW}  No files to sync${NC}"
    fi
}

# Check sync status for a worktree (used by list)
check_sync_status() {
    local source_root="$1"
    local target_root="$2"
    # Returns: "ok", "outdated", or "missing"

    local has_issues=false
    local has_missing=false

    # Check *.env files
    for env_file in "$source_root"/*.env; do
        [ -f "$env_file" ] || continue
        local filename
        filename="$(basename "$env_file")"
        if [ ! -f "$target_root/$filename" ]; then
            has_missing=true
        elif ! cmp -s "$env_file" "$target_root/$filename"; then
            has_issues=true
        fi
    done

    # Check ~/.claude/settings.local.json
    local claude_settings="$HOME/.claude/settings.local.json"
    if [ -f "$claude_settings" ]; then
        if [ ! -f "$target_root/.claude/settings.local.json" ]; then
            has_missing=true
        elif ! cmp -s "$claude_settings" "$target_root/.claude/settings.local.json"; then
            has_issues=true
        fi
    fi

    if [ "$has_missing" = true ]; then
        echo "missing"
    elif [ "$has_issues" = true ]; then
        echo "outdated"
    else
        echo "ok"
    fi
}

# ─── Help & Version ──────────────────────────────────────────────────────────

show_help() {
    local in_repo=false
    local repo_info=""

    if git rev-parse --show-toplevel &>/dev/null; then
        in_repo=true
        repo_info="$(get_repo_name) ($(get_repo_root))"
    fi

    echo ""
    echo "Alpha-5 CLI - Feature Management with Git Worktrees"
    echo ""
    echo "Usage:"
    echo "  a5 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  help                          Show this help message"
    echo "  add <prefix>:<name>          Create a new feature worktree"
    echo "  list                          List all feature worktrees"
    echo "  update <prefix>:<name>       Sync config files to a feature"
    echo "  update-all                    Sync config files to all features"
    echo "  delete <prefix>:<name>       Remove a feature worktree and branch"
    echo "  status <prefix>:<name>       Show git status of a feature"
    echo "  path <prefix>:<name>         Print absolute path to a feature"
    echo "  open <prefix>:<name>         Navigate to a feature worktree"
    echo "  version                       Show version information"
    echo ""
    echo "Valid prefixes: ${VALID_PREFIXES[*]}"
    echo ""
    echo "Examples:"
    echo "  a5 add feat:new-button"
    echo "  a5 add fix:login-bug"
    echo "  a5 add chore:update-deps"
    echo "  a5 list"
    echo "  a5 open feat:new-button"
    echo "  a5 delete fix:login-bug"
    echo ""
    echo "Auto-synced files:"
    echo "  - All *.env files from the repo root"
    echo "  - ~/.claude/settings.local.json"
    echo ""

    if [ "$in_repo" = true ]; then
        echo "Current repo:      $repo_info"
        echo "Features path:     $(get_features_path)"
    else
        echo -e "${YELLOW}Not inside a git repository. Navigate to one to use alpha-5.${NC}"
    fi
    echo ""
}

show_version() {
    echo "Alpha-5 CLI version $VERSION"
}

# ─── Add (Create Feature Worktree) ───────────────────────────────────────────

create_feature() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: a5 add <prefix>:<name>"
        echo "Example: a5 add feat:new-button"
        exit 1
    fi

    parse_feature_input "$input"
    require_repo

    local repo_root
    repo_root="$(get_repo_root)"
    local features_path
    features_path="$(get_features_path)"
    local branch_name
    branch_name="$(get_branch_name "$input")"
    local worktree_path="$features_path/$input"

    if [ -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' already exists at $worktree_path${NC}"
        exit 1
    fi

    mkdir -p "$features_path"

    echo ""
    echo "Setting up feature: $input"
    echo ""

    # Fetch latest and detect the default remote branch
    echo "Fetching latest from remote..."
    git -C "$repo_root" fetch origin 2>&1

    local default_branch
    default_branch="$(git -C "$repo_root" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
    if [ -z "$default_branch" ]; then
        default_branch="main"
    fi

    echo "Branching from origin/$default_branch"
    echo ""

    echo "Creating worktree..."
    if git -C "$repo_root" worktree add "$worktree_path" -b "$branch_name" "origin/$default_branch" 2>&1; then
        echo -e "${GREEN}Created worktree at $worktree_path${NC}"
        echo -e "${GREEN}Branch: $branch_name${NC}"
    else
        echo -e "${RED}ERROR: Failed to create worktree${NC}"
        echo ""
        echo "The branch '$branch_name' may already exist. Check with: git branch -a"
        exit 1
    fi

    sync_files_to_worktree "$repo_root" "$worktree_path"

    echo ""
    echo -e "${GREEN}Feature '$input' is ready!${NC}"
    echo "Path: $worktree_path"
    echo ""
    echo "Navigate with: a5 open $input"
    echo ""

    echo "__A5_AUTO_CD__:$worktree_path"
}

# ─── List Features ────────────────────────────────────────────────────────────

list_features() {
    require_repo

    local repo_root
    repo_root="$(get_repo_root)"
    local repo_name
    repo_name="$(get_repo_name)"
    local features_path
    features_path="$(get_features_path)"

    echo ""
    echo -e "${CYAN}Features for: $repo_name${NC}"
    echo -e "${CYAN}Worktrees in: $features_path${NC}"
    echo ""

    if [ ! -d "$features_path" ]; then
        echo -e "${YELLOW}No features yet.${NC}"
        echo ""
        echo "Create one with: a5 add <prefix>:<name>"
        echo ""
        return 0
    fi

    local count=0
    local has_features=false

    for worktree_dir in "$features_path"/*/; do
        [ -d "$worktree_dir" ] || continue
        has_features=true
        count=$((count + 1))

        local feature_name
        feature_name="$(basename "$worktree_dir")"

        if [ ! -f "$worktree_dir/.git" ]; then
            echo -e "${YELLOW}? $feature_name (not a worktree)${NC}"
            continue
        fi

        local branch
        branch="$(cd "$worktree_dir" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"

        local status
        status="$(check_sync_status "$repo_root" "$worktree_dir")"

        case "$status" in
            missing)
                echo -e "${YELLOW}!${NC} $feature_name ${YELLOW}(missing config files)${NC}  [$branch]"
                ;;
            outdated)
                echo -e "${YELLOW}~${NC} $feature_name ${YELLOW}(outdated - run update)${NC}  [$branch]"
                ;;
            *)
                echo -e "${GREEN}*${NC} $feature_name  [$branch]"
                ;;
        esac
    done

    if [ "$has_features" = false ]; then
        echo -e "${YELLOW}No features found.${NC}"
        echo ""
        echo "Create one with: a5 add <prefix>:<name>"
    else
        echo ""
        echo -e "${CYAN}Total: $count feature(s)${NC}"
    fi
    echo ""
}

# ─── Update Feature ──────────────────────────────────────────────────────────

update_feature() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: a5 update <prefix>:<name>"
        exit 1
    fi

    require_repo

    local repo_root
    repo_root="$(get_repo_root)"
    local features_path
    features_path="$(get_features_path)"
    local worktree_path="$features_path/$input"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' does not exist${NC}"
        echo ""
        echo "Run 'a5 list' to see all features."
        exit 1
    fi

    echo ""
    echo "Updating feature: $input"

    sync_files_to_worktree "$repo_root" "$worktree_path"

    echo ""
    echo -e "${GREEN}Feature '$input' updated.${NC}"
    echo ""
}

# ─── Update All Features ─────────────────────────────────────────────────────

update_all_features() {
    require_repo

    local repo_root
    repo_root="$(get_repo_root)"
    local features_path
    features_path="$(get_features_path)"

    echo ""
    echo -e "${CYAN}Updating all features...${NC}"
    echo ""

    if [ ! -d "$features_path" ]; then
        echo -e "${YELLOW}No features directory found.${NC}"
        echo ""
        echo "Create a feature first with: a5 add <prefix>:<name>"
        return 0
    fi

    local total=0
    local updated=0
    local skipped=0

    for worktree_dir in "$features_path"/*/; do
        [ -d "$worktree_dir" ] || continue
        total=$((total + 1))

        local feature_name
        feature_name="$(basename "$worktree_dir")"

        echo -e "${CYAN}Processing: $feature_name${NC}"

        if [ ! -f "$worktree_dir/.git" ]; then
            echo -e "${YELLOW}  Skipped (not a worktree)${NC}"
            skipped=$((skipped + 1))
            echo ""
            continue
        fi

        sync_files_to_worktree "$repo_root" "$worktree_dir"
        updated=$((updated + 1))
        echo ""
    done

    echo "---"
    echo -e "${CYAN}Update Summary${NC}"
    echo -e "${CYAN}Total: $total  Updated: $updated  Skipped: $skipped${NC}"
    echo ""
}

# ─── Delete Feature ──────────────────────────────────────────────────────────

delete_feature() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: a5 delete <prefix>:<name>"
        exit 1
    fi

    require_repo

    local repo_root
    repo_root="$(get_repo_root)"
    local features_path
    features_path="$(get_features_path)"
    local worktree_path="$features_path/$input"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' does not exist${NC}"
        echo ""
        echo "Run 'a5 list' to see all features."
        exit 1
    fi

    # Get the branch from the worktree itself
    local branch_name
    branch_name="$(cd "$worktree_path" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

    echo ""
    echo -e "${YELLOW}WARNING: You are about to delete:${NC}"
    echo ""
    echo -e "${CYAN}Feature:${NC}  $input"
    echo -e "${CYAN}Path:${NC}     $worktree_path"
    if [ -n "$branch_name" ]; then
        echo -e "${CYAN}Branch:${NC}   $branch_name"
    fi

    if command -v du &>/dev/null; then
        local size
        size=$(du -sh "$worktree_path" 2>/dev/null | cut -f1)
        echo -e "${CYAN}Size:${NC}     $size"
    fi

    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""

    read -p "Delete '$input'? (yes/no): " confirmation

    case "$confirmation" in
        yes|YES|Yes)
            echo ""
            echo "Removing worktree..."

            if git worktree remove "$worktree_path" --force 2>&1; then
                echo -e "${GREEN}Worktree removed.${NC}"
            else
                rm -rf "$worktree_path"
                git worktree prune
                echo -e "${GREEN}Worktree removed (manual cleanup).${NC}"
            fi

            if [ -n "$branch_name" ]; then
                if git branch -d "$branch_name" 2>/dev/null; then
                    echo -e "${GREEN}Branch '$branch_name' deleted.${NC}"
                elif git branch -D "$branch_name" 2>/dev/null; then
                    echo -e "${YELLOW}Branch '$branch_name' force-deleted (had unmerged changes).${NC}"
                else
                    echo -e "${YELLOW}Branch '$branch_name' not found or already deleted.${NC}"
                fi
            fi

            echo ""
            echo -e "${GREEN}Feature '$input' deleted.${NC}"
            echo ""
            ;;
        *)
            echo ""
            echo "Cancelled. Feature '$input' was not deleted."
            echo ""
            ;;
    esac
}

# ─── Status ───────────────────────────────────────────────────────────────────

show_status() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: a5 status <prefix>:<name>"
        exit 1
    fi

    require_repo

    local features_path
    features_path="$(get_features_path)"
    local worktree_path="$features_path/$input"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' does not exist${NC}"
        echo ""
        echo "Run 'a5 list' to see all features."
        exit 1
    fi

    echo ""
    echo -e "${CYAN}Status for: $input${NC}"
    echo -e "${CYAN}Path: $worktree_path${NC}"
    echo ""

    (cd "$worktree_path" && git status)
}

# ─── Path ─────────────────────────────────────────────────────────────────────

print_path() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}" >&2
        echo "" >&2
        echo "Usage: a5 path <prefix>:<name>" >&2
        exit 1
    fi

    require_repo

    local features_path
    features_path="$(get_features_path)"
    local worktree_path="$features_path/$input"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' does not exist${NC}" >&2
        echo "" >&2
        echo "Run 'a5 list' to see all features." >&2
        exit 1
    fi

    echo "$(cd "$worktree_path" && pwd)"
}

# ─── Open ─────────────────────────────────────────────────────────────────────

open_feature() {
    local input="$1"

    if [ -z "$input" ]; then
        echo -e "${RED}ERROR: Feature name is required${NC}" >&2
        echo "" >&2
        echo "Usage: a5 open <prefix>:<name>" >&2
        exit 1
    fi

    require_repo

    local features_path
    features_path="$(get_features_path)"
    local worktree_path="$features_path/$input"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}ERROR: Feature '$input' does not exist${NC}" >&2
        echo "" >&2
        echo "Run 'a5 list' to see all features." >&2
        exit 1
    fi

    echo "$(cd "$worktree_path" && pwd)"
}

# ─── Main Command Router ─────────────────────────────────────────────────────

main() {
    local command="$1"

    if [ -z "$command" ]; then
        show_help
        exit 0
    fi

    case "$command" in
        help|--help|-h)
            show_help
            ;;
        version|--version|-v)
            show_version
            ;;
        add|create)
            shift
            create_feature "$@"
            ;;
        list|ls)
            list_features
            ;;
        update|sync)
            shift
            update_feature "$@"
            ;;
        update-all)
            update_all_features
            ;;
        delete|remove|rm)
            shift
            delete_feature "$@"
            ;;
        status|st)
            shift
            show_status "$@"
            ;;
        path)
            shift
            print_path "$@"
            ;;
        open)
            shift
            open_feature "$@"
            ;;
        *)
            echo -e "${RED}ERROR: Unknown command '$command'${NC}"
            echo ""
            echo "Run 'a5 help' for usage information."
            exit 1
            ;;
    esac
}

main "$@"
