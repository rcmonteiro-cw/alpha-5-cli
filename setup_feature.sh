#!/bin/bash

set -e

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "❌ ERROR: Feature name is required"
    echo "Usage: $0 <feature_name>"
    exit 1
fi

echo "🚀 Setting up feature: $FEATURE_NAME"

# Use environment variable or default to ./features
FEATURES_BASE="${ALPHA5_FEATURES_PATH:-./features}"

echo "📁 Creating feature directory..."
FEATURE_DIR="$FEATURES_BASE/$FEATURE_NAME"
if mkdir -p "$FEATURE_DIR"; then
    echo "✅ SUCCESS: Created directory $FEATURE_DIR"
else
    echo "❌ FAIL: Failed to create directory $FEATURE_DIR"
    exit 1
fi

echo "📦 Cloning infinite-lending repository into feature directory..."
CLONED_REPO="$FEATURE_DIR/infinite-lending"
if git clone https://github.com/cloudwalk/infinite-lending.git "$CLONED_REPO"; then
    echo "✅ SUCCESS: Cloned infinite-lending repository to $CLONED_REPO"
else
    echo "❌ FAIL: Failed to clone infinite-lending repository"
    exit 1
fi

echo "🔀 Creating and checking out feature branch..."
BRANCH_NAME="feat/$FEATURE_NAME"
if (cd "$CLONED_REPO" && git checkout -b "$BRANCH_NAME"); then
    echo "✅ SUCCESS: Created and checked out branch '$BRANCH_NAME'"
else
    echo "❌ FAIL: Failed to create branch '$BRANCH_NAME'"
    exit 1
fi

# Source directory for config files
SOURCE_REPO="$HOME/projects/repos/infinite-lending"

# Verify source repository exists
if [ ! -d "$SOURCE_REPO" ]; then
    echo "❌ FAIL: Source repository not found at $SOURCE_REPO"
    echo "Please ensure the repository exists at this location"
    exit 1
fi

echo "📋 Copying configuration files from local repo to cloned repo..."

# Copy development.env
if [ -f "$SOURCE_REPO/development.env" ]; then
    if cp "$SOURCE_REPO/development.env" "$CLONED_REPO/development.env"; then
        echo "✅ SUCCESS: Copied development.env"
    else
        echo "❌ FAIL: Failed to copy development.env"
        exit 1
    fi
else
    echo "❌ FAIL: development.env not found in source repository"
    exit 1
fi

# Create .claude directory and copy settings.local.json
mkdir -p "$CLONED_REPO/.claude"
if [ -f "$SOURCE_REPO/.claude/settings.local.json" ]; then
    if cp "$SOURCE_REPO/.claude/settings.local.json" "$CLONED_REPO/.claude/settings.local.json"; then
        echo "✅ SUCCESS: Copied .claude/settings.local.json"
    else
        echo "❌ FAIL: Failed to copy .claude/settings.local.json"
        exit 1
    fi
else
    echo "❌ FAIL: .claude/settings.local.json not found in source repository"
    exit 1
fi

echo "🎉 Feature setup completed successfully!"
echo "📍 Feature location: $FEATURE_DIR"
echo "📍 Repository location: $CLONED_REPO"
echo ""
echo "📂 Opening repository..."
echo ""

# Output special marker for a5 function to detect and cd
echo "__A5_AUTO_CD__:$CLONED_REPO"