#!/bin/bash

# AI Resource Tracker - Release Build Script
# This script builds a distributable version of the app

set -e

echo "🚀 Building AI Resource Tracker..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="AI resource tracker"
SCHEME_NAME="AI resource tracker"
BUILD_DIR="./build"
RELEASE_DIR="./releases"
APP_NAME="AI resource tracker.app"

# Clean previous builds
echo -e "${BLUE}📦 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

# Build the app
echo -e "${BLUE}🔨 Building release version...${NC}"
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           | xcpretty || true

# Check if build succeeded
if [ ! -d "$BUILD_DIR/Build/Products/Release/$APP_NAME" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Get version from Info.plist if available
VERSION="1.0"
if [ -f "$BUILD_DIR/Build/Products/Release/$APP_NAME/Contents/Info.plist" ]; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$BUILD_DIR/Build/Products/Release/$APP_NAME/Contents/Info.plist" 2>/dev/null || echo "1.0")
fi

# Create zip
echo -e "${BLUE}📦 Creating distributable zip...${NC}"
cd "$BUILD_DIR/Build/Products/Release"
ZIP_NAME="AI-Resource-Tracker-v${VERSION}.zip"
ditto -c -k --keepParent "$APP_NAME" "../../../../$RELEASE_DIR/$ZIP_NAME"
cd - > /dev/null

# Calculate size
SIZE=$(du -h "$RELEASE_DIR/$ZIP_NAME" | cut -f1)

echo ""
echo -e "${GREEN}✅ Release build complete!${NC}"
echo ""
echo "📍 Location: $RELEASE_DIR/$ZIP_NAME"
echo "📊 Size: $SIZE"
echo "🏷️  Version: $VERSION"
echo ""
echo "Next steps:"
echo "1. Test the app: open '$BUILD_DIR/Build/Products/Release/$APP_NAME'"
echo "2. Upload to GitHub: Create a new release and attach $ZIP_NAME"
echo ""
