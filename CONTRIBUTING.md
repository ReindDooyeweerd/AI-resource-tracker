# Contributing to AI Resource Tracker

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs 🐛

If you find a bug, please create an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- macOS version and app version
- Any relevant console logs

### Suggesting Features 💡

Feature requests are welcome! Please:
- Check if the feature has already been requested
- Describe the use case and benefits
- Explain how it should work

### Submitting Pull Requests 🔧

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**: `git commit -m "Add feature: description"`
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Open a Pull Request**

## Development Setup

1. Clone the repository
2. Open `AI resource tracker.xcodeproj` in Xcode
3. Select your development team for signing
4. Build and run (⌘R)

## Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Leverage Swift Concurrency (async/await)
- Add comments for complex logic
- Use meaningful variable names

## Testing

Before submitting:
- Test the app with and without Claude Code authentication
- Verify the UI on different macOS versions (if possible)
- Check for memory leaks in Instruments
- Ensure no console errors

## Adding New Providers

To add support for other AI services:

1. Create a new file: `YourProviderName.swift`
2. Conform to the `UsageProvider` protocol
3. Implement authentication (via AuthManager or separately)
4. Parse API responses into `UsageData`
5. Add provider to `UsageViewModel`
6. Update README with new provider info

Example structure:
```swift
final class NewAIProvider: UsageProvider {
    let id = "new-ai"
    let name = "New AI Service"
    let refreshInterval: TimeInterval = 60
    
    func fetchUsage() async -> UsageData? {
        // Implement API integration
    }
}
```

## Questions?

Feel free to open an issue for any questions or discussions!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
