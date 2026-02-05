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
    echo "  version                 Show version information"
    echo ""
    echo "Examples:"
    echo "  alpha-5 help"
    echo "  alpha-5 add my-awesome-feature"
    echo "  alpha-5 add payment-processing"
    echo ""
    echo "Configuration:"
    echo "  Features path: $features_path"
    echo ""
    echo "Description:"
    echo "  The 'add' command creates a new feature directory and sets up"
    echo "  the necessary structure by cloning and copying agents from the"
    echo "  infinite-lending repository."
    echo ""
}

# Function to show version
show_version() {
    echo "Alpha-5 CLI version 1.0.0"
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
