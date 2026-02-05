#!/bin/bash

# Alpha-5 CLI Tool
# Main command-line interface for feature management

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup_feature.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo "  delete <feature-name>   Delete a feature (with confirmation)"
    echo "  version                 Show version information"
    echo ""
    echo "Examples:"
    echo "  alpha-5 help"
    echo "  alpha-5 add my-awesome-feature"
    echo "  alpha-5 list"
    echo "  alpha-5 delete payment-processing"
    echo ""
    echo "Configuration:"
    echo "  Features path: $features_path"
    echo ""
    echo "Description:"
    echo "  - 'add' creates a new feature directory with agents from infinite-lending"
    echo "  - 'list' shows all features in your configured path"
    echo "  - 'delete' removes a feature after confirmation"
    echo ""
}

# Function to show version
show_version() {
    echo "Alpha-5 CLI version 1.1.0"
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
    
    echo ""
    echo -e "${BLUE}📁 Features in: $features_path${NC}"
    echo ""
    
    # Check if features directory exists
    if [ ! -d "$features_path" ]; then
        echo -e "${YELLOW}⚠️  Features directory does not exist yet${NC}"
        echo ""
        echo "Create your first feature with: alpha-5 add <feature-name>"
        echo ""
        return 0
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
            
            # Check if agents folder exists
            if [ -d "$feature_dir/agents" ]; then
                echo -e "${GREEN}✓${NC} $feature_name"
            else
                echo -e "${YELLOW}⚠${NC} $feature_name ${YELLOW}(missing agents folder)${NC}"
            fi
        fi
    done
    
    if [ "$has_features" = false ]; then
        echo -e "${YELLOW}No features found${NC}"
        echo ""
        echo "Create your first feature with: alpha-5 add <feature-name>"
    else
        echo ""
        echo -e "${BLUE}Total: $count feature(s)${NC}"
    fi
    echo ""
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
    echo -e "${BLUE}Feature name:${NC} $feature_name"
    echo -e "${BLUE}Location:${NC} $feature_dir"
    
    # Check size
    if command -v du &> /dev/null; then
        local size=$(du -sh "$feature_dir" 2>/dev/null | cut -f1)
        echo -e "${BLUE}Size:${NC} $size"
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
            echo -e "${BLUE}ℹ️  Deletion cancelled. Feature '$feature_name' was not deleted.${NC}"
            echo ""
            exit 0
            ;;
    esac
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
        delete|remove|rm)
            shift
            delete_feature "$@"
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
