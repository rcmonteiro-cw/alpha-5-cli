#!/bin/bash

# Alpha-5 CLI Tool
# Main command-line interface for feature management

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup_feature.sh"
UPDATE_SCRIPT="$SCRIPT_DIR/update_feature.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"
    
    echo ""
    echo "🚀 Alpha-5 CLI - Feature Management Tool"
    echo ""
    echo "Usage:"
    echo "  alpha-5 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  help                    Show this help message"
    echo "  add <feature-name>      Create a new feature with the specified name"
    echo "  list                    List all existing features"
    echo "  update <feature-name>   Update an existing feature config files"
    echo "  update-all              Update config files for all features"
    echo "  delete <feature-name>   Delete a feature (with confirmation)"
    echo "  status <feature-name>   Show git status of a feature"
    echo "  path <feature-name>     Print the absolute path to a feature"
    echo "  open <feature-name>     Print path to feature repository (use with cd)"
    echo "  version                 Show version information"
    echo ""
    echo "Examples:"
    echo "  alpha-5 help"
    echo "  alpha-5 add my-awesome-feature"
    echo "  alpha-5 list"
    echo "  alpha-5 update payment-processing"
    echo "  alpha-5 update-all"
    echo "  alpha-5 status payment-processing"
    echo "  alpha-5 path payment-processing"
    echo "  alpha-5 open payment-processing"
    echo "  alpha-5 delete old-feature"
    echo ""
    echo "Configuration:"
    echo "  Features path: $features_path"
    echo ""
    echo "Description:"
    echo "  - 'add' creates a new feature directory with config files from infinite-lending"
    echo "  - 'list' shows all features and their sync status"
    echo "  - 'update' syncs an existing feature with latest config files"
    echo "  - 'update-all' syncs all features with latest config files"
    echo "  - 'delete' removes a feature after confirmation"
    echo "  - 'status' shows git status of a feature's repository"
    echo "  - 'path' prints the absolute path to a feature"
    echo "  - 'open' prints path to feature's repository for navigation"
    echo ""
}

# Function to show version
show_version() {
    echo "Alpha-5 CLI version 2.3.0"
}

# Function to create a feature
create_feature() {
    local feature_name="$1"
    
    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: alpha-5 add <feature-name>"
        echo ""
        echo "Run 'alpha-5 help' for more information."
        exit 1
    fi
    
    # Check if setup script exists
    if [ ! -f "$SETUP_SCRIPT" ]; then
        echo -e "${RED}❌ ERROR: Setup script not found at $SETUP_SCRIPT${NC}"
        exit 1
    fi
    
    # Execute the setup script
    bash "$SETUP_SCRIPT" "$feature_name"
}

# Function to list all features
list_features() {
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"
    local source_repo="$HOME/projects/repos/infinite-lending"

    echo ""
    echo -e "${CYAN}📁 Features in: $features_path${NC}"
    echo ""

    # Check if features directory exists
    if [ ! -d "$features_path" ]; then
        echo -e "${YELLOW}⚠️  Features directory does not exist yet${NC}"
        echo ""
        echo "Create your first feature with: alpha-5 add <feature-name>"
        echo ""
        return 0
    fi

    # Check if source repository exists
    local source_exists=true
    if [ ! -d "$source_repo" ]; then
        source_exists=false
    fi

    # Count features
    local count=0
    local has_features=false

    # List all directories in features path
    for feature_dir in "$features_path"/*/ ; do
        if [ -d "$feature_dir" ]; then
            has_features=true
            count=$((count + 1))
            local feature_name=$(basename "$feature_dir")

            # Check if infinite-lending directory exists
            local repo_dir="$feature_dir/infinite-lending"
            if [ ! -d "$repo_dir" ]; then
                echo -e "${YELLOW}⚠${NC} $feature_name ${YELLOW}(missing infinite-lending directory)${NC}"
                continue
            fi

            # Check if required files exist
            local dev_env_exists=false
            local settings_exists=false
            local dev_env_updated=true
            local settings_updated=true

            if [ -f "$repo_dir/development.env" ]; then
                dev_env_exists=true
            fi

            if [ -f "$repo_dir/.claude/settings.local.json" ]; then
                settings_exists=true
            fi

            # If source exists, check if files are up to date
            if [ "$source_exists" = true ]; then
                if [ "$dev_env_exists" = true ] && [ -f "$source_repo/development.env" ]; then
                    if ! cmp -s "$repo_dir/development.env" "$source_repo/development.env"; then
                        dev_env_updated=false
                    fi
                fi

                if [ "$settings_exists" = true ] && [ -f "$source_repo/.claude/settings.local.json" ]; then
                    if ! cmp -s "$repo_dir/.claude/settings.local.json" "$source_repo/.claude/settings.local.json"; then
                        settings_updated=false
                    fi
                fi
            fi

            # Display status based on file state
            if [ "$dev_env_exists" = false ] || [ "$settings_exists" = false ]; then
                echo -e "${YELLOW}⚠${NC} $feature_name ${YELLOW}(missing config files)${NC}"
            elif [ "$source_exists" = true ] && { [ "$dev_env_updated" = false ] || [ "$settings_updated" = false ]; }; then
                echo -e "${YELLOW}🔄${NC} $feature_name ${YELLOW}(outdated - run update)${NC}"
            else
                echo -e "${GREEN}✓${NC} $feature_name"
            fi
        fi
    done

    if [ "$has_features" = false ]; then
        echo -e "${YELLOW}No features found${NC}"
        echo ""
        echo "Create your first feature with: alpha-5 add <feature-name>"
    else
        echo ""
        echo -e "${CYAN}Total: $count feature(s)${NC}"
        if [ "$source_exists" = false ]; then
            echo ""
            echo -e "${YELLOW}⚠️  Source repository not found at $source_repo${NC}"
            echo -e "${YELLOW}   Cannot check if features are up to date${NC}"
        fi
    fi
    echo ""
}

# Function to update a feature
update_feature() {
    local feature_name="$1"
    
    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: alpha-5 update <feature-name>"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi
    
    # Check if update script exists
    if [ ! -f "$UPDATE_SCRIPT" ]; then
        echo -e "${RED}❌ ERROR: Update script not found at $UPDATE_SCRIPT${NC}"
        exit 1
    fi
    
    # Execute the update script
    bash "$UPDATE_SCRIPT" "$feature_name"
}

# Function to delete a feature
delete_feature() {
    local feature_name="$1"
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"
    
    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: alpha-5 delete <feature-name>"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi
    
    local feature_dir="$features_path/$feature_name"
    
    # Check if feature exists
    if [ ! -d "$feature_dir" ]; then
        echo -e "${RED}❌ ERROR: Feature '$feature_name' does not exist${NC}"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi
    
    # Show feature details
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: You are about to delete the following feature:${NC}"
    echo ""
    echo -e "${CYAN}Feature name:${NC} $feature_name"
    echo -e "${CYAN}Location:${NC} $feature_dir"
    
    # Check size
    if command -v du &> /dev/null; then
        local size=$(du -sh "$feature_dir" 2>/dev/null | cut -f1)
        echo -e "${CYAN}Size:${NC} $size"
    fi
    
    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    
    # Confirmation prompt
    read -p "Are you sure you want to delete '$feature_name'? (yes/no): " confirmation
    
    case "$confirmation" in
        yes|YES|Yes)
            echo ""
            echo -e "${YELLOW}Deleting feature '$feature_name'...${NC}"
            
            if rm -rf "$feature_dir"; then
                echo -e "${GREEN}✅ SUCCESS: Feature '$feature_name' has been deleted${NC}"
                echo ""
            else
                echo -e "${RED}❌ FAIL: Failed to delete feature '$feature_name'${NC}"
                echo ""
                exit 1
            fi
            ;;
        *)
            echo ""
            echo -e "${CYAN}ℹ️  Deletion cancelled. Feature '$feature_name' was not deleted.${NC}"
            echo ""
            exit 0
            ;;
    esac
}

# Function to show git status of a feature
show_status() {
    local feature_name="$1"
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"

    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: alpha-5 status <feature-name>"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi

    local feature_dir="$features_path/$feature_name"
    local repo_dir="$feature_dir/infinite-lending"

    # Check if feature exists
    if [ ! -d "$feature_dir" ]; then
        echo -e "${RED}❌ ERROR: Feature '$feature_name' does not exist${NC}"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi

    # Check if repository exists
    if [ ! -d "$repo_dir" ]; then
        echo -e "${RED}❌ ERROR: infinite-lending directory not found in feature '$feature_name'${NC}"
        exit 1
    fi

    echo ""
    echo -e "${CYAN}📊 Git Status for: $feature_name${NC}"
    echo -e "${CYAN}Repository: $repo_dir${NC}"
    echo ""

    # Run git status in the repository
    (cd "$repo_dir" && git status)
}

# Function to print feature path
print_path() {
    local feature_name="$1"
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"

    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}"
        echo ""
        echo "Usage: alpha-5 path <feature-name>"
        echo ""
        echo "Run 'alpha-5 list' to see all features."
        exit 1
    fi

    local feature_dir="$features_path/$feature_name"

    # Check if feature exists
    if [ ! -d "$feature_dir" ]; then
        echo -e "${RED}❌ ERROR: Feature '$feature_name' does not exist${NC}" >&2
        echo "" >&2
        echo "Run 'alpha-5 list' to see all features." >&2
        exit 1
    fi

    # Print the absolute path
    echo "$(cd "$feature_dir" && pwd)"
}

# Function to open a feature (print path to infinite-lending repository)
open_feature() {
    local feature_name="$1"
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"

    if [ -z "$feature_name" ]; then
        echo -e "${RED}❌ ERROR: Feature name is required${NC}" >&2
        echo "" >&2
        echo "Usage: alpha-5 open <feature-name>" >&2
        echo "" >&2
        echo "Run 'alpha-5 list' to see all features." >&2
        exit 1
    fi

    local feature_dir="$features_path/$feature_name"
    local repo_dir="$feature_dir/infinite-lending"

    # Check if feature exists
    if [ ! -d "$feature_dir" ]; then
        echo -e "${RED}❌ ERROR: Feature '$feature_name' does not exist${NC}" >&2
        echo "" >&2
        echo "Run 'alpha-5 list' to see all features." >&2
        exit 1
    fi

    # Check if repository exists
    if [ ! -d "$repo_dir" ]; then
        echo -e "${RED}❌ ERROR: infinite-lending directory not found in feature '$feature_name'${NC}" >&2
        exit 1
    fi

    # Print the absolute path to infinite-lending repository
    echo "$(cd "$repo_dir" && pwd)"
}

# Function to update all features
update_all_features() {
    local features_path="${ALPHA5_FEATURES_PATH:-./features}"

    echo ""
    echo -e "${CYAN}🔄 Updating all features...${NC}"
    echo ""

    # Check if features directory exists
    if [ ! -d "$features_path" ]; then
        echo -e "${YELLOW}⚠️  Features directory does not exist yet${NC}"
        echo ""
        echo "Create your first feature with: alpha-5 add <feature-name>"
        exit 0
    fi

    # Source directory for config files
    local source_repo="$HOME/projects/repos/infinite-lending"

    # Verify source repository exists
    if [ ! -d "$source_repo" ]; then
        echo -e "${RED}❌ FAIL: Source repository not found at $source_repo${NC}"
        echo "Please ensure the repository exists at this location"
        exit 1
    fi

    # Count features
    local total=0
    local updated=0
    local failed=0
    local skipped=0

    # Iterate through all features
    for feature_dir in "$features_path"/*/ ; do
        if [ -d "$feature_dir" ]; then
            total=$((total + 1))
            local feature_name=$(basename "$feature_dir")
            local repo_dir="$feature_dir/infinite-lending"

            echo -e "${CYAN}Processing: $feature_name${NC}"

            # Check if infinite-lending directory exists
            if [ ! -d "$repo_dir" ]; then
                echo -e "${YELLOW}  ⚠ Skipped (missing infinite-lending directory)${NC}"
                skipped=$((skipped + 1))
                echo ""
                continue
            fi

            # Update development.env
            local env_updated=false
            local settings_updated=false

            if [ -f "$source_repo/development.env" ]; then
                if cp "$source_repo/development.env" "$repo_dir/development.env" 2>/dev/null; then
                    env_updated=true
                fi
            fi

            # Update .claude/settings.local.json
            mkdir -p "$repo_dir/.claude"
            if [ -f "$source_repo/.claude/settings.local.json" ]; then
                if cp "$source_repo/.claude/settings.local.json" "$repo_dir/.claude/settings.local.json" 2>/dev/null; then
                    settings_updated=true
                fi
            fi

            if [ "$env_updated" = true ] && [ "$settings_updated" = true ]; then
                echo -e "${GREEN}  ✓ Updated successfully${NC}"
                updated=$((updated + 1))
            elif [ "$env_updated" = true ] || [ "$settings_updated" = true ]; then
                echo -e "${YELLOW}  ⚠ Partially updated${NC}"
                updated=$((updated + 1))
            else
                echo -e "${RED}  ✗ Failed to update${NC}"
                failed=$((failed + 1))
            fi
            echo ""
        fi
    done

    # Summary
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Update Summary${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Total features:${NC} $total"
    echo -e "${GREEN}Updated:${NC} $updated"
    if [ $skipped -gt 0 ]; then
        echo -e "${YELLOW}Skipped:${NC} $skipped"
    fi
    if [ $failed -gt 0 ]; then
        echo -e "${RED}Failed:${NC} $failed"
    fi
    echo ""

    if [ $updated -gt 0 ]; then
        echo -e "${GREEN}🎉 Update completed!${NC}"
    else
        echo -e "${YELLOW}⚠️  No features were updated${NC}"
    fi
    echo ""
}

# Main command router
main() {
    local command="$1"
    
    # If no command provided, show help
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
        update-all)
            update_all_features
            ;;
        open)
            shift
            open_feature "$@"
            ;;
        *)
            echo -e "${RED}❌ ERROR: Unknown command '$command'${NC}"
            echo ""
            echo "Run 'alpha-5 help' for usage information."
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
