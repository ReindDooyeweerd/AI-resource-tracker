# 🎉 AI Resource Tracker v1.0.0 - Initial Release

I'm excited to share the first release of **AI Resource Tracker** - a lightweight macOS menu bar app that helps you monitor your Claude Code API usage in real-time!

## 🌟 What is this?

If you use Claude Code (the AI coding assistant), you know it has usage limits that reset every 5 hours. This app sits quietly in your menu bar and shows you exactly how much of your quota you've used, so you're never caught off guard.

## ✨ Features

- **📊 Real-time Usage Tracking** - See your usage percentage right in the menu bar
- **⏰ Reset Timer** - Know exactly when your 5-hour window resets
- **🔐 Secure Authentication** - Uses your existing Claude Code credentials (no extra login needed!)
- **🎨 Native macOS Design** - Clean, modern SwiftUI interface that feels right at home
- **⚡ Lightweight** - Minimal resource usage, auto-updates every 30 seconds

## 🔐 How Authentication Works

**You don't need to enter any credentials!** The app automatically uses your existing Claude Code authentication:

1. **Reads from macOS Keychain** - When you sign in to Claude Code, it stores an OAuth access token in your macOS Keychain (service name: `Claude Code-credentials`)
2. **Reads Organization ID** - Gets your organization UUID from `~/.claude.json` 
3. **Calls Anthropic API** - Uses these credentials to fetch your usage data directly from Anthropic's official OAuth API endpoint

**Your credentials never leave your Mac.** All API calls go directly from your computer to Anthropic's servers. This app doesn't collect, store, or transmit any of your data.

## 📋 Requirements

- **macOS 12.0 or later**
- **Claude Code installed and authenticated** (just run `claude` once in Terminal)
- That's it!

## 🚀 Installation

1. **Download** the `AI-Resource-Tracker.app.zip` file below
2. **Unzip** the file
3. **Move** the app to your Applications folder
4. **Right-click** the app and select "Open" (required on first launch due to macOS Gatekeeper)
5. The app will appear in your menu bar! 🎉

## 📖 First-Time Setup

If you haven't signed in to Claude Code yet:

1. Open Terminal
2. Run: `claude`
3. Complete the OAuth sign-in process
4. Restart AI Resource Tracker

The app will automatically detect your credentials and start showing your usage!

## 🎯 Usage

- **Menu Bar Icon** - Shows your current usage percentage (e.g., "23%")
- **Click the Icon** - Opens a detailed view with:
  - Full usage breakdown
  - Time remaining until reset
  - Quick access to quit or configure launch at login

## ⚠️ Known Limitations

- **First Launch Security Warning** - Since this app isn't notarized with Apple (requires a paid developer account), you'll need to right-click and select "Open" on first launch
- **Claude Code Only** - Currently only supports Claude Code. Support for other AI services coming in future releases!
- **macOS Only** - This is a native macOS app (no Windows/Linux support planned)

## 🐛 Troubleshooting

**"Not Signed In" message?**
- Make sure you've run `claude` in Terminal at least once
- Try running `claude` again to refresh your authentication
- Restart the AI Resource Tracker app

**No usage data appearing?**
- Ensure you have an active internet connection
- Check that you have a Claude Code subscription with API access
- Open Console.app and filter for "AI resource tracker" to see debug logs

## 🙏 Feedback & Contributions

This is an open-source project! Feel free to:
- ⭐ Star the repo if you find it useful
- 🐛 Report bugs via [Issues](../../issues)
- 💡 Suggest features
- 🔧 Contribute code via [Pull Requests](../../pulls)

Check out the [README](../../blob/main/README.md) for development setup and [CONTRIBUTING](../../blob/main/CONTRIBUTING.md) guidelines.

## 🔮 Future Plans

Ideas for upcoming releases:
- Support for other AI providers (OpenAI, Gemini, etc.)
- Multiple API key management
- Usage history/graphs
- Custom alert thresholds
- Customizable refresh intervals

## 📄 License

This project is licensed under the MIT License - free to use, modify, and distribute!

## ⚠️ Disclaimer

This is an unofficial app and is not affiliated with or endorsed by Anthropic. Claude and Claude Code are trademarks of Anthropic, PBC.

---

**Download the app below and never lose track of your AI usage again!** 🚀

If you encounter any issues, please [open an issue](../../issues) and I'll do my best to help.

Happy coding! 🧠✨
