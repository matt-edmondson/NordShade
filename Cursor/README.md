# NordShade for Cursor IDE

A darker variant of the [Nord](https://www.nordtheme.com/) color scheme, specifically adapted for Cursor IDE.

## Installation

### Automatic Installation

The easiest way to install NordShade for Cursor is using the provided installation scripts from the root directory of the NordShade repository:

#### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/matt-edmondson/NordShade/main/install.ps1 | iex
```

#### macOS/Linux (Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/matt-edmondson/NordShade/main/install.sh | bash
```

The installer will automatically detect if Cursor is installed and add it to the list of applications for NordShade theme installation.

### Manual Installation

To manually install the theme:

1. Navigate to your Cursor extensions directory:

   - Windows: `%LOCALAPPDATA%\Programs\Cursor\resources\app\extensions` or `%APPDATA%\cursor-editor\extensions`
   - macOS: `~/Library/Application Support/cursor-editor/extensions`
   - Linux: `~/.config/cursor-editor/extensions`

2. Create a folder called `nordshade-theme` and copy the `NordShade.json` and `package.json` files into it.

3. Restart Cursor IDE.

4. Open Settings (Ctrl+,/Cmd+,), search for "color theme", and select "NordShade" from the dropdown menu.

## Features

- Optimized dark theme based on the Nord color scheme
- Enhanced readability with carefully selected contrast
- Semantic highlighting for improved code comprehension
- Reduced eye strain during long coding sessions

## Screenshots

[Screenshot of Cursor IDE with NordShade theme]

## Credits

Based on the Nord color scheme by Arctic Ice Studio.

## License

MIT
