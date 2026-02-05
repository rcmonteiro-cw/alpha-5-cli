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

# Check if agents directory exists
AGENTS_DEST="$FEATURE_DIR/agents"
if [ ! -d "$AGENTS_DEST" ]; then
    echo "❌ ERROR: Agents directory not found in feature '$FEATURE_NAME'"
    echo "Expected: $AGENTS_DEST"
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

AGENTS_SRC="$TEMP_REPO/agents"

if [ ! -d "$AGENTS_SRC" ]; then
    echo "❌ FAIL: agents folder not found in repository"
    rm -rf "$TEMP_REPO"
    exit 1
fi

echo "🔄 Updating agents contents (with exclusions)..."

# Create a function to copy with exclusions
copy_with_exclusions() {
    local src="$1"
    local dest="$2"
    
    # Use rsync if available, otherwise use find with cp
    if command -v rsync &> /dev/null; then
        rsync -av \
            --exclude='spec/' \
            --exclude='IMPLEMENTATION_PLAN.md' \
            "$src/" "$dest/"
    else
        # Fallback to manual copying with find
        echo "⚠️  rsync not found, using manual copy (slower)"
        
        # Copy all files except excluded ones
        find "$src" -type f | while read -r file; do
            relative_path="${file#$src/}"
            
            # Skip if in spec directory
            if [[ "$relative_path" == spec/* ]]; then
                continue
            fi
            
            # Skip IMPLEMENTATION_PLAN.md
            if [[ "$(basename "$file")" == "IMPLEMENTATION_PLAN.md" ]]; then
                continue
            fi
            
            # Copy the file
            dest_file="$dest/$relative_path"
            dest_dir=$(dirname "$dest_file")
            mkdir -p "$dest_dir"
            cp "$file" "$dest_file"
        done
    fi
}

# Perform the update
if copy_with_exclusions "$AGENTS_SRC" "$AGENTS_DEST"; then
    echo "✅ SUCCESS: Updated agents contents in $AGENTS_DEST"
    echo ""
    echo "📋 Update summary:"
    echo "  ✗ spec/ directory (not updated - preserved)"
    echo "  ✗ IMPLEMENTATION_PLAN.md (not updated - preserved)"
    echo "  ✓ All other files including *.md and loop.sh (updated)"
else
    echo "❌ FAIL: Failed to update agents contents"
    rm -rf "$TEMP_REPO"
    exit 1
fi

echo ""
echo "🧹 Cleaning up temporary files..."
if rm -rf "$TEMP_REPO"; then
    echo "✅ SUCCESS: Cleaned up temporary repository"
else
    echo "⚠️  WARNING: Failed to clean up temporary repository at $TEMP_REPO"
fi

echo ""
echo "🎉 Feature update completed successfully!"
echo "📍 Feature location: $FEATURE_DIR"
