import Foundation
import Combine

@MainActor
final class UsageViewModel: ObservableObject {
    @Published var usages: [UsageData] = []

    var menuBarLabel: String {
        guard let primary = usages.first else { return "—" }
        let pct = Int(primary.used * 100)
        return "\(pct)%"
    }

    private var providers: [UsageProvider] = []
    private var timers: [AnyCancellable] = []
    private var authManager: AuthManager?
    private var authCancellable: AnyCancellable?

    init() {}

    func configure(with authManager: AuthManager) {
        guard self.authManager == nil else { return }
        self.authManager = authManager

        // If already authenticated, add provider immediately
        if authManager.isAuthenticated {
            addProviderIfNeeded(authManager: authManager)
        }

        // Observe future auth changes
        authCancellable = authManager.$isAuthenticated
            .removeDuplicates()
            .sink { [weak self] isAuthenticated in
                guard let self else { return }
                if isAuthenticated {
                    self.addProviderIfNeeded(authManager: authManager)
                } else {
                    self.removeAllProviders()
                }
            }
    }

    private func addProviderIfNeeded(authManager: AuthManager) {
        guard !providers.contains(where: { $0.id == "claude-code" }) else { return }
        addProvider(ClaudeCodeProvider(authManager: authManager))
    }

    func addProvider(_ provider: UsageProvider) {
        providers.append(provider)
        startPolling(provider)
        Task { await refresh(provider) }
    }

    func removeAllProviders() {
        providers.removeAll()
        timers.removeAll()
        usages.removeAll()
    }

    private func startPolling(_ provider: UsageProvider) {
        let timer = Timer.publish(every: provider.refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh(provider) }
            }
        timers.append(timer)
    }

    private func refresh(_ provider: UsageProvider) async {
        guard let data = await provider.fetchUsage() else { return }
        if let idx = usages.firstIndex(where: { $0.providerName == provider.name }) {
            usages[idx] = data
        } else {
            usages.append(data)
        }
    }
}
