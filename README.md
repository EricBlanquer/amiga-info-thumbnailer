# Amiga .info Thumbnailer for KDE/Dolphin

Thumbnail preview plugin for Amiga Workbench `.info` icon files in KDE Dolphin file manager.

## Supported formats

- **Classic icons** (AmigaOS 1.x/2.x) - planar bitmap format
- **NewIcons** - extended icon format with embedded palette
- **GlowIcons / ColorIcons** (AmigaOS 3.5+) - IFF-based truecolor icons

## Requirements

- KDE Plasma 5 with Dolphin
- Node.js (for GlowIcon/NewIcon decoding)
- netpbm (`infotopam`, `pamtopng`) - optional fallback for classic icons
- Build tools: `cmake`, `extra-cmake-modules`, `libkf5kio-dev`, `qtbase5-dev`

### Ubuntu/Debian

```bash
sudo apt install nodejs npm cmake extra-cmake-modules libkf5kio-dev qtbase5-dev netpbm
```

## Installation

```bash
git clone https://github.com/ebmusic/amiga-info-thumbnailer.git
cd amiga-info-thumbnailer
chmod +x install.sh
./install.sh
```

Then restart Dolphin.

## Uninstallation

```bash
./uninstall.sh
```

## How it works

1. A **custom MIME type** (`application/x-amiga-info`) is registered for `.info` files based on the Amiga magic number `0xE310`
2. A **converter script** (`amiga-info-to-png`) decodes the icon to PNG using the [Amiga-Icon-converter](https://github.com/steffest/Amiga-Icon-converter) library (MIT), with fallback to `infotopam` from netpbm
3. A **KDE ThumbCreator plugin** (C++) calls the converter and returns the image to Dolphin's thumbnail system

## Standalone usage

The converter can also be used standalone:

```bash
amiga-info-to-png MyIcon.info output.png
```

## Credits

- Icon decoding: [Amiga-Icon-converter](https://github.com/steffest/Amiga-Icon-converter) by Steffest (MIT License)
- Classic icon fallback: [netpbm](https://netpbm.sourceforge.net/) (`infotopam`)

## License

MIT
