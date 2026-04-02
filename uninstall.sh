#!/bin/bash
set -e

INSTALL_DIR="/usr/local/share/amiga-info-thumbnailer"
PLUGIN_DIR=$(qtpaths --plugin-dir 2>/dev/null || echo "/usr/lib/x86_64-linux-gnu/qt5/plugins")

echo "=== Uninstalling Amiga .info Thumbnailer ==="

# Remove KDE plugin
echo "Removing KDE plugin..."
sudo rm -f "$PLUGIN_DIR/kf5/thumbcreator/amigainfothumbnail.so"

# Remove converter
echo "Removing converter..."
sudo rm -f /usr/local/bin/amiga-info-to-png
sudo rm -rf "$INSTALL_DIR"

# Remove MIME type
echo "Removing MIME type..."
rm -f ~/.local/share/mime/packages/amiga-info.xml
update-mime-database ~/.local/share/mime

# Remove from Dolphin config
DOLPHIN_RC="$HOME/.config/dolphinrc"
if [ -f "$DOLPHIN_RC" ]; then
    sed -i 's/,amigainfothumbnail//g; s/amigainfothumbnail,//g; s/amigainfothumbnail//g' "$DOLPHIN_RC"
fi

# Rebuild KDE service cache
if command -v kbuildsycoca5 &>/dev/null; then
    kbuildsycoca5 2>/dev/null
elif command -v kbuildsycoca6 &>/dev/null; then
    kbuildsycoca6 2>/dev/null
fi

# Clear thumbnail cache
rm -rf ~/.cache/thumbnails/normal/* ~/.cache/thumbnails/large/* 2>/dev/null

echo "Uninstallation complete."
