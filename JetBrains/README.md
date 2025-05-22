# NordShade for JetBrains IDEs

A darker variant of the Nord theme for JetBrains IDEs (IntelliJ IDEA, WebStorm, PyCharm, CLion, DataGrip, GoLand, PhpStorm, Rider, RubyMine, etc.).

## Automatic Installation

Use the provided installation scripts to automatically install the theme for all detected JetBrains IDE installations:

### Windows

Run the `install.ps1` PowerShell script in this directory.

### macOS/Linux

Run the `install.sh` Bash script in this directory:

```bash
chmod +x install.sh
./install.sh
```

## Manual Installation

1. Locate your JetBrains IDE configuration folder:

   - **Windows**:

     - `%APPDATA%\JetBrains\<Product><Version>`
     - `C:\Users\<Username>\.jetbrains\<Product><Version>`

   - **macOS**:
     - `~/Library/Application Support/JetBrains/<Product><Version>`
   - **Linux**:
     - `~/.config/JetBrains/<Product><Version>`
     - `~/.<Product><Version>`

2. Create a `colors` directory inside the config folder if it doesn't exist.

3. Copy the `NordShade.xml` file from this folder to the `colors` directory.

4. Restart your JetBrains IDE if it's running.

5. Go to Settings > Editor > Color Scheme and select "NordShade" from the dropdown menu.

## Compatibility

This theme is compatible with all JetBrains IDEs based on the IntelliJ platform:

- IntelliJ IDEA
- WebStorm
- PyCharm
- CLion
- DataGrip
- GoLand
- PhpStorm
- Rider
- RubyMine
- Android Studio
- And other IntelliJ-based IDEs

## Notes

- The theme will be applied to the editor, code syntax highlighting, UI elements, and debugger.
- Your existing theme settings will not be overwritten; the theme will be installed as an additional option.
- If you've customized your current theme, consider exporting it before switching to NordShade.
