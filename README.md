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
3. Ask if you want to automatically apply themes or just install them
4. Install themes for applications you choose
5. Clean up temporary files after installation

#### Theme Application Options

You can now choose whether to automatically apply themes during installation:

- **Auto-Apply (Yes)**: The installer will apply themes immediately where possible
- **Install Only (No)**: Themes will be installed but will require manual activation in each application

This option is presented at the beginning of the installation process and applies to all applications. If you choose "No", the installer will provide instructions for manually activating each theme.

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

## Theme Management

NordShade uses a modular architecture with:

1. **Application-specific installers**: Each supported app has its own installation script
2. **Central index**: An `index.json` file defines all available themes and required files
3. **Main installers**: Unified scripts that orchestrate the installation process

### index.json

The `index.json` file is the central registry for all NordShade themes. It:

- Lists all supported applications
- Defines required files for each theme
- Specifies download locations
- Makes adding new themes simple without modifying the main installers

This architecture ensures themes are downloaded only when needed and installed consistently.

## Supported Applications

NordShade is available for:

- [Visual Studio Code](./VisualStudioCode/)
- [Visual Studio 2022](./VisualStudio2022/)
- [Windows Terminal](./WindowsTerminal/)
- [Windows 11](./Windows11/)
- [Microsoft Edge](./MicrosoftEdge/)
- [Obsidian](./Obsidian/)
- [Neovim](./Neovim/)
- [JetBrains IDEs](./JetBrains/)
- [Discord](./Discord/)
- [GitHub Desktop](./GitHubDesktop/)
- [Cursor IDE](./Cursor/)

Each application folder contains:

- Theme files
- Installation scripts
- Documentation

The modular architecture makes it easy to install themes for specific applications or all detected applications at once.
