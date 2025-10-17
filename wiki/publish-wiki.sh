#!/bin/bash

# Script to publish wiki documentation to GitHub Wiki
# Usage: ./publish-wiki.sh

set -e

WIKI_DIR="wiki"
REPO_NAME="container-apps-store-api-microservice"
WIKI_REPO_URL="https://github.com/TeplrGuy/${REPO_NAME}.wiki.git"
TEMP_DIR="/tmp/${REPO_NAME}.wiki"

echo "🚀 Publishing Wiki Documentation to GitHub"
echo "=========================================="

# Check if wiki directory exists
if [ ! -d "$WIKI_DIR" ]; then
    echo "❌ Error: wiki directory not found!"
    exit 1
fi

# Clean up any existing temp directory
if [ -d "$TEMP_DIR" ]; then
    echo "🧹 Cleaning up existing temporary directory..."
    rm -rf "$TEMP_DIR"
fi

# Clone the wiki repository
echo "📥 Cloning wiki repository..."
if ! git clone "$WIKI_REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    echo "❌ Error: Failed to clone wiki repository."
    echo "   Make sure the wiki has been initialized on GitHub."
    echo "   Visit: https://github.com/TeplrGuy/${REPO_NAME}/wiki/_new"
    echo "   Create any page to initialize the wiki, then run this script again."
    exit 1
fi

# Copy wiki files
echo "📄 Copying wiki files..."
cp "$WIKI_DIR"/*.md "$TEMP_DIR/"

# Navigate to wiki directory
cd "$TEMP_DIR"

# Check if there are changes
if git diff --quiet && git diff --staged --quiet; then
    echo "✅ No changes to publish. Wiki is up to date!"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Add all markdown files
echo "➕ Adding files to git..."
git add *.md

# Commit changes
echo "💾 Committing changes..."
git commit -m "Update wiki documentation - $(date +'%Y-%m-%d %H:%M:%S')"

# Push to GitHub
echo "⬆️  Pushing to GitHub..."
git push origin master

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo ""
echo "✨ Wiki documentation successfully published!"
echo "🔗 View at: https://github.com/TeplrGuy/${REPO_NAME}/wiki"
echo ""
