# NordShade for GitHub Desktop

A darker variant of the Nord theme for GitHub Desktop.

## Installation Instructions

GitHub Desktop supports custom themes through its user stylesheet override. The process requires modifying a CSS file in your GitHub Desktop installation.

### Windows Installation

1. Close GitHub Desktop if it's running.

2. Navigate to the GitHub Desktop styles directory:

   ```
   %USERPROFILE%\AppData\Local\GitHubDesktop\app-<version>\resources\app\static\common
   ```

   Note: Replace `<version>` with your installed version number (e.g., `3.4.19`).

3. Back up the original `main.js` file by copying it to `main.js.backup`.

4. Copy the contents of `nord-shade.less` from this repository.

5. Open the `main.js` file with a text editor.

6. Find the section containing style definitions (usually near other theme definitions like "dark" and "light").

7. Paste the NordShade theme code at the end of the styles section, right before the end of the stylesheet definition.

8. Save the file and restart GitHub Desktop.

### macOS Installation

1. Close GitHub Desktop if it's running.

2. Navigate to the GitHub Desktop styles directory:

   ```
   ~/Applications/GitHub Desktop.app/Contents/Resources/app/static/common
   ```

   Alternatively, right-click on "GitHub Desktop" in Applications, select "Show Package Contents" and navigate to Contents/Resources/app/static/common.

3. Follow steps 3-8 from the Windows installation instructions.

### Linux Installation

1. Close GitHub Desktop if it's running.

2. Navigate to the GitHub Desktop styles directory (location may vary based on installation method).

3. Follow steps 3-8 from the Windows installation instructions.

## Updating GitHub Desktop

Note that after updating GitHub Desktop, you'll need to reapply the theme as updates will overwrite your customizations.

## Troubleshooting

If the theme doesn't apply correctly:

1. Ensure you've modified the correct `main.js` file.
2. Check that you've inserted the theme code in the right location.
3. Try clearing the GitHub Desktop cache by going to "Help" > "Reset GitHub Desktop to Factory Settings" (you'll need to set up your repositories again).

## Reverting to Default Theme

To revert to the default theme, simply replace the modified `main.js` file with your backup, or reinstall GitHub Desktop.
