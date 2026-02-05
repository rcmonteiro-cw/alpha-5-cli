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

echo "📦 Cloning infinite-lending repository to /tmp..."
TEMP_REPO="/tmp/infinite-lending-$(date +%s)"
if git clone https://github.com/cloudwalk/infinite-lending.git "$TEMP_REPO"; then
    echo "✅ SUCCESS: Cloned infinite-lending repository to $TEMP_REPO"
else
    echo "❌ FAIL: Failed to clone infinite-lending repository"
    exit 1
fi

echo "📂 Creating agents directory..."
AGENTS_DEST="$FEATURE_DIR/agents"
if mkdir -p "$AGENTS_DEST"; then
    echo "✅ SUCCESS: Created agents directory at $AGENTS_DEST"
else
    echo "❌ FAIL: Failed to create agents directory"
    rm -rf "$TEMP_REPO"
    exit 1
fi

echo "📋 Copying agents contents..."
AGENTS_SRC="$TEMP_REPO/agents"

if [ -d "$AGENTS_SRC" ]; then
    if cp -r "$AGENTS_SRC"/* "$AGENTS_DEST"/; then
        echo "✅ SUCCESS: Copied all agents contents to $AGENTS_DEST"
    else
        echo "❌ FAIL: Failed to copy agents contents"
        rm -rf "$TEMP_REPO"
        exit 1
    fi
else
    echo "❌ FAIL: agents folder not found in repository"
    rm -rf "$TEMP_REPO"
    exit 1
fi

echo "🧹 Cleaning up temporary files..."
if rm -rf "$TEMP_REPO"; then
    echo "✅ SUCCESS: Cleaned up temporary repository"
else
    echo "⚠️  WARNING: Failed to clean up temporary repository at $TEMP_REPO"
fi

echo "🎉 Feature setup completed successfully!"
echo "📍 Feature location: $FEATURE_DIR"