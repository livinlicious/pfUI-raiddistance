# pfUI Raid Distance

An extension for **pfUI** that displays distance information on **Raid**, **Party**, and **Target** unit frames.

## Features

- **Distance Display**: Shows the distance in yards (e.g., "25yr") on unit frames.
- **Smart Coloring**: Text turns **Red** if the unit is out of range (>40 yards) or out of line-of-sight. Text is **White** otherwise.
- **Separate Configurations**: Individually configure settings for **Raid**, **Party**, and **Target** frames.
- **Performance Optimized**: Configurable update frequency to minimize CPU usage in large raids.
- **Native Integration**: Seamlessly integrated into the pfUI settings menu.

> **Note:** Target of Target (ToT) and ToToT frames are intentionally not supported to keep the addon lightweight and focused.

## Installation

1. Copy the `pfUI-raiddistance` folder to your WoW AddOns directory:
   `...\Interface\AddOns\pfUI-raiddistance`
2. Restart WoW or reload your UI.

## Usage & Configuration

Go to **pfUI Settings** (`/pfui`) → **Thirdparty** → **Raid Distance**.

Global Settings:
- **Update Frequency**: How often to refresh distances (default: 0.5s).

Per-Frame Settings (Raid / Party / Target):
- **Enable**: Toggle distance display for this specific frame type.
- **Font Size**: Adjust the text size.
- **X / Y Offset**: Fine-tune the position.
- **Text Alignment**: Left, Center, or Right.

## Technical Details

- **Dependencies**: Requires `pfUI`.
- **Distance Calculation**: Relies on standard library functions (like generic `UnitXP` or native APIs if available) to determine distance and Line of Sight.
- **Layering**: Text is properly layered (Overlay) to ensure it appears above health bars, especially on Party frames.

## Disclaimer

**USE AT YOUR OWN RISK**

- This addon is provided **AS-IS** with no warranty.
- I do not provide support for this addon.
- If you encounter issues, feel free to fork and modify the code.
- I maintain this addon only for personal use; feature requests may not be addressed.

## Credits

Built as an extension to **pfUI** for Vanilla/TBC WoW.
Shagu is the GOAT, all hail the King.
