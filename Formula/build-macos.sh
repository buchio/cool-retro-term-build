#!/bin/bash
set -e

# =============================================================================
# cool-retro-term macOS Build Script for Apple Silicon
# =============================================================================
#
# Build cool-retro-term on Apple Silicon (M1/M2/M3) Mac.
#
# The official release only provides Intel Mac binaries, so you need to build
# from source to run on Apple Silicon. This script makes it easy.
#
# Also works on Intel Mac.
#
# Gist: https://gist.github.com/buchio/103b0dcc2ce9553f81c6a003c729feb8
#
# =============================================================================
# QUICK START
# =============================================================================
#
#   # Install prerequisites
#   xcode-select --install
#   brew install qt@5
#
#   # Clone and build
#   git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
#   cd cool-retro-term
#   curl -O https://gist.githubusercontent.com/buchio/103b0dcc2ce9553f81c6a003c729feb8/raw/build-macos.sh
#   chmod +x build-macos.sh
#   ./build-macos.sh
#
# =============================================================================
# PATCHES APPLIED
# =============================================================================
#
# - Braille character width fix (konsole_wcwidth.cpp)
#   Fixes display issues with btop, htop, and other tools that use
#   Braille patterns (U+2800-U+28FF) for drawing graphs.
#
# =============================================================================

echo "=== cool-retro-term macOS Build Script ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check for Qt5
echo -e "${YELLOW}Checking for Qt5...${NC}"
if command -v qmake &> /dev/null; then
    QMAKE="qmake"
elif [ -f "/opt/homebrew/opt/qt@5/bin/qmake" ]; then
    QMAKE="/opt/homebrew/opt/qt@5/bin/qmake"
    export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
elif [ -f "/usr/local/opt/qt@5/bin/qmake" ]; then
    QMAKE="/usr/local/opt/qt@5/bin/qmake"
    export PATH="/usr/local/opt/qt@5/bin:$PATH"
else
    echo -e "${RED}Error: Qt5 not found. Please install it:${NC}"
    echo "  brew install qt@5"
    exit 1
fi

QT_VERSION=$($QMAKE -query QT_VERSION)
echo -e "${GREEN}Found Qt $QT_VERSION${NC}"

# Find macdeployqt
if command -v macdeployqt &> /dev/null; then
    MACDEPLOYQT="macdeployqt"
elif [ -f "/opt/homebrew/opt/qt@5/bin/macdeployqt" ]; then
    MACDEPLOYQT="/opt/homebrew/opt/qt@5/bin/macdeployqt"
elif [ -f "/usr/local/opt/qt@5/bin/macdeployqt" ]; then
    MACDEPLOYQT="/usr/local/opt/qt@5/bin/macdeployqt"
else
    echo -e "${RED}Error: macdeployqt not found${NC}"
    exit 1
fi

# Initialize submodules
echo -e "${YELLOW}Initializing submodules...${NC}"
git submodule update --init --recursive

# Apply patches
echo -e "${YELLOW}Applying patches...${NC}"

# Clean previous build
echo -e "${YELLOW}Cleaning previous build...${NC}"
rm -rf cool-retro-term.app
rm -f cool-retro-term.dmg
rm -f cool-retro-term
make clean 2>/dev/null || true

# Run qmake
echo -e "${YELLOW}Running qmake...${NC}"
$QMAKE cool-retro-term.pro

# Build
echo -e "${YELLOW}Building (this may take a few minutes)...${NC}"
make -j$(sysctl -n hw.ncpu)

# Run macdeployqt to bundle Qt frameworks (before modifying app bundle)
echo -e "${YELLOW}Bundling Qt frameworks...${NC}"
$MACDEPLOYQT cool-retro-term.app -qmldir=app/qml -qmldir=qmltermwidget

# Setup app bundle
echo -e "${YELLOW}Setting up app bundle...${NC}"
mkdir -p cool-retro-term.app/Contents/PlugIns

# Rename executable so we can use a launcher script
mv cool-retro-term.app/Contents/MacOS/cool-retro-term cool-retro-term.app/Contents/MacOS/cool-retro-term.bin

# Copy QMLTermWidget plugin
cp -r qmltermwidget/QMLTermWidget cool-retro-term.app/Contents/PlugIns/

# Create symlink for QMLTermWidget in qml directory
echo -e "${YELLOW}Setting up QML imports...${NC}"
mkdir -p cool-retro-term.app/Contents/Resources/qml
ln -sf ../../PlugIns/QMLTermWidget cool-retro-term.app/Contents/Resources/qml/QMLTermWidget

# Fix QMLTermWidget dylib dependencies
echo -e "${YELLOW}Fixing plugin dependencies...${NC}"
PLUGIN_DYLIB="cool-retro-term.app/Contents/PlugIns/QMLTermWidget/libqmltermwidget.dylib"
if [ -f "$PLUGIN_DYLIB" ]; then
    # Get Qt lib path
    QT_LIB_PATH=$($QMAKE -query QT_INSTALL_LIBS)

    # Fix each Qt framework reference
    for framework in QtCore QtGui QtWidgets QtQml QtQmlModels QtQuick QtNetwork; do
        install_name_tool -change \
            "$QT_LIB_PATH/$framework.framework/Versions/5/$framework" \
            "@executable_path/../Frameworks/$framework.framework/Versions/5/$framework" \
            "$PLUGIN_DYLIB" 2>/dev/null || true
    done
fi

# Create launcher script to set environment variables
echo -e "${YELLOW}Creating launcher script...${NC}"
cat > cool-retro-term.app/Contents/MacOS/cool-retro-term << 'LAUNCHER'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(dirname "$DIR")"

export QT_PLUGIN_PATH="$APP_DIR/PlugIns"
export QML2_IMPORT_PATH="$APP_DIR/Resources/qml:$APP_DIR/PlugIns"
export DYLD_FRAMEWORK_PATH="$APP_DIR/Frameworks"

exec "$DIR/cool-retro-term.bin" "$@"
LAUNCHER
chmod +x cool-retro-term.app/Contents/MacOS/cool-retro-term

# Ad-hoc code signing
echo -e "${YELLOW}Code signing (ad-hoc)...${NC}"
codesign --force --deep --sign - cool-retro-term.app

# Create DMG
if [ -z "$SKIP_DMG" ]; then
    echo -e "${YELLOW}Creating DMG...${NC}"
    hdiutil create -volname "Cool Retro Term" -srcfolder cool-retro-term.app -ov -format UDZO cool-retro-term.dmg
else
    echo -e "${YELLOW}Skipping DMG creation (SKIP_DMG set)...${NC}"
fi

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo -e "App bundle: ${GREEN}cool-retro-term.app${NC}"
echo -e "DMG file:   ${GREEN}cool-retro-term.dmg${NC}"
echo ""
echo "To run: open cool-retro-term.app"
