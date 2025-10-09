# pfUI Raid Distance

A pfUI extension addon that displays distance and line-of-sight information on raid and party frames.

## Features

- Shows distance in yards to raid/party members
- Visual line-of-sight indicator (white = LOS, red = no LOS)
- Configurable update frequency for performance tuning
- Customizable font size, positioning, and text alignment
- Native pfUI integration with GUI configuration

## Installation

1. Copy the `pfUI-raiddistance` folder to your WoW AddOns directory
2. Reload your UI or restart WoW
3. The addon will automatically load with pfUI

## Usage

1. Open pfUI configuration (`/pfui`)
2. Navigate to **Thirdparty** → **Raid Distance**
3. Configure:
   - **Enable Raid Distance** - Toggle the entire system on/off
   - **Update Frequency** - How often to refresh distances (seconds, default: 0.5)
   - **Font Size** - Size of distance text (default: 10)
   - **X Offset** - Horizontal position adjustment
   - **Y Offset** - Vertical position adjustment
   - **Text Alignment** - Left, Center, or Right alignment

## Visual Indicators

- **White text** - Unit is in line-of-sight
- **Red text** - Unit is NOT in line-of-sight (behind wall/obstacle)
- **"--"** - Distance cannot be determined
- **"##yr"** - Distance in yards (e.g., "25yr")

## Performance

This addon is optimized for raid environments:
- Configurable update frequency to balance accuracy vs. CPU usage
- Only updates active raid/party frames
- Skips player's own frame
- Efficient frame counter system for timing updates

## Technical Details

Requires:
- pfUI (dependency)
- UnitXP addon or similar for distance calculations

Works with:
- pfUI raid frames (up to 40 players)
- pfUI party frames (when not in raid)

## Disclaimer

**USE AT YOUR OWN RISK**

- This addon is provided **AS-IS** with no warranty
- I do not provide support for this addon
- If you encounter issues, you can fork the code and modify it yourself
- Consider using AI tools (like Claude 4.5) to create your own version
- I maintain this addon only as long as I personally use it
- No guarantee of future compatibility or updates
- No responses to feature requests or support inquiries

## License

Feel free to modify, fork, or redistribute as needed.

## Credits

Built as an extension to pfUI for Vanilla/TBC WoW. Shagu is the GOAT, all hail the King.
