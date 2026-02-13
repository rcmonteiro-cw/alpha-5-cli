#!/bin/bash

set -e

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "❌ ERROR: Feature name is required"
    echo "Usage: $0 <feature_name>"
    exit 1
fi

# Use environment variable or default to ./features
FEATURES_BASE="${ALPHA5_FEATURES_PATH:-./features}"

echo "🔄 Updating feature: $FEATURE_NAME"

# Check if feature exists
FEATURE_DIR="$FEATURES_BASE/$FEATURE_NAME"
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ ERROR: Feature '$FEATURE_NAME' does not exist"
    echo "Run 'alpha-5 list' to see existing features"
    echo "Or use 'alpha-5 add $FEATURE_NAME' to create it"
    exit 1
fi

# Check if infinite-lending directory exists in feature
CLONED_REPO="$FEATURE_DIR/infinite-lending"
if [ ! -d "$CLONED_REPO" ]; then
    echo "❌ ERROR: infinite-lending directory not found in feature '$FEATURE_NAME'"
    echo "Expected: $CLONED_REPO"
    exit 1
fi

# Source directory for infinite-lending repo
SOURCE_REPO="$HOME/projects/repos/infinite-lending"

# Verify source repository exists
if [ ! -d "$SOURCE_REPO" ]; then
    echo "❌ FAIL: Source repository not found at $SOURCE_REPO"
    echo "Please ensure the repository exists at this location"
    exit 1
fi

echo "📋 Updating configuration files..."

# Update development.env
if [ -f "$SOURCE_REPO/development.env" ]; then
    if cp "$SOURCE_REPO/development.env" "$CLONED_REPO/development.env"; then
        echo "✅ SUCCESS: Updated development.env"
    else
        echo "❌ FAIL: Failed to update development.env"
        exit 1
    fi
else
    echo "❌ FAIL: development.env not found in source repository"
    exit 1
fi

# Create .claude directory if it doesn't exist and update settings.local.json
mkdir -p "$CLONED_REPO/.claude"
if [ -f "$SOURCE_REPO/.claude/settings.local.json" ]; then
    if cp "$SOURCE_REPO/.claude/settings.local.json" "$CLONED_REPO/.claude/settings.local.json"; then
        echo "✅ SUCCESS: Updated .claude/settings.local.json"
    else
        echo "❌ FAIL: Failed to update .claude/settings.local.json"
        exit 1
    fi
else
    echo "❌ FAIL: .claude/settings.local.json not found in source repository"
    exit 1
fi

echo ""
echo "📋 Update summary:"
echo "  ✓ development.env (updated)"
echo "  ✓ .claude/settings.local.json (updated)"

echo ""
echo "🎉 Feature update completed successfully!"
echo "📍 Feature location: $FEATURE_DIR"
echo "📍 Repository location: $CLONED_REPO"
