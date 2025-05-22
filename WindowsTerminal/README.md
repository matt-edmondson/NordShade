# NordShade for Windows Terminal

A darker variant of the [Nord](https://www.nordtheme.com/) color scheme for Windows Terminal.

## Installation

### Method 1: Using Settings UI

1. Open Windows Terminal
2. Open Settings (Ctrl+,)
3. Click on "Open JSON file" in the bottom left corner
4. Add the content of `NordShade.json` to the `schemes` array
5. Save the settings file
6. Go back to the Settings UI
7. Select a profile you want to customize
8. Go to "Appearance"
9. Select "NordShade" from the "Color scheme" dropdown

### Method 2: Manual JSON Editing

1. Open Windows Terminal
2. Open Settings (Ctrl+,)
3. Click on "Open JSON file" in the bottom left corner
4. Add the content of `NordShade.json` to the `schemes` array:
   ```json
   "schemes": [
     {
       "name": "NordShade",
       "background": "#1E222A",
       "foreground": "#D8DEE9",
       "cursorColor": "#D8DEE9",
       "selectionBackground": "#394253",
       "black": "#2A2F3B",
       "blue": "#81A1C1",
       "cyan": "#88C0D0",
       "green": "#A3BE8C",
       "purple": "#B48EAD",
       "red": "#BF616A",
       "white": "#CACFD6",
       "yellow": "#EBCB8B",
       "brightBlack": "#394253",
       "brightBlue": "#81A1C1",
       "brightCyan": "#88C0D0",
       "brightGreen": "#A3BE8C",
       "brightPurple": "#B48EAD",
       "brightRed": "#BF616A",
       "brightWhite": "#D8DEE9",
       "brightYellow": "#EBCB8B"
     }
   ]
   ```
5. In the profiles section, add the color scheme to your profile:
   ```json
   "profiles": {
     "defaults": {
       "colorScheme": "NordShade"
     }
   }
   ```
6. Save the settings file

## Color Palette

| Purpose      | Hex Code  |
| ------------ | --------- |
| Background   | `#1E222A` |
| Foreground   | `#D8DEE9` |
| Selection    | `#394253` |
| Black        | `#2A2F3B` |
| Red          | `#BF616A` |
| Green        | `#A3BE8C` |
| Yellow       | `#EBCB8B` |
| Blue         | `#81A1C1` |
| Purple       | `#B48EAD` |
| Cyan         | `#88C0D0` |
| White        | `#CACFD6` |
| Bright Black | `#394253` |
| Bright White | `#D8DEE9` |
