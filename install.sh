#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/usr/local/share/amiga-info-thumbnailer"

echo "=== Amiga .info Thumbnailer for KDE/Dolphin ==="
echo ""

# Check dependencies
echo "Checking dependencies..."

MISSING=()
command -v node &>/dev/null || MISSING+=("nodejs")
command -v cmake &>/dev/null || MISSING+=("cmake")
dpkg -l extra-cmake-modules &>/dev/null 2>&1 || MISSING+=("extra-cmake-modules")
dpkg -l libkf5kio-dev &>/dev/null 2>&1 || MISSING+=("libkf5kio-dev")
dpkg -l qtbase5-dev &>/dev/null 2>&1 || MISSING+=("qtbase5-dev")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing missing packages: ${MISSING[*]}"
    sudo apt install -y "${MISSING[@]}"
fi

# Install MIME type
echo "Installing MIME type..."
mkdir -p ~/.local/share/mime/packages
cp "$SCRIPT_DIR/mime/amiga-info.xml" ~/.local/share/mime/packages/
update-mime-database ~/.local/share/mime

# Install converter
echo "Installing icon converter..."
sudo mkdir -p "$INSTALL_DIR/converter"
sudo cp -r "$SCRIPT_DIR/converter/"* "$INSTALL_DIR/converter/"
sudo chmod +x "$INSTALL_DIR/converter/amiga-info-to-png"
sudo ln -sf "$INSTALL_DIR/converter/amiga-info-to-png" /usr/local/bin/amiga-info-to-png

# Install Node.js dependency
echo "Installing Node.js dependencies..."
cd "$INSTALL_DIR/converter/node"
sudo npm install --production 2>&1 | tail -1
cd "$SCRIPT_DIR"

# Build KDE plugin
echo "Building KDE ThumbCreator plugin..."
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"
cmake "$SCRIPT_DIR/plugin" 2>&1 | tail -1
make 2>&1 | tail -1

# Find the correct plugin directory
PLUGIN_DIR=$(qtpaths --plugin-dir 2>/dev/null || echo "/usr/lib/x86_64-linux-gnu/qt5/plugins")
THUMBCREATOR_DIR="$PLUGIN_DIR/kf5/thumbcreator"

echo "Installing KDE plugin to $THUMBCREATOR_DIR..."
sudo mkdir -p "$THUMBCREATOR_DIR"
sudo cp "$BUILD_DIR/libamigainfothumbnail.so" "$THUMBCREATOR_DIR/amigainfothumbnail.so"
rm -rf "$BUILD_DIR"

# Enable the plugin in Dolphin
DOLPHIN_RC="$HOME/.config/dolphinrc"
if [ -f "$DOLPHIN_RC" ]; then
    if grep -q "^Plugins=" "$DOLPHIN_RC"; then
        if ! grep -q "amigainfothumbnail" "$DOLPHIN_RC"; then
            sed -i "s/^Plugins=\(.*\)/Plugins=\1,amigainfothumbnail/" "$DOLPHIN_RC"
            echo "Enabled plugin in Dolphin config."
        fi
    fi
fi

# Rebuild KDE service cache
if command -v kbuildsycoca5 &>/dev/null; then
    kbuildsycoca5 2>/dev/null
elif command -v kbuildsycoca6 &>/dev/null; then
    kbuildsycoca6 2>/dev/null
fi

# Clear thumbnail cache
rm -rf ~/.cache/thumbnails/normal/* ~/.cache/thumbnails/large/* 2>/dev/null

echo ""
echo "Installation complete!"
echo "Restart Dolphin to see Amiga .info icon thumbnails."
echo ""
echo "Supported formats:"
echo "  - Classic Amiga icons (OS 1.x/2.x)"
echo "  - NewIcons"
echo "  - GlowIcons / ColorIcons (OS 3.5+)"
