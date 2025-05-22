# NordShade

A darker variant of the [Nord](https://www.nordtheme.com/) color scheme.

## Color Palette

| Purpose     | Nord      | NordShade | Change |
| ----------- | --------- | --------- | ------ |
| Background  | `#2E3440` | `#1E222A` | -34.6% |
| Foreground  | `#D8DEE9` | `#D8DEE9` | +0.0%  |
| Selection   | `#4C566A` | `#394253` | -23.5% |
| Comments    | `#616E88` | `#57637D` | -9.8%  |
| Red         | `#BF616A` | `#BF616A` | +0.0%  |
| Orange      | `#D08770` | `#D08770` | +0.0%  |
| Yellow      | `#EBCB8B` | `#EBCB8B` | +0.0%  |
| Green       | `#A3BE8C` | `#A3BE8C` | +0.0%  |
| Cyan        | `#88C0D0` | `#88C0D0` | +0.0%  |
| Blue        | `#81A1C1` | `#81A1C1` | +0.0%  |
| Purple      | `#B48EAD` | `#B48EAD` | +0.0%  |
| Dark Gray   | `#3B4252` | `#2A2F3B` | -28.7% |
| Bright Gray | `#E5E9F0` | `#CACFD6` | -11.3% |

## Installation

### Option 1: Download and Install with One Command

You can install NordShade themes without cloning the repository using our installation scripts:

#### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/matt-edmondson/NordShade/main/install.ps1 | iex
```

#### macOS/Linux (Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/matt-edmondson/NordShade/main/install.sh | bash
```

The scripts will:

1. Detect your installed applications
2. Download necessary theme files (or use git clone if available)
3. Install themes for applications you choose
4. **Automatically apply the themes where possible**
5. Clean up temporary files after installation

#### Automatic Theme Application

The installation scripts will automatically apply themes for:

- **Visual Studio Code**: Updates settings.json with the NordShade theme
- **Windows Terminal**: Sets NordShade as the default color scheme for all profiles
- **Visual Studio 2022**: Attempts to apply theme using the VS command line interface
- **Windows 11**: Applies the theme using the Windows theme API and installs the included wallpaper
- **Obsidian**: Updates appearance.json to set NordShade as active theme

Some applications require manual steps after installation (like loading unpacked extensions or placing files in specific locations).

### Option 2: Clone Repository and Install

If you prefer to examine the files first:

```bash
# Clone the repository
git clone https://github.com/matt-edmondson/NordShade.git

# Change to NordShade directory
cd NordShade

# Run installation script
# On Windows
./install.ps1

# On macOS/Linux
./install.sh
```

## Themes

NordShade is available for:

- [Visual Studio 2022](./VisualStudio2022/)
- [Visual Studio Code](./VisualStudioCode/)
- [Windows Terminal](./WindowsTerminal/)
- [Windows 11](./Windows11/)
- [Microsoft Edge](./MicrosoftEdge/)
- [Obsidian](./Obsidian/)
- [Neovim](./Neovim/)
- [Windows PowerShell](./WindowsPowerShell/)
- [JetBrains DataGrip](./JetBrainsDataGrip/)
- [Discord](./Discord/)
- [GitHub Desktop](./GitHubDesktop/)
- [Fork](./Fork/)
- [Cursor](./Cursor/)
- [Blender](./Blender/)
- [Slack](./Slack/)
- [Docker Desktop](./DockerDesktop/)
- [Arduino IDE](./ArduinoIDE/)
- [Unity Hub](./UnityHub/)
