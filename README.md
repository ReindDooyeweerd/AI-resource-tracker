# AI Resource Tracker 🧠

A lightweight macOS menu bar app that tracks your Claude Code API usage in real-time.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- 📊 **Real-time Usage Tracking** - Monitor your Claude Code API usage with automatic 30-second updates
- 🎯 **Menu Bar Integration** - Glanceable usage percentage directly in your menu bar
- ⏰ **Reset Timer** - See when your 5-hour usage window resets
- 🔐 **Secure Authentication** - Uses your existing Claude Code credentials from Keychain
- 🎨 **Native macOS Design** - Clean, modern SwiftUI interface

**Screenshots can be found here:**

- https://share.cleanshot.com/Hr7wz1l1jmhk30V0Y0NS
- https://share.cleanshot.com/J3KlDzq0rPc8sWS4tq0b
- https://share.cleanshot.com/XlGCXvYGmYr21Tr4Zhrh

## Requirements

- macOS 12.0 or later
- Claude Code installed and authenticated
- Xcode 15.0+ (for building from source)

## Installation

### Option 1: Download Pre-built App (Recommended)

1. Go to the [Releases](../../releases) page
2. Download the latest `AI-Resource-Tracker.app.zip`
3. Unzip the file
4. Move `AI Resource Tracker.app` to your Applications folder
5. Right-click the app and select "Open" (required for first launch due to Gatekeeper)

### Option 2: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ai-resource-tracker.git
   cd ai-resource-tracker
   ```

2. Open the project in Xcode:
   ```bash
   open AI\ resource\ tracker.xcodeproj
   ```

3. Select your signing team in Xcode:
   - Select the project in the navigator
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

4. Build and run (⌘R)

## Usage

1. **First Launch**: If you haven't signed in to Claude Code yet:
   - Open Terminal
   - Run `claude` command
   - Complete the OAuth authentication
   - Restart AI Resource Tracker

2. **Normal Use**:
   - The app shows your usage percentage in the menu bar
   - Click the menu bar icon to see detailed information:
     - Current usage percentage
     - Time until usage window resets
     - Detailed usage breakdown
   
3. **Launch at Login** (Optional):
   - Click the menu bar icon
   - Select "Open at Login..."
   - Enable the app in Login Items settings

4. **Quit**: Click the menu bar icon and select "Quit"

## How It Works

AI Resource Tracker integrates with Claude Code's authentication system:

- Reads your OAuth credentials from macOS Keychain (service: `Claude Code-credentials`)
- Reads your organization ID from `~/.claude.json`
- Uses the Anthropic OAuth API to fetch usage data
- Displays your 5-hour usage window utilization

## Privacy & Security

- ✅ All credentials are stored securely in macOS Keychain
- ✅ No data is collected or sent to third parties
- ✅ API calls go directly to Anthropic's servers
- ✅ Open source - you can audit the code yourself

## Building for Distribution

To create a distributable build:

### Quick Build (Unsigned)

```bash
# Build release version
xcodebuild -project "AI resource tracker.xcodeproj" \
           -scheme "AI resource tracker" \
           -configuration Release \
           -derivedDataPath ./build

# Find the built app
open build/Build/Products/Release/
```

### Signed and Notarized Build (Recommended)

1. **Archive the app**:
   - In Xcode: Product → Archive
   - Wait for the build to complete

2. **Export the app**:
   - Click "Distribute App"
   - Select "Copy App"
   - Choose a destination folder

3. **Sign the app** (if you have a Developer ID):
   ```bash
   codesign --deep --force --verify --verbose \
            --sign "Developer ID Application: YOUR NAME (TEAM_ID)" \
            "AI Resource Tracker.app"
   ```

4. **Notarize the app** (optional, requires paid Apple Developer account):
   ```bash
   # Create a zip
   ditto -c -k --keepParent "AI Resource Tracker.app" "AI-Resource-Tracker.zip"
   
   # Submit for notarization
   xcrun notarytool submit AI-Resource-Tracker.zip \
                          --apple-id "your@email.com" \
                          --team-id "YOUR_TEAM_ID" \
                          --password "app-specific-password" \
                          --wait
   
   # Staple the notarization ticket
   xcrun stapler staple "AI Resource Tracker.app"
   ```

5. **Create release zip**:
   ```bash
   ditto -c -k --keepParent "AI Resource Tracker.app" "AI-Resource-Tracker-v1.0.zip"
   ```

6. **Upload to GitHub Releases**:
   - Go to your repository on GitHub
   - Click "Releases" → "Create a new release"
   - Add a tag (e.g., `v1.0.0`)
   - Upload the zip file
   - Write release notes

### Alternative: Using GitHub Actions

Create `.github/workflows/release.yml` for automated builds on tag push.

## Development

### Project Structure

```
AI resource tracker/
├── AI_resource_trackerApp.swift     # App entry point
├── PopoverView.swift                # Main UI
├── AuthManager.swift                # Authentication handling
├── UsageViewModel.swift             # Data management
├── ClaudeCodeProviderFinal.swift   # API integration
└── UsageProvider.swift              # Protocol definitions
```

### Adding New Providers

To add support for other AI services:

1. Create a new class conforming to `UsageProvider`
2. Implement the required properties and `fetchUsage()` method
3. Add the provider in `UsageViewModel.configure()`

Example:
```swift
final class NewAIProvider: UsageProvider {
    let id = "new-ai"
    let name = "New AI Service"
    let refreshInterval: TimeInterval = 60
    
    func fetchUsage() async -> UsageData? {
        // Implement API call
    }
}
```

## Troubleshooting

**App shows "Not Signed In"**
- Make sure Claude Code is installed and you've run `claude` at least once
- Try running `claude` in Terminal to refresh authentication
- Restart the AI Resource Tracker app

**No usage data showing**
- Check that you have an active Claude Code subscription
- Ensure you have internet connectivity
- Check Console.app for error messages (filter for "AI resource tracker")

**App won't open (Gatekeeper)**
- Right-click the app and select "Open"
- Or: System Settings → Privacy & Security → Allow anyway

## Contributing

Contributions are welcome! Feel free to:
- Report bugs via Issues
- Suggest features via Issues
- Submit Pull Requests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and Swift Concurrency
- Uses the Anthropic OAuth API
- Inspired by the need to track AI usage limits

## Disclaimer

This is an unofficial app and is not affiliated with or endorsed by Anthropic. Claude and Claude Code are trademarks of Anthropic, PBC.

---

Made with ❤️ by [Reind Dooyeweerd](https://github.com/reinddooyeweerd)
